protocol LoginService {
    func login() async -> User
}

struct LoginServiceImpl: LoginService {
    func login() async -> User {
        try? await Task.sleep(for: .seconds(3))
        return User(name: "Junios")
    }
}
