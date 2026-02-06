import CoreFlow
import UIKit

public final class LoginScreen: Screen<LoginCore> {
    private let loginButton = LoginButton()
    private let loadingIndicator = UIActivityIndicatorView()

    /// 상태 관찰과 액션 바인딩을 설정합니다.
    public override func bind() {
        observeDistinctState(\.isLoading) { [weak self] output in
            guard let self else { return }
            
            loadingIndicator.isHidden = !output
            if output {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            
            loginButton.isUserInteractionEnabled = !output
        }
        
        bind(
            onEmit: loginButton.touchUpInside,
            send: .loginButtonTapped
        )
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
        
        setupLoginButton()
        setupLoadingIndicator()
    }
    
    private func setupLoginButton() {
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
