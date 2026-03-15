@testable import Sample

struct StubLoginService: LoginService {
    private let user: User
    init(user: User) {
        self.user = user
    }
    func login() async -> User { user }
}
