import CoreFlow

extension MainFlow {
    struct Argument {
        let user: User
    }
}

final class MainFlow: Flow<MainCore, MainScreen> {
    private weak var listener: MainListener?
    private let argument: Argument

    init(listener: MainListener, argument: Argument) {
        self.listener = listener
        self.argument = argument
    }

    override func createCore() -> MainCore {
        let core = MainCore(initialState: .init(user: argument.user))
        core.listener = listener
        return core
    }

    override func createScreen() -> MainScreen {
        let screen = MainScreen(reactor: core)
        screen.bind()
        return screen
    }
}

