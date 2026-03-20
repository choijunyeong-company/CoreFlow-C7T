import CoreFlow
import Combine
import UIKit

final class MainScreen: UIViewController, @MainActor Screenable {
    private let titleLabel = UILabel()
    
    let reactor: MainCore
    
    init(reactor: MainCore) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    
    func bind() {
        observeDistinctState(\.userName) { [weak self] output in
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
