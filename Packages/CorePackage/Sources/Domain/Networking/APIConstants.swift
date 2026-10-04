import Foundation

enum APIConstants {
    /// The local FastAPI dev server (see WishSpeaker-Backend/run.sh) — point this at the
    /// Render URL once the backend is deployed.
    static let baseURL = URL(string: "http://localhost:8000")!
}
