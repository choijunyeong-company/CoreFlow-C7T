import Combine

/// A type that reacts to actions and emits state changes.
///
/// This protocol defines the reactive behavior of a Core component.
/// It receives actions via `send(_:)` and publishes state changes
/// through a Combine publisher, enabling unidirectional data flow.
@MainActor
public protocol Reactable<Action, State>: AnyObject {
    associatedtype Action: Sendable
    associatedtype State: Equatable

    var state: AnyPublisher<State, Never> { get }
    func send(_ action: Action)
}

extension Reactable {
    public func scope<SubState: Equatable, SubAction>(
        state statePath: KeyPath<State, SubState>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubState, SubAction>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        }
    }
    
    public func scope<SubState: Equatable, SubAction>(
        state statePath: KeyPath<State, SubState?>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState?> {
        OptionalStateSubReactor<SubState, SubAction>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        }
    }
    
    public func compactScope<SubState: Equatable, SubAction>(
        state statePath: KeyPath<State, SubState?>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubState, SubAction>(state: state.map(statePath).compactMap(\.self)) { [weak self] subAction in
            guard let transform else { return }

            self?.send(transform(subAction))
        }
    }

    public func compact<Wrapped: Equatable>() -> any Reactable<Action, Wrapped> where State == Wrapped? {
        SubReactor<Wrapped, Action>(
            state: state.compactMap { $0 }.eraseToAnyPublisher()
        ) { [weak self] action in
            self?.send(action)
        }
    }
}
