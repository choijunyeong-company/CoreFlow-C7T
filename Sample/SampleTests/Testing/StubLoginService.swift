@testable import Sample

struct StubLoginService: LoginService {
    func login() async -> User { User(name: "name") }
}
