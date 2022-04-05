import Foundation
import SwiftUI

struct PasscodeView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    @inlinable public init(viewModel: ViewModel){
        self.viewModel = viewModel
    }

    var body: some View {
        if (viewModel.routingState.isPresented) {
            coverView
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.white)
        } else {
            Color.clear.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }

    private var coverView: AnyView {
        return AnyView(loadedView())
    }

    private func loadedView() -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Please enter the passcode")
                .padding(.bottom, 71)
            PasscodeField(resultText: $viewModel.userDataState.passcode)
                .padding(.bottom, 24)
                .shake(amount: -20, animatableData: CGFloat(viewModel.attempts))
                .onAnimationCompleted(for: CGFloat(viewModel.attempts)) {
                    viewModel.userDataState.passcode = ""
                }
        }
        .onAppear {
            viewModel.userDataState.passcode = ""
        }
    }
}
