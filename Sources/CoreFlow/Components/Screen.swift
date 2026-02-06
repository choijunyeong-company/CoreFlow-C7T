import Combine
import UIKit

/// A UIViewController-based screen component.
///
/// Screen observes state from Core (Reactor) and converts UI events into actions.
/// Configure state observation and action binding in the `bind()` method.
@MainActor
open class Screen<Reactor: Reactable>: UIViewController, Screenable, ActionSource {
    public weak var reactor: Reactor!

    public typealias Action = Reactor.Action
    public typealias State = Reactor.State

    public init(reactor: Reactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    public required init?(coder _: NSCoder) { nil }

    /// Called during Screen initialization. Override in subclasses for initial setup.
    open func initialize() {}

    /// Configures state observation and action binding.
    ///
    /// Called after Screen creation in Flow's `createScreen()`.
    /// Use `observeState`, `observeDistinctState`, and `bind(onEmit:send:)` to
    /// implement state change observation and UI event-action binding.
    open func bind() {}
}

// MARK: Sending action to Reactor

public extension Screen {
    /// Sends an action directly to the Reactor (Core).
    final func send(_ action: Action) {
        reactor.send(action)
    }

    /// Converts publisher events into actions and sends them to the Reactor.
    ///
    /// - Parameters:
    ///   - pubisher: A publisher that emits UI events.
    ///   - transform: A closure that converts the publisher output into an action.
    final func bind<P: Publisher>(
        onEmit pubisher: () -> P,
        send transform: @escaping (P.Output) -> Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        bind(onEmit: pubisher(), send: transform, onComplete, onFailure)
    }

    final func bind<P: Publisher>(
        onEmit pubisher: P,
        send transform: @escaping (P.Output) -> Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        pubisher
            .map(transform)
            .sink { completion in
                switch completion {
                case .finished: onComplete?()
                case let .failure(error): onFailure?(error)
                }
            } receiveValue: { [weak reactor] action in
                reactor?.send(action)
            }
            .store(in: &store)
    }

    final func bind<P: Publisher>(
        onEmit publisher: () -> P,
        send action: Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        bind(onEmit: publisher(), send: action, onComplete, onFailure)
    }

    final func bind<P: Publisher>(
        onEmit publisher: P,
        send action: Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        publisher
            .map { _ in action }
            .sink { completion in
                switch completion {
                case .finished: onComplete?()
                case let .failure(error): onFailure?(error)
                }
            } receiveValue: { [weak reactor] action in
                reactor?.send(action)
            }
            .store(in: &store)
    }
}

// MARK: Observe Reactor's state

public extension Screen {
    /// Observes a specific state property with transformation.
    final func observeState<T>(
        _ keyPath: KeyPath<State, T>,
        transform: @escaping (T) -> AnyPublisher<T, Never>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .eraseToAnyPublisher()
            .flatMap(transform)
            .sink(receiveValue: sink)
            .store(in: &store)
    }

    final func observeState<T>(
        _ keyPath: KeyPath<State, T>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .sink(receiveValue: sink)
            .store(in: &store)
    }

    /// Observes a specific state property and only processes when the value changes.
    ///
    /// Automatically filters duplicate values for `Equatable` properties.
    /// Useful for preventing unnecessary UI re-renders.
    final func observeDistinctState<T: Equatable>(
        _ keyPath: KeyPath<State, T>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .removeDuplicates()
            .sink(receiveValue: sink)
            .store(in: &store)
    }
    
    func forward<Substate, Listener: StateListener<Substate>>(state keyPath: KeyPath<State, Substate>, to listener: Listener) {
        listener.listen(to: reactor.state.map(keyPath))
    }
}
