import SwiftUI

struct Second: View {

    let number: Int
    @State var isPresented = false

    var body: some View {
        Button("tapped \(number)") {
            isPresented = true
        }.sheet(isPresented: $isPresented, onDismiss: nil) {
            Text("Sheet shown")
        }
    }
}
