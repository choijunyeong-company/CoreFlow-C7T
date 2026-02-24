import Combine
import UIKit

struct GestureRecognizerPublisher<Recognizer: UIGestureRecognizer>: Publisher {
    typealias Output = Recognizer
    typealias Failure = Never

    private let recognizer: Recognizer

    init(recognizer: Recognizer) {
        self.recognizer = recognizer
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = GestureRecognizerSubscription(
            recognizer: recognizer,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

final class GestureRecognizerSubscription<S: Subscriber, Recognizer: UIGestureRecognizer>: Subscription, @unchecked Sendable where S.Input == Recognizer {
    private weak var recognizer: Recognizer?
    private var subscriber: S?

    private let action = #selector(handleAction(_:))
    private var demand: Subscribers.Demand = .none

    init(recognizer: Recognizer, subscriber: S) {
        self.recognizer = recognizer
        self.subscriber = subscriber

        recognizer.addTarget(self, action: action)
    }

    func cancel() {
        subscriber = nil
        recognizer?.removeTarget(self, action: action)
    }

    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
    }

    @objc
    private func handleAction(_ recognizer: UIGestureRecognizer) {
        guard demand > .none else { return }

        demand -= .max(1)

        guard let typed = recognizer as? Recognizer else {
            assertionFailure("recognizer type casting failed")
            return
        }

        demand += (subscriber?.receive(typed) ?? .none)
    }
}
