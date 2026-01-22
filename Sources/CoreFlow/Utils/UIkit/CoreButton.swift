import Combine
import UIKit

public final class CoreButton: UIView {
    private var labelView: UIView?
    private var view: UIView { self }

    private var onTouchBegan: (() -> Void)?
    private var onTouchEnd: (() -> Void)?

    private let _onTap: PassthroughSubject<Void, Never> = .init()
    public var onTap: AnyPublisher<Void, Never> { _onTap.eraseToAnyPublisher() }

    public convenience init(label: () -> UIView) {
        self.init(label: label())
    }

    public init(label: UIView? = nil) {
        super.init(frame: .zero)
        setup()
        attachLabel(label)
    }

    required init?(coder _: NSCoder) { nil }

    override public func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        if let onTouchBegan { return onTouchBegan() }

        labelView?.alpha = 0.5
    }

    override public func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        _onTap.send(())

        if let onTouchEnd { return onTouchEnd() }

        UIView.animate(withDuration: 0.35) {
            self.labelView?.alpha = 1
        }
    }
}

// MARK: Pulblic method

public extension CoreButton {
    func attachLabel(_ label: UIView?) {
        dettachLabelView()

        guard let label else { return }

        labelView = label
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: Private method

extension CoreButton {
    private func setup() {
        view.backgroundColor = .clear
    }

    private func dettachLabelView() {
        labelView?.removeFromSuperview()
        labelView = nil
    }
}
