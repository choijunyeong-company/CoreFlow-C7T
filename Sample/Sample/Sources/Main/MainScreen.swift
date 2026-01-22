import CoreFlow
import Combine
import UIKit

final class MainScreen: Screen<MainCore> {
    private let titleLabel = UILabel()
    
    override func bind() {
        observeState(\.userName) { [weak self] output in
            self?.titleLabel.text = "안녕하세요, \(output)"
        }
    }
}

extension MainScreen {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reactor.send(.viewDidLoad)
    }
}

extension MainScreen {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitle()
    }
    
    private func setupTitle() {
        titleLabel.text = "메인 화면"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
