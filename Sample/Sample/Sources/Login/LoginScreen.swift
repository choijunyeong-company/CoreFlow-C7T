import Combine
import CoreFlow
import UIKit

final class LoginScreen: Screen<LoginCore> {
    private let loginSection = LoginSection()

    /// 상태 관찰과 액션 바인딩을 설정합니다.
    override func bind() {
        // Input
        
        
        loginSection.bind(
            reactor: reactor.compactScope(
                state: \.loginSectionState,
                transform: { .loginSection($0) }
            )
        )
        
        // Output
        forward(actions: [
            map(loginSection.action) { .loginSection($0) }
        ])
    }
}

extension LoginScreen {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reactor.send(.viewDidLoad)
    }
}

extension LoginScreen {
    private func setupUI() {
        view.backgroundColor = .systemBackground

        setupLoginSection()
    }

    private func setupLoginSection() {
        view.addSubview(loginSection)
        loginSection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loginSection.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginSection.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginSection.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            loginSection.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
        ])
    }
}
