// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ffmpeg-kit",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "ffmpeg-kit",
            targets: [
                "libavcodec",
                "libavdevice",
                "libavfilter",
                "libavformat",
                "libavutil",
                "libswresample",
                "libswscale",
                "ffmpegkit",
            ]
        )
    ],
    targets: [
        .binaryTarget(name: "libavcodec", path: "libavcodec.xcframework"),
        .binaryTarget(name: "libavdevice", path: "libavdevice.xcframework"),
        .binaryTarget(name: "libavfilter", path: "libavfilter.xcframework"),
        .binaryTarget(name: "libavformat", path: "libavformat.xcframework"),
        .binaryTarget(name: "libavutil", path: "libavutil.xcframework"),
        .binaryTarget(name: "libswresample", path: "libswresample.xcframework"),
        .binaryTarget(name: "libswscale", path: "libswscale.xcframework"),
        .binaryTarget(name: "ffmpegkit", path: "ffmpegkit.xcframework"),
    ]
)
