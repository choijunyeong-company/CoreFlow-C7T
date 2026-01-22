import CoreFlow
import UIKit

public final class RootScreen: Screen<RootCore> {}

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
