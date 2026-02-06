import CoreFlow
import Combine
import UIKit

final class LoginSection: ComponentView {
    enum Action {
        case loginButtonTapped
    }

    struct State: Equatable {
        var loginButtonTitleText: String = ""
        var isLoading: Bool = false
    }

    private let descriptionLabel = UILabel()
    private let loginButton = UIButton()

    override func initialize() {
        setupUI()
        combineToSingleAction(
            map(loginButton.touchUpInside, to: .loginButtonTapped)
        )
    }
    
    func listen<P>(to publisher: P) where P : Publisher<State, Never> {
        publisher
            .map(\.loginButtonTitleText)
            .sink { [descriptionLabel] text in
                descriptionLabel.text = text
            }
            .store(in: &store)
        
        publisher
            .map(\.isLoading)
            .sink { [loginButton] isLoading in
                loginButton.isUserInteractionEnabled = !isLoading
            }
            .store(in: &store)
    }
}

extension LoginSection {
    private func setupUI() {
        setupDescriptionLabel()
        setupLoginButton()
    }

    private func setupDescriptionLabel() {
        descriptionLabel.textColor = .orange
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func setupLoginButton() {
        loginButton.setTitle("로그인", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.setTitleColor(.lightGray, for: .highlighted)

        addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
