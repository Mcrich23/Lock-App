import SwiftUI
import SwiftData

@main
struct LockApp: App {
    @State var aes: AES
    @State var isShowingAESError: Bool = false
    @State var aesError: String = ""
    
    init() {
        do {
            aes = try .getAES()
        } catch {
            print(error)
            aes = .init(key: Data())
            aesError = error.localizedDescription
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isShowingAESError {
                Text("Uh Oh!")
                    .font(.title)
                Text("We encountered an error while loading LOCK: *\(aesError)*")
            } else {
                PasswordNavigationView()
            }
        }
        .modelContainer(for: Item.self)
        .environment(aes)
    }
}
