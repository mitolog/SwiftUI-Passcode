import SwiftUI

struct First: View {

    var body: some View {
        NavigationView {
            List {
                ForEach(0..<10){ index in
                    NavigationLink(String(index)) {
                        Second(number: index)
                    }
                }
            }
        }
    }
}
