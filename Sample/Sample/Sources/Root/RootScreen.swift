import CoreFlow
import UIKit

public final class RootScreen: UIViewController, @MainActor Screenable {
    public let reactor: AnyReactor<Action, State>

    init(reactor: any Reactable<Action, State>) {
        self.reactor = reactor.eraseToAnyReactor()
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

extension RootScreen {
    public typealias State = RootState
    public typealias Action = RootAction
}
