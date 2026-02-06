import Combine
import CoreFlow
import UIKit

final class LoginScreen: Screen<LoginCore> {
    private let loginSection = LoginSection()
    private let loadingIndicator = UIActivityIndicatorView()

    /// 상태 관찰과 액션 바인딩을 설정합니다.
    override func bind() {
        // Input
        combineToSingleAction(
            map(loginSection.action) { .loginSection($0) }
        )
        
        // Output
        loginSection.listen(to: reactor.state.map(\.loginSectionState))
        
        observeDistinctState(\.isLoading) { [weak self] output in
            guard let self else { return }

            loadingIndicator.isHidden = !output
            if output {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
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
        setupLoadingIndicator()
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

    private func setupLoadingIndicator() {
        loadingIndicator.isHidden = true

        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
