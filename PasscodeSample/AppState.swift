import SwiftUI
import Combine

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
}

extension AppState {
    struct UserData: Equatable {
        var passcodeView = PasscodeView.UserData()
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var passcodeView = PasscodeView.Routing()
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData &&
        lhs.routing == rhs.routing
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        return AppState()
    }
}
#endif
