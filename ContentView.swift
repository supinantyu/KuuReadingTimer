import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("タイマー")
                }

            BookshelfView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("本棚")
                }
        }
        .tint(.blue)
    }
}
