@preconcurrency @_exported import Swinject

/// 의존성을 자동으로 주입받는 프로퍼티 래퍼입니다.
///
/// 객체 초기화 시점에 `ServiceLocator`로부터 의존성을 해결합니다.
/// 해당 타입이 등록되어 있지 않으면 런타임 오류가 발생합니다.
///
/// ```swift
/// class LoginCore: Core<LoginAction, LoginState> {
///     @Autowired private var service: LoginService
/// }
/// ```
@propertyWrapper
public class Autowired<T> {
    public let wrappedValue: T

    /// 초기화 시점에 ServiceLocator로부터 의존성을 해결합니다.
    public init() {
        self.wrappedValue = ServiceLocator.shared.resolve()
    }
}

/// 의존성 컨테이너를 관리하는 싱글톤 클래스입니다.
///
/// Swinject Container를 내부적으로 관리하며, 의존성 등록 및 해결을 담당합니다.
/// `ServiceLocator.shared`를 통해 전역적으로 접근합니다.
public final class ServiceLocator: Sendable {
    public static let shared = ServiceLocator()

    private let container: Container

    private init(container: Container = Container()) {
        self.container = container
    }
}

// MARK: Public
extension ServiceLocator {
    /// 여러 Assembly를 한 번에 등록합니다.
    ///
    /// 앱 시작 시 `AppDelegate`에서 모든 Assembly를 등록합니다.
    ///
    /// - Parameter assemblies: 등록할 Assembly 배열
    public func assemble(_ assemblies: [Assembly]) {
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }

    /// 단일 의존성을 등록합니다.
    ///
    /// - Parameters:
    ///   - serviceType: 등록할 서비스 타입
    ///   - object: 의존성을 생성하는 팩토리 클로저
    /// - Returns: 체이닝을 위한 `ServiceEntry` (예: `.inObjectScope(.container)`)
    @discardableResult
    public func register<T>(
        _ serviceType: T.Type,
        object: @escaping(Resolver) -> T
    ) -> ServiceEntry<T> {
        container.register(serviceType) {
            object($0)
        }
    }

    /// 등록된 의존성을 해결하여 반환합니다.
    public func resolve<T>() -> T {
        container.resolve(T.self)!
    }

    /// 등록된 의존성을 해결하여 반환합니다.
    ///
    /// - Parameter serviceType: 해결할 서비스 타입
    /// - Returns: 해결된 의존성 인스턴스
    public func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(T.self)!
    }
}
