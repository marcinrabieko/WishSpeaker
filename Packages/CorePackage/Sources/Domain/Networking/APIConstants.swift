import Foundation

enum APIConstants {
    /// The local FastAPI dev server (see WishSpeaker-Backend/run.sh) — point this at the
    /// Render URL once the backend is deployed.
    ///
    /// "localhost" only resolves to the Mac itself, which works from the Simulator
    /// (it shares the host's network) but not from a physical device — a real iPhone
    /// needs the Mac's LAN IP instead, and both devices must be on the same Wi-Fi.
    /// Find it with `ipconfig getifaddr en0` while connected to Wi-Fi.
    static let baseURL = URL(string: "http://192.168.1.14:8000")!
}
