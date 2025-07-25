import SwiftUI

@main
struct DivaryApp: App {
    var body: some Scene {
        WindowGroup {
            DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: .constant(true)), offsetY: 300)
        }
    }
}
