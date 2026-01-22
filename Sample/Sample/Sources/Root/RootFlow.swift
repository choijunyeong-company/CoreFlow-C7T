import CoreFlow
import UIKit

public final class RootFlow: Flow<RootCore, RootScreen> {
    private weak var listener: RootListener?
    
    private var loginFlow: LoginFlow?
    private var mainFlow: MainFlow?

    public init(listener: RootListener) {
        self.listener = listener
        super.init()
    }

    public override func createCore() -> RootCore {
        let core = RootCore(initialState: .init())
        core.listener = listener
        core.router = self
        return core
    }

    public override func createScreen() -> RootScreen {
        let screen = RootScreen(reactor: core)
        screen.bind()
        return screen
    }
}

// MARK: - Routing
extension RootFlow: RootRouting {
    public func routeToLogin() {
        let loginFlow = LoginFlow(listener: core)
        self.loginFlow = loginFlow
        
        screen.navigationController?.pushViewController(
            loginFlow.screen, animated: true
        )
    }
    
    public func dismissLogin() {
        screen.navigationController?.popViewController(animated: true)
    }
    
    public func routeToMain(user: User) {
        let mainFlow = MainFlow(
            listener: core,
            argument: .init(user: user)
        )
        self.mainFlow = mainFlow
        
        screen.navigationController?.pushViewController(
            mainFlow.screen, animated: true
        )
    }
}
