import SwiftUI

struct ContentView: View {
    var body: some View {
        PlanListView()
            .preferredColorScheme(.dark) // Force Dark Mode as per Design Specs
    }
}
