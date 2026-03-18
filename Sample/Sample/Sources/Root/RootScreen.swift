import CoreFlow
import UIKit

public final class RootScreen: UIViewController, Screenable {
    public let reactor: RootCore

    init(reactor: RootCore) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
}

extension RootScreen {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reactor.send(.viewDidLoad)
    }
}

extension RootScreen {
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = true
    }
}
