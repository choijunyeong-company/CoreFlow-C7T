import Combine
import UIKit

struct UIControlEventPublisher<Control: AnyObject>: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let uiControl: Control
    private let addTarget: (Control, AnyObject, Selector) -> Void
    private let removeTarget: (Control?, AnyObject, Selector) -> Void

    init(
        uiControl: Control,
        addTarget: @escaping (Control, AnyObject, Selector) -> Void,
        removeTarget: @escaping (Control?, AnyObject, Selector) -> Void
    ) {
        self.uiControl = uiControl
        self.addTarget = addTarget
        self.removeTarget = removeTarget
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UIControlEventSubscription(
            uiControl: uiControl,
            subscriber: subscriber,
            addTarget: addTarget,
            removeTarget: removeTarget
        )
        subscriber.receive(subscription: subscription)
    }
}

final class UIControlEventSubscription<S: Subscriber, Control: AnyObject>: Subscription where S.Input == Void {
    private weak var uiControl: Control?
    private var subscriber: S?
    private var removeTarget: (Control?, AnyObject, Selector) -> Void

    private let action = #selector(handleAction)
    private var demand: Subscribers.Demand = .none

    init(
        uiControl: Control,
        subscriber: S,
        addTarget: @escaping (Control, AnyObject, Selector) -> Void,
        removeTarget: @escaping (Control?, AnyObject, Selector) -> Void
    ) {
        self.uiControl = uiControl
        self.subscriber = subscriber
        self.removeTarget = removeTarget

        addTarget(uiControl, self, action)
    }

    func cancel() {
        subscriber = nil
        removeTarget(uiControl, self, action)
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
    }
    
    @objc
    private func handleAction() {
        guard demand > .none else { return }
        
        demand -= .max(1)
        demand += (subscriber?.receive() ?? .none)
    }
}
