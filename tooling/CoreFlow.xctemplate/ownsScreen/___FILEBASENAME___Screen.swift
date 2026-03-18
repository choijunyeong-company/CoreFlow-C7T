//___FILEHEADER___

import CoreFlow
import UIKit

public final class ___VARIABLE_productName___Screen: UIViewController, Screenable {
    public let reactor: ___VARIABLE_productName___Core

    init(reactor: ___VARIABLE_productName___Core) {
        self.reactor = reactor
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
