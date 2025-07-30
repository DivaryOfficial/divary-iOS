import SwiftUI

@main
struct DivaryApp: App {
    
    var body: some Scene {
        WindowGroup {
            DiaryMainView(showCanvas: .constant(false))
        }
    }
}
