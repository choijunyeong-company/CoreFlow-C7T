//___FILEHEADER___

import Combine
import CoreFlow
import UIKit

public final class ___VARIABLE_productName___Screen: UIViewController, @MainActor Screenable {
    let reactor: AnyReactor<___VARIABLE_productName___Action, ___VARIABLE_productName___State>

    init(reactor: any Reactable<Action, State>) {
        self.reactor = reactor.eraseToAnyReactor()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }

    public func bind() {
        // Bindings between UI and Reactor go here.
    }
}

extension ___VARIABLE_productName___Screen {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reactor.send(.viewDidLoad)
    }
}

extension ___VARIABLE_productName___Screen {
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
}

extension ___VARIABLE_productName___Screen {
    typealias Action = ___VARIABLE_productName___Action
    typealias State = ___VARIABLE_productName___State
}