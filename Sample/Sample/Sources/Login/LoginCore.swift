import CoreFlow

/// 상위 CoreFlow에 요청사항을 전송하는 프로토콜입니다.
/// 로그인 완료 후 상위 CoreFlow에 해당 CoreFlow의 종료를 알립니다.
public protocol LoginListener: AnyObject {
    func loginFinished(user: User)
}

/// Flow에 요청할 라우팅 액션을 선언하는 프로토콜입니다.
public protocol LoginRouting: AnyObject {}

/// Screen으로부터 수신하는 유저 액션과 내부 파생 액션입니다.
/// 내부에서만 사용되는 액션의 경우 케이스명 앞에 언더바(_)를 붙입니다.
public enum LoginAction {
    case viewDidLoad
    case loginButtonTapped
    /// 내부 파생 액션: 로그인 완료 후 호출
    case _loginFinished(User)
}

/// Screen의 상태 또는 Core 내부 상태를 정의합니다.
public struct LoginState {
    var isLoading = false
}

public final class LoginCore: Core<LoginAction, LoginState> {
    /// 의존성 주입: ServiceLocator로부터 자동 해결
    @Autowired private var service: LoginService

    weak var listener: LoginListener?
    weak var router: LoginRouting?

    public override func reduce(state: inout LoginState, action: LoginAction) -> Effect<LoginAction> {
        switch action {
        case .viewDidLoad:
            return .none
            
        case .loginButtonTapped:
            state.isLoading = true
            return .run { [weak self] send in
                guard let self else { return }
                
                let user = await service.login()
                await send(._loginFinished(user))
            }
            
        case ._loginFinished(let user):
            state.isLoading = false
            listener?.loginFinished(user: user)
            return .none
        }
    }
}
