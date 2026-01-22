import CoreFlow

/// Login 모듈의 의존성을 등록하는 Assembly입니다.
///
/// Swinject의 Assembly 프로토콜을 채택하여 의존성 등록을 모듈화합니다.
/// CoreFlow를 import하면 Assembly, Container 등 Swinject 타입을 직접 사용할 수 있습니다.
struct LoginProvider: Assembly {
    func assemble(container: Container) {
        /// LoginService 프로토콜을 LoginServiceImpl 구현체로 등록
        container.register(LoginService.self) { _ in
            LoginServiceImpl()
        }
    }
}
