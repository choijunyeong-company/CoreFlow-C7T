import UIKit

// MARK: UIView

open class SimpleInitUIView: UIView {
    public init() {
        super.init(frame: .zero)
        initialize()
    }
    public required init?(coder: NSCoder) { nil }
    
    open func initialize() {}
}
