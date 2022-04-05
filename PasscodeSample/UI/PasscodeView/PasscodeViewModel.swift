import SwiftUI

// MARK: - Routing & UserData
extension PasscodeView {
    struct Routing: Equatable {
        var isPresented: Bool = false
    }

    struct UserData: Equatable {
        var passcode: String = ""
    }
}

// MARK: - ViewModel

extension PasscodeView {
    class ViewModel: ObservableObject {

        // State
        @Published var routingState: Routing
        @Published var userDataState: UserData
        @Published var storedPasscode: String

        @Published var attempts: Int = 0

        // Misc
        private var cancelBag = CancelBag()

        init(appState: Store<AppState>, storedPasscode: String = "") {
            _userDataState = .init(initialValue: appState.value.userData.passcodeView)
            _routingState = .init(initialValue: appState.value.routing.passcodeView)
            _storedPasscode = .init(initialValue: storedPasscode)

            cancelBag.collect {
                $routingState
                    .sink { appState[\.routing.passcodeView] = $0 }
                appState.map(\.routing.passcodeView)
                    .removeDuplicates()
                    .assign(to: \.routingState, on: self)

                $userDataState
                    .sink {
                        appState[\.userData.passcodeView] = $0
                        if ($0.passcode.count == PasscodeField.Count) {
                            if $0.passcode == self.storedPasscode {
                                // succeeded
                                self.routingState.isPresented = false
                            } else {
                                // unmatched
                                DispatchQueue.main.async {
                                    withAnimation(Animation.default.repeatCount(3, autoreverses: true).speed(6)) {
                                        self.attempts += 1
                                    }
                                }
                            }
                        }
                    }
                appState.map(\.userData.passcodeView)
                    .removeDuplicates()
                    .assign(to: \.userDataState, on: self)

                $storedPasscode.sink { stored in
                    let matched = !stored.isEmpty && stored == self.userDataState.passcode
                    // unset if no passcode is stored or input passcode is matched with stored one
                    self.routingState.isPresented = !(stored.isEmpty || matched)
                }
            }

            self.loadPasscode()
        }

        func loadPasscode() {
            // dummy stored pass code
            storedPasscode = "1234"
        }
    }
}
