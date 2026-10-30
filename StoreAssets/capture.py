#!/usr/bin/env python3
"""Captures App Store screenshots and an App Preview video on iOS simulators.

The app drives itself through the flow (see ScreenshotDemo in Domain, Debug builds
only); this script records the screen, answers each screenshot handshake and turns the
raw recording into an App Store Connect-ready App Preview.

    python3 StoreAssets/capture.py --prepare     # once: render the narrated fixture video
    python3 StoreAssets/capture.py               # screenshots + App Preview per device
    python3 StoreAssets/capture.py --skip-build --devices "iPhone 17 Pro"
"""

import argparse
import json
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORE_ASSETS = ROOT / "StoreAssets"
FIXTURES = STORE_ASSETS / "Fixtures"
OUTPUT = STORE_ASSETS / "Output"
DERIVED_DATA = ROOT / "build" / "StoreAssets"
APP_PATH = DERIVED_DATA / "Build" / "Products" / "Debug-iphonesimulator" / "WishSpeaker.app"
BUNDLE_ID = "com.rabieko.wishspeaker"

DEFAULT_DEVICES = ["iPhone 17 Pro Max", "iPhone 17 Pro"]

# Models with more than one screen need the one the app is on named explicitly, and get
# no App Preview of their own — App Store Connect takes the same 886×1920 one there.
# (The iPhone Duo simulator keeps its 2007×2853 screen dark, so only 1398×2034 is used.)
MULTI_DISPLAY_DEVICES = {
    "iPhone Duo": "1",
}
LAUNCH_LOCALE_ARGS = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]

# Copied into the app's Documents directory before every walkthrough run — names must
# match ScreenshotDemo+Fixtures.swift.
DOCUMENT_FIXTURES = {
    FIXTURES / "screenshot_demo.mp4": "screenshot_demo.mp4",
    FIXTURES / "screenshot_demo_thumbnail.jpg": "screenshot_demo_thumbnail.jpg",
    ROOT / "Packages/CorePackage/Sources/ExampleWishesFeature/Demo/thankyou_demo.mp3": "screenshot_demo_voice.mp3",
}

# App Store Connect App Preview spec for 6.3"/6.9" iPhones.
PREVIEW_WIDTH, PREVIEW_HEIGHT = 886, 1920
PREVIEW_MIN_SECONDS, PREVIEW_MAX_SECONDS = 15.0, 30.0


def run(*command, capture=False):
    result = subprocess.run(command, check=True, text=True, capture_output=capture)
    return result.stdout.strip() if capture else None


def simctl(*args, capture=False):
    return run("xcrun", "simctl", *args, capture=capture)


def build():
    print("› xcodegen generate")
    run("xcodegen", "generate", "--spec", str(ROOT / "project.yml"), "--quiet")

    print("› xcodebuild (Debug, iOS Simulator)")
    run(
        "xcodebuild",
        "-project", str(ROOT / "WishSpeaker.xcodeproj"),
        "-scheme", "MobileApp",
        "-configuration", "Debug",
        "-destination", "generic/platform=iOS Simulator",
        "-derivedDataPath", str(DERIVED_DATA),
        "-quiet",
        "build",
        # The FFmpegKit xcframework's simulator slice is arm64-only.
        "ARCHS=arm64",
    )


def resolve_device(model):
    """A dedicated "StoreAssets <model>" simulator, created on the newest iOS runtime
    if it doesn't exist yet — so a run never reinstalls apps or overrides the status
    bar on a simulator that's in use for something else."""
    name = f"StoreAssets {model}"
    devices = json.loads(simctl("list", "devices", "available", "-j", capture=True))["devices"]

    for runtime_devices in devices.values():
        for device in runtime_devices:
            if device["name"] == name:
                return device["udid"]

    device_types = json.loads(simctl("list", "devicetypes", "-j", capture=True))["devicetypes"]
    device_type = next((item["identifier"] for item in device_types if item["name"] == model), None)

    if device_type is None:
        sys.exit(f"Unknown simulator model '{model}'")

    runtimes = json.loads(simctl("list", "runtimes", "available", "-j", capture=True))["runtimes"]
    # Some models (e.g. iPhone Duo) only run on their own device-specific runtime.
    ios_runtimes = [
        runtime for runtime in runtimes
        if runtime["platform"] == "iOS"
        and any(item["identifier"] == device_type for item in runtime.get("supportedDeviceTypes", []))
    ]
    newest_runtime = max(ios_runtimes, key=lambda runtime: [int(part) for part in runtime["version"].split(".")])

    print(f"› Creating simulator '{name}' (iOS {newest_runtime['version']})")
    return simctl("create", name, device_type, newest_runtime["identifier"], capture=True)


def prepare_device(udid):
    subprocess.run(["xcrun", "simctl", "boot", udid], capture_output=True)
    simctl("bootstatus", udid, "-b")

    # The status bar formats the overridden time with the device's region — anything
    # but a 12-hour one turns Apple's "9:41" into "09:41". SpringBoard only picks up a
    # region change after a reboot.
    region = subprocess.run(
        ["xcrun", "simctl", "spawn", udid, "defaults", "read", "-g", "AppleLocale"],
        capture_output=True,
        text=True,
    ).stdout.strip()

    if region != "en_US":
        simctl("spawn", udid, "defaults", "write", "-g", "AppleLocale", "en_US")
        simctl("spawn", udid, "defaults", "write", "-g", "AppleLanguages", "-array", "en")
        simctl("shutdown", udid)
        simctl("boot", udid)
        simctl("bootstatus", udid, "-b")

    simctl("ui", udid, "appearance", "light")
    simctl(
        "status_bar", udid, "override",
        "--time", "9:41",
        "--dataNetwork", "wifi",
        "--wifiMode", "active",
        "--wifiBars", "3",
        "--cellularMode", "active",
        "--cellularBars", "4",
        "--batteryState", "charged",
        "--batteryLevel", "100",
    )

    subprocess.run(["xcrun", "simctl", "terminate", udid, BUNDLE_ID], capture_output=True)
    subprocess.run(["xcrun", "simctl", "uninstall", udid, BUNDLE_ID], capture_output=True)
    simctl("install", udid, str(APP_PATH))

    return Path(simctl("get_app_container", udid, BUNDLE_ID, "data", capture=True)) / "Documents"


def wait_for_marker(markers, name, timeout):
    deadline = time.time() + timeout

    while time.time() < deadline:
        if (markers / name).exists():
            return (markers / name).read_text()
        time.sleep(0.2)

    sys.exit(f"Timed out waiting for {name}")


def prepare_fixtures(device_name):
    """Renders the narrated fixture video through the real backend once."""
    udid = resolve_device(device_name)
    documents = prepare_device(udid)
    markers = documents / "ScreenshotDemo"

    print(f"› Rendering fixture video on {device_name} (backend + on-device ffmpeg)")
    simctl("launch", udid, BUNDLE_ID, "-ScreenshotDemoPrepare", *LAUNCH_LOCALE_ARGS)

    deadline = time.time() + 300

    while time.time() < deadline:
        if (markers / "prepare-failed.mark").exists():
            sys.exit(f"Fixture rendering failed: {(markers / 'prepare-failed.mark').read_text()}")
        if (markers / "prepared.mark").exists():
            break
        time.sleep(1)
    else:
        sys.exit("Timed out rendering the fixture video")

    FIXTURES.mkdir(parents=True, exist_ok=True)
    shutil.copy(documents / "screenshot_demo.mp4", FIXTURES / "screenshot_demo.mp4")
    shutil.copy(documents / "screenshot_demo_thumbnail.jpg", FIXTURES / "screenshot_demo_thumbnail.jpg")
    simctl("terminate", udid, BUNDLE_ID)

    duration = (markers / "prepared.mark").read_text()
    print(f"✓ Fixtures saved to {FIXTURES} (duration {duration}s — set Fixture.videoDuration)")


def capture_device(device_name):
    udid = resolve_device(device_name)
    output = OUTPUT / device_name
    shutil.rmtree(output, ignore_errors=True)
    output.mkdir(parents=True)

    print(f"\n━━ {device_name} ({udid})")
    documents = prepare_device(udid)
    documents.mkdir(parents=True, exist_ok=True)

    for source, file_name in DOCUMENT_FIXTURES.items():
        if not source.exists():
            sys.exit(f"Missing fixture {source} — run with --prepare first")
        shutil.copy(source, documents / file_name)

    markers = documents / "ScreenshotDemo"
    shutil.rmtree(markers, ignore_errors=True)

    display = MULTI_DISPLAY_DEVICES.get(device_name)
    raw_video = output / "raw_recording.mp4"
    recorder = None

    if display is None:
        recorder = subprocess.Popen(
            ["xcrun", "simctl", "io", udid, "recordVideo", "--codec=h264", "--force", str(raw_video)],
            stderr=subprocess.PIPE,
            text=True,
        )

        # recordVideo prints "Recording started" once the first frame is being written —
        # that moment is t=0 for every marker timestamp below.
        for line in recorder.stderr:
            if "Recording started" in line:
                break
    recording_start = time.time()

    simctl("launch", udid, BUNDLE_ID, "-ScreenshotDemo", *LAUNCH_LOCALE_ARGS)

    timestamps = {}
    deadline = time.time() + 180

    while "finished" not in timestamps:
        if time.time() > deadline:
            if recorder:
                recorder.send_signal(signal.SIGINT)
            sys.exit("Timed out waiting for the walkthrough to finish")

        for marker in sorted(markers.glob("*")) if markers.exists() else []:
            name, kind = marker.stem, marker.suffix

            if kind not in (".ready", ".mark") or name in timestamps:
                continue

            timestamps[name] = time.time() - recording_start

            if kind == ".ready":
                display_args = [f"--display={display}"] if display else []
                simctl("io", udid, "screenshot", *display_args, str(output / f"{name}.png"))
                (markers / f"{name}.done").write_text("")
                print(f"  📸 {name}  ({timestamps[name]:.1f}s)")

        time.sleep(0.05)

    simctl("terminate", udid, BUNDLE_ID)
    # Shut down so the next device's walkthrough doesn't share the Mac with this one.
    simctl("shutdown", udid)

    if recorder is None:
        return

    recorder.send_signal(signal.SIGINT)
    recorder.wait()

    make_app_preview(raw_video, output / "app_preview.mp4", timestamps)


def make_app_preview(raw_video, preview, timestamps):
    start = timestamps["preview-start"]
    end = timestamps["preview-end"]
    duration = end - start
    narration_delay_ms = int((timestamps["video-start"] - start) * 1000)

    # The simulator records no audio — the narration comes from the fixture video,
    # aligned to the moment the app pressed play, over silence for everything before it.
    filter_graph = (
        f"[0:v]fps=30,scale={PREVIEW_WIDTH}:-2,crop={PREVIEW_WIDTH}:{PREVIEW_HEIGHT},setsar=1,format=yuv420p[v];"
        f"[1:a]adelay={narration_delay_ms}|{narration_delay_ms},apad,atrim=0:{duration:.3f},"
        f"aformat=sample_rates=48000:channel_layouts=stereo[a]"
    )

    run(
        "ffmpeg", "-y", "-loglevel", "error",
        "-ss", f"{start:.3f}", "-t", f"{duration:.3f}", "-i", str(raw_video),
        "-i", str(FIXTURES / "screenshot_demo.mp4"),
        "-filter_complex", filter_graph,
        "-map", "[v]", "-map", "[a]",
        "-c:v", "libx264", "-profile:v", "high", "-preset", "slow", "-b:v", "10M",
        "-c:a", "aac", "-b:a", "256k",
        "-movflags", "+faststart",
        "-t", f"{duration:.3f}",
        str(preview),
    )

    print(f"  🎬 {preview.name}  ({duration:.1f}s)")

    if not PREVIEW_MIN_SECONDS <= duration <= PREVIEW_MAX_SECONDS:
        print(f"  ⚠️  App Previews must be {PREVIEW_MIN_SECONDS:.0f}–{PREVIEW_MAX_SECONDS:.0f}s long")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--devices", nargs="+", default=DEFAULT_DEVICES)
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--prepare", action="store_true", help="render the narrated fixture video instead")
    args = parser.parse_args()

    if not args.skip_build:
        build()

    if args.prepare:
        prepare_fixtures(args.devices[0])
        return

    for device_name in args.devices:
        capture_device(device_name)

    print(f"\n✓ Done — {OUTPUT}")


if __name__ == "__main__":
    main()
