import SwiftUI

@main
struct DivaryApp: App {
    var body: some Scene {
        WindowGroup {
            DiaryImageSelectView(viewModel: DiaryImageSelectViewModel())
        }
    }
}
