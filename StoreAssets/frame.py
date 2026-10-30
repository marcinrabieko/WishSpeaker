#!/usr/bin/env python3
"""Turns the raw App Store screenshots from capture.py into marketing ones: a caption
on a warm background above the screenshot set in a drawn iPhone frame. Needs ImageMagick.

    python3 StoreAssets/frame.py                       # every device in StoreAssets/Output
    python3 StoreAssets/frame.py --devices "iPhone 17 Pro" --only 01-start
"""

import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "StoreAssets" / "Output"
FRAMED = ROOT / "StoreAssets" / "Framed"

VIDEO_ASSETS = ROOT / "Packages/CorePackage/Sources/VideoRendering/Assets"
APP_ICON = ROOT / "Targets/MobileApp/Resources/Assets.xcassets/AppIcon.appiconset/image.png"
TITLE_FONT = ROOT / "Packages/CorePackage/Sources/Resources/Fonts/NewYork.ttf"
SUBTITLE_FONT = Path("/System/Library/Fonts/SFNS.ttf")

BACKGROUND_TOP = "#FFF8EC"
BACKGROUND_BOTTOM = "#F3D9A8"
GLOW = "#FFFFFF"
TITLE_COLOR = "#1F1A17"
SUBTITLE_COLOR = "#7A6A58"
ACCENT_COLOR = "#E30613"
BEZEL_COLOR = "#0E0E10"
RIM_COLOR = "#B9B2A8"

CAPTIONS = {
    "01-start": ("Wishes that sound\npersonal", "Turn a few details into a heartfelt message"),
    "02-occasion": ("A wish for\nevery occasion", "Birthdays, weddings, anniversaries and more"),
    "03-form": ("Tell us about\nthem", "A few details make the wish truly theirs"),
    "04-wishes": ("Pick the perfect\ntone", "Warm, natural or light — you choose"),
    "05-result": ("Hear it come\nto life", "A narrated video wish, ready to share"),
    "05b-share": ("Hear it, then\nshare it anywhere", "Send your video wish in any messenger"),
    "06-library": ("All your wishes\nin one place", "Text, voice and video, saved for later"),
    "07-examples": ("Hear what's\npossible", "Listen to example wishes before you start"),
}

# Framed screenshots made from another one's raw capture instead of their own.
SOURCE_SCREENSHOTS = {
    "05b-share": "05-result",
}


# The opening "what this app does" page, placed before the framed screenshots.
INTRO_NAME = "00-intro"
INTRO_TAGLINE = "Wishes that sound personal"
INTRO_DESCRIPTION = (
    "Tell us who it's for and a few things about them. WishSpeaker writes a heartfelt wish "
    "and turns it into a narrated video, ready to share."
)
INTRO_OCCASIONS = "Birthdays · Weddings · Mother's Day · and more"

# First pages of three example wish videos, fanned out under the description — left,
# center (in front), right. Rendered like WishVideoRenderer renders the real ones.
INTRO_WISHES = [
    ("wedding", "On Your Wedding Day", ["Emily & James, today", "two travel buddies", "become a family."]),
    ("celebration", "On Your Birthday", ["Happy 30th birthday, Mia!", "Here's to your first", "marathon, your new life", "in Lisbon and to Pickle!"]),
    ("floral", "On Mother's Day", ["Happy Mother's Day, Mom!", "Thank you for every", "bedtime story and every", "hug that fixed it all."]),
]

# VideoLayout values for the 1024px canvas WishVideoRenderer renders at.
CARD_CANVAS = 1024
CARD_BORDER_SIZE = 840
CARD_TEXT_COLOR = "&H00121417"
CARD_FONT_SIZE = 50
CARD_LINE_SPACING = 5
CARD_GREETING_FONT_SIZE = 56
CARD_GREETING_CENTER_Y = 302
CARD_TEXT_CENTER_Y = 546


def magick(*args):
    subprocess.run(["magick", *map(str, args)], check=True)


def framed_phone(screenshot, screen_width, work):
    """The screenshot scaled to `screen_width`, with rounded corners and a Dynamic
    Island, inside a black bezel and a thin metal rim — proportions of an iPhone 17 Pro."""
    width, height = map(int, subprocess.run(
        ["magick", "identify", "-format", "%w %h", str(screenshot)],
        check=True, capture_output=True, text=True,
    ).stdout.split())

    screen_height = round(height * screen_width / width)
    corner = round(screen_width * 0.14)
    bezel = round(screen_width * 0.032)
    rim = round(screen_width * 0.009)

    island_width = round(screen_width * 0.29)
    island_height = round(screen_width * 0.085)
    island_top = round(screen_width * 0.03)
    island_left = (screen_width - island_width) // 2

    # Only the tall, Dynamic Island iPhones get one — not e.g. the iPhone Duo.
    island = [
        "-fill", "black", "-draw",
        f"roundrectangle {island_left},{island_top} {island_left + island_width},{island_top + island_height} "
        f"{island_height // 2},{island_height // 2}",
    ] if height / width > 2.0 else []

    screen = work / "screen.png"
    magick(
        screenshot, "-resize", f"{screen_width}x{screen_height}!",
        *island,
        "(", "-size", f"{screen_width}x{screen_height}", "xc:none", "-fill", "white",
        "-draw", f"roundrectangle 0,0 {screen_width - 1},{screen_height - 1} {corner},{corner}", ")",
        "-alpha", "set", "-compose", "DstIn", "-composite",
        screen,
    )

    phone_width = screen_width + 2 * (bezel + rim)
    phone_height = screen_height + 2 * (bezel + rim)
    phone = work / "phone.png"
    magick(
        "-size", f"{phone_width}x{phone_height}", "xc:none",
        "-fill", RIM_COLOR, "-draw",
        f"roundrectangle 0,0 {phone_width - 1},{phone_height - 1} {corner + bezel + rim},{corner + bezel + rim}",
        "-fill", BEZEL_COLOR, "-draw",
        f"roundrectangle {rim},{rim} {phone_width - rim - 1},{phone_height - rim - 1} {corner + bezel},{corner + bezel}",
        screen, "-geometry", f"+{bezel + rim}+{bezel + rim}", "-composite",
        phone,
    )

    return phone


def frame(screenshot, destination, title, subtitle):
    width, height = map(int, subprocess.run(
        ["magick", "identify", "-format", "%w %h", str(screenshot)],
        check=True, capture_output=True, text=True,
    ).stdout.split())

    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        phone = framed_phone(screenshot, round(width * 0.74), work)

        phone_top = round(height * 0.24)
        title_size = round(width * 0.088)
        subtitle_size = round(width * 0.04)
        subtitle_top = round(height * 0.055 + title_size * 2.4)

        magick(
            *background(width, height, glow_center=0.62),
            "-gravity", "north",
            "-font", TITLE_FONT, "-pointsize", title_size, "-fill", TITLE_COLOR, "-interline-spacing", round(-title_size * 0.12),
            "-annotate", f"+0+{round(height * 0.055)}", title,
            "-font", SUBTITLE_FONT, "-pointsize", subtitle_size, "-fill", SUBTITLE_COLOR, "-interline-spacing", 0,
            "-annotate", f"+0+{subtitle_top}", subtitle,
            # Drop shadow, then the phone itself.
            "(", phone, "-background", "#5A3A10", "-shadow", f"35x{round(width * 0.025)}+0+{round(width * 0.03)}", ")",
            "-gravity", "north", "-geometry", f"+0+{phone_top - round(width * 0.05)}", "-composite",
            phone, "-gravity", "north", "-geometry", f"+0+{phone_top}", "-composite",
            "-alpha", "off",
            destination,
        )


def wish_card(theme, greeting, lines, destination, work):
    """One frame of a wish video's title page: the theme's background and border with
    the greeting and wish text set by libass in the same style SubtitleScript uses."""
    def page(text_lines, font_size):
        return f"{{\\fs{CARD_LINE_SPACING}}}\\N{{\\fs{font_size}}}\\N".join(text_lines)

    center_x = CARD_CANVAS // 2
    soften = "\\blur1\\bord0.5"
    script = work / f"{theme}.ass"
    script.write_text(
        "[Script Info]\nScriptType: v4.00+\n"
        f"PlayResX: {CARD_CANVAS}\nPlayResY: {CARD_CANVAS}\n\n"
        "[V4+ Styles]\n"
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, "
        "Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, "
        "BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n"
        f"Style: Default,Libre Baskerville,{CARD_FONT_SIZE},{CARD_TEXT_COLOR},{CARD_TEXT_COLOR},{CARD_TEXT_COLOR},"
        "&H00000000,0,0,0,0,100,100,0,0,1,0,0,5,0,0,0,1\n\n"
        "[Events]\n"
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n"
        f"Dialogue: 0,0:00:00.00,0:00:05.00,Default,,0,0,0,,{{\\an5\\pos({center_x},{CARD_GREETING_CENTER_Y})"
        f"\\fs{CARD_GREETING_FONT_SIZE}{soften}}}{greeting}\n"
        f"Dialogue: 0,0:00:00.00,0:00:05.00,Default,,0,0,0,,{{\\an5\\pos({center_x},{CARD_TEXT_CENTER_Y}){soften}}}"
        f"{page(lines, CARD_FONT_SIZE)}\n"
    )

    offset = (CARD_CANVAS - CARD_BORDER_SIZE) // 2
    frame_file = work / f"{theme}-frame.png"
    subprocess.run(
        [
            "ffmpeg", "-y", "-loglevel", "error",
            "-ss", "2", "-i", str(VIDEO_ASSETS / f"background_{theme}_normalized.mp4"),
            "-i", str(VIDEO_ASSETS / f"border_{theme}.png"),
            "-filter_complex",
            f"[0:v]scale={CARD_CANVAS}:{CARD_CANVAS}:force_original_aspect_ratio=increase,"
            f"crop={CARD_CANVAS}:{CARD_CANVAS}[bg];[1:v]scale={CARD_BORDER_SIZE}:{CARD_BORDER_SIZE}[border];"
            f"[bg][border]overlay={offset}:{offset},subtitles='{script}':fontsdir='{VIDEO_ASSETS}'",
            "-frames:v", "1", str(frame_file),
        ],
        check=True,
    )

    # Rounded like the video player in the app.
    corner = round(CARD_CANVAS * 0.06)
    magick(
        frame_file,
        "(", "-size", f"{CARD_CANVAS}x{CARD_CANVAS}", "xc:none", "-fill", "white",
        "-draw", f"roundrectangle 0,0 {CARD_CANVAS - 1},{CARD_CANVAS - 1} {corner},{corner}", ")",
        "-alpha", "set", "-compose", "DstIn", "-composite",
        destination,
    )


def background(width, height, glow_center):
    """The warm gradient with a soft glow at `glow_center` (a fraction of the height),
    echoing the app's own bokeh background."""
    return [
        "-size", f"{width}x{height}", f"gradient:{BACKGROUND_TOP}-{BACKGROUND_BOTTOM}",
        "(", "-size", f"{width}x{height}", "xc:none", "-fill", GLOW,
        "-draw", f"ellipse {width // 2},{round(height * glow_center)} {round(width * 0.55)},{round(height * 0.3)} 0,360",
        "-blur", f"0x{round(width * 0.12)}", "-channel", "A", "-evaluate", "multiply", "0.55", "+channel", ")",
        "-composite",
    ]


def intro(destination, width, height):
    """App icon, name and tagline over a short description and three example wish
    videos — sized like the device's screenshots so it slots in as the first one."""
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)

        # Everything is sized off a phone-proportioned column, so a wider screen
        # (e.g. iPhone Duo) gets the same layout centered rather than blown up.
        unit = min(width, round(height * 0.46))

        icon_size = round(unit * 0.3)
        icon_corner = round(icon_size * 0.2237)
        icon = work / "icon.png"
        magick(
            APP_ICON, "-resize", f"{icon_size}x{icon_size}",
            "(", "-size", f"{icon_size}x{icon_size}", "xc:none", "-fill", "white",
            "-draw", f"roundrectangle 0,0 {icon_size - 1},{icon_size - 1} {icon_corner},{icon_corner}", ")",
            "-alpha", "set", "-compose", "DstIn", "-composite",
            icon,
        )

        back_size = round(unit * 0.46)
        front_size = round(unit * 0.56)
        cards = []

        for index, (theme, greeting, lines) in enumerate(INTRO_WISHES):
            card = work / f"card-{theme}.png"
            wish_card(theme, greeting, lines, card, work)

            is_front = index == 1
            size = front_size if is_front else back_size
            angle = 0 if is_front else (-6 if index == 0 else 6)
            magick(
                card, "-resize", f"{size}x{size}",
                "-background", "none", "-rotate", angle,
                card,
            )
            cards.append(card)

        icon_top = round(height * 0.07)
        name_top = icon_top + icon_size + round(height * 0.03)
        name_size = round(unit * 0.115)
        tagline_size = round(unit * 0.05)
        description_top = name_top + round(name_size * 1.25) + round(tagline_size * 1.9)

        # Two cards side by side at the back, the third in front and lower, covering
        # only their bottom edge so all three greetings stay readable.
        cards_top = round(height * 0.46)
        back_shift = round(unit * 0.23)
        front_top = cards_top + round(back_size * 0.78)
        shadow = ["-background", "#5A3A10", "-shadow", f"40x{round(unit * 0.02)}+0+{round(unit * 0.02)}"]

        layout = []
        for card, shift, top in [
            (cards[0], -back_shift, cards_top),
            (cards[2], back_shift, cards_top),
            (cards[1], 0, front_top),
        ]:
            layout += [
                "(", card, *shadow, ")", "-gravity", "north",
                "-geometry", f"{shift:+d}+{top - round(unit * 0.02)}", "-composite",
                card, "-gravity", "north", "-geometry", f"{shift:+d}+{top}", "-composite",
            ]

        occasions_top = front_top + front_size + round(height * 0.03)

        magick(
            *background(width, height, glow_center=0.25),
            "(", icon, "-background", "#5A3A10", "-shadow", f"40x{round(unit * 0.03)}+0+{round(unit * 0.025)}", ")",
            "-gravity", "north", "-geometry", f"+0+{icon_top - round(unit * 0.05)}", "-composite",
            icon, "-gravity", "north", "-geometry", f"+0+{icon_top}", "-composite",
            "-font", TITLE_FONT, "-pointsize", name_size, "-fill", TITLE_COLOR,
            "-annotate", f"+0+{name_top}", "WishSpeaker",
            "-font", TITLE_FONT, "-pointsize", tagline_size, "-fill", ACCENT_COLOR,
            "-annotate", f"+0+{name_top + round(name_size * 1.3)}", INTRO_TAGLINE,
            "(", "-size", f"{round(unit * 0.8)}x", "-background", "none", "-font", SUBTITLE_FONT,
            "-pointsize", round(unit * 0.04), "-fill", SUBTITLE_COLOR, "-gravity", "center",
            "-interline-spacing", round(unit * 0.012), f"caption:{INTRO_DESCRIPTION}", ")",
            "-gravity", "north", "-geometry", f"+0+{description_top}", "-composite",
            *layout,
            "-font", SUBTITLE_FONT, "-pointsize", round(unit * 0.036), "-fill", SUBTITLE_COLOR,
            "-gravity", "north", "-annotate", f"+0+{occasions_top}", INTRO_OCCASIONS,
            "-alpha", "off",
            destination,
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--devices", nargs="+")
    parser.add_argument("--only", nargs="+", help="screenshot names, e.g. 01-start")
    args = parser.parse_args()

    devices = args.devices or sorted(path.name for path in OUTPUT.iterdir() if path.is_dir())

    for device in devices:
        (FRAMED / device).mkdir(parents=True, exist_ok=True)

        if not args.only or INTRO_NAME in args.only:
            width, height = map(int, subprocess.run(
                ["magick", "identify", "-format", "%w %h", str(OUTPUT / device / "01-start.png")],
                check=True, capture_output=True, text=True,
            ).stdout.split())
            intro(FRAMED / device / f"{INTRO_NAME}.png", width, height)
            print(f"  🖼  {device}/{INTRO_NAME}.png")

        for name, (title, subtitle) in CAPTIONS.items():
            if args.only and name not in args.only:
                continue

            screenshot = OUTPUT / device / f"{SOURCE_SCREENSHOTS.get(name, name)}.png"
            frame(screenshot, FRAMED / device / f"{name}.png", title, subtitle)
            print(f"  🖼  {device}/{name}.png")

    print(f"\n✓ Done — {FRAMED}")


if __name__ == "__main__":
    main()
