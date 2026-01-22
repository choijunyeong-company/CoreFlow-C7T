import CoreFlow

protocol MainListener: AnyObject {}

enum MainAction {
    case viewDidLoad
}

struct MainState {
    var userName: String = ""
    let user: User
}

final class MainCore: Core<MainAction, MainState> {
    weak var listener: MainListener?

    override func reduce(state: inout MainState, action: MainAction) -> Effect<MainAction> {
        switch action {
        case .viewDidLoad:
            state.userName = state.user.name
            return .none
        }
    }
}
