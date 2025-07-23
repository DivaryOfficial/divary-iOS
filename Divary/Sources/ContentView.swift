import SwiftUI
enum Field: Hashable {
    case leader, buddy, partner
}

public struct ContentView: View {
    public init() {}

    public var body: some View {
        Text("Hello, World!")
            .padding()
            .font(Font.omyu.regular(size: 32))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
