import CoreFlow

public final class LoginFlow: Flow<LoginCore, LoginScreen> {
    private weak var listener: LoginListener?

    /// 리스너를 주입받아 Flow를 초기화합니다.
    public init(listener: LoginListener) {
        self.listener = listener
        super.init()
    }

    /// Core를 생성하고 필요한 의존성(listener, router)을 설정합니다.
    public override func createCore() -> LoginCore {
        let core = LoginCore(initialState: .init())
        core.listener = listener
        core.router = self
        return core
    }

    /// Screen을 생성하고 바인딩을 설정합니다.
    public override func createScreen() -> LoginScreen {
        let screen = LoginScreen(reactor: core)
        screen.bind()
        return screen
    }
}

// MARK: - Routing
/// Routing 프로토콜 구현: 필요한 라우팅 메서드를 여기에 추가
extension LoginFlow: LoginRouting {}
