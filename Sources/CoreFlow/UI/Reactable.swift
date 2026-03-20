import Combine

/// A type that reacts to actions and emits state changes.
///
/// This protocol defines the reactive behavior of a Core component.
/// It receives actions via `send(_:)` and publishes state changes
/// through a Combine publisher, enabling unidirectional data flow.
@MainActor
public protocol Reactable<Action, State>: AnyObject {
    associatedtype Action
    associatedtype State

    var state: AnyPublisher<State, Never> { get }
    func send(_ action: Action)
}

extension Reactable {
    public func scope<SubState, SubAction>(
        state statePath: KeyPath<State, SubState>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubAction, SubState>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        }
    }
    
    public func scope<SubState, SubAction>(
        state statePath: KeyPath<State, SubState?>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState?> {
        OptionalStateSubReactor<SubAction, SubState>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        }
    }
    
    public func compactScope<SubState, SubAction>(
        state statePath: KeyPath<State, SubState?>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubAction, SubState>(state: state.map(statePath).compactMap(\.self)) { [weak self] subAction in
            guard let transform else { return }

            self?.send(transform(subAction))
        }
    }

    public func compact<Wrapped>() -> any Reactable<Action, Wrapped> where State == Wrapped? {
        SubReactor<Action, Wrapped>(
            state: state.compactMap { $0 }.eraseToAnyPublisher()
        ) { [weak self] action in
            self?.send(action)
        }
    }
}
