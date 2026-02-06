import Combine
import UIKit

struct UIControlEventPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    private let uiControl: Control
    private let event: UIControl.Event

    init(uiControl: Control, event: UIControl.Event) {
        self.uiControl = uiControl
        self.event = event
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UIControlEventSubscription(
            uiControl: uiControl,
            event: event,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

final class UIControlEventSubscription<S: Subscriber, Control: UIControl>: Subscription, @unchecked Sendable where S.Input == Control {
    private weak var uiControl: Control?
    private var subscriber: S?
    private let event: UIControl.Event

    private let action = #selector(handleAction(_:))
    private var demand: Subscribers.Demand = .none

    init(uiControl: Control, event: UIControl.Event, subscriber: S) {
        self.uiControl = uiControl
        self.event = event
        self.subscriber = subscriber

        uiControl.addTarget(self, action: action, for: event)
    }

    func cancel() {
        subscriber = nil
        uiControl?.removeTarget(self, action: action, for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
    }
    
    @objc
    private func handleAction(_ control: UIControl) {
        guard demand > .none else { return }
        
        demand -= .max(1)
        
        guard let typed = control as? Control else {
            assertionFailure("control type casting failed")
            return
        }
        
        demand += (subscriber?.receive(typed) ?? .none)
    }
}
