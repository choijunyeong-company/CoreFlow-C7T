import CoreFlow
import Combine

/// Procedure의 각 단계에서 수행할 작업을 정의하는 Step 프로토콜입니다.
/// Core가 이 프로토콜을 채택하여 각 Step의 실제 동작을 구현합니다.
protocol RootProcedureStep {
    /// 로그인 완료를 기다리는 중간 Step
    /// - Returns: (다음 Step, 전달할 User 데이터)를 포함한 Publisher
    func waitForLogin() -> AnyPublisher<(RootProcedureStep, User), Never>

    /// 메인 화면으로 라우팅하는 마지막 Step
    func routeToMain(user: User)
}

public protocol RootListener: AnyObject {
    func rootIsReady()
}

public protocol RootRouting: AnyObject {
    func routeToLogin()
    func dismissLogin()
    func routeToMain(user: User)
}

public enum RootAction {
    case viewDidLoad
}

public struct RootState {}

public final class RootCore: Core<RootAction, RootState> {
    weak var listener: RootListener?
    weak var router: RootRouting?

    /// Step 완료를 알리기 위한 Subject입니다.
    /// 하위 CoreFlow의 Listener를 통해 완료 신호를 받으면 값을 발행합니다.
    private let loginStepFinished = CurrentValueSubject<User?, Never>(nil)

    public override func reduce(state: inout RootState, action: RootAction) -> Effect<RootAction> {
        switch action {
        case .viewDidLoad:
            listener?.rootIsReady()
            return .none
        }
    }
}

/// 하위 CoreFlow(Login)의 Listener 구현입니다.
/// 로그인 완료 시 Subject에 값을 발행하여 Procedure Step을 완료시킵니다.
extension RootCore: LoginListener {
    public func loginFinished(user: User) {
        router?.dismissLogin()
        loginStepFinished.send(user)
    }
}

extension RootCore: MainListener {}

/// Step 프로토콜 구현입니다.
extension RootCore: RootProcedureStep {
    func waitForLogin() -> AnyPublisher<(RootProcedureStep, User), Never> {
        // 1. 로그인 화면으로 라우팅
        router?.routeToLogin()

        // 2. loginStepFinished Subject를 구독하여 완료를 대기
        // 3. User 데이터가 발행되면 (self, user) 튜플로 변환하여 다음 Step에 전달
        return loginStepFinished
            .compactMap(\.self)
            .map { user in (self, user) }
            .eraseToAnyPublisher()
    }

    func routeToMain(user: User) {
        router?.routeToMain(user: user)
    }
}
