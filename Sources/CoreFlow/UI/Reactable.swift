import Combine

/// A type that reacts to actions and emits state changes.
///
/// This protocol defines the reactive behavior of a Core component.
/// It receives actions via `send(_:)` and publishes state changes
/// through a Combine publisher, enabling unidirectional data flow.
@MainActor
public protocol Reactable<Action, State>: AnyObject {
    associatedtype Action
    associatedtype State: Equatable

    var state: AnyPublisher<State, Never> { get }
    var currentState: State { get }
    
    func send(_ action: Action)
}

extension Reactable {
    public func scope<SubAction, SubState: Equatable>(
        state statePath: KeyPath<State, SubState>,
        transform: ((SubAction) -> Action)? = nil,
        
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubAction, SubState>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        } onCurrentState: { [weak self, initialState = currentState[keyPath: statePath]] in
            guard let self else { return initialState }
            
            return currentState[keyPath: statePath]
        }
    }
    
    public func scope<SubState: Equatable, SubAction>(
        state statePath: KeyPath<State, SubState?>,
        transform: ((SubAction) -> Action)? = nil
    ) -> any Reactable<SubAction, SubState?> {
        OptionalStateSubReactor<SubAction, SubState>(state: state.map(statePath)) { [weak self] subAction in
            guard let transform else { return }
            
            self?.send(transform(subAction))
        } onCurrentState: { [weak self, initialState = currentState[keyPath: statePath]] in
            guard let self else { return initialState }
            
            return currentState[keyPath: statePath]
        }
    }
}

// MARK: Type erase
extension Reactable {
    public func eraseToAnyReactor() -> AnyReactor<Action, State> {
        AnyReactor(origin: self)
    }
}

public final class AnyReactor<Action, State: Equatable>: Reactable {
    private let origin: Reactable<Action, State>
    public let state: AnyPublisher<State, Never>
    public var currentState: State { origin.currentState }
    
    init(origin: Reactable<Action, State>) {
        self.origin = origin
        self.state = origin.state
    }
    
    public func send(_ action: Action) {
        origin.send(action)
    }
}

// MARK: Preview

public final class PreviewReactor<Action, State: Equatable>: Reactable {
    private let initialState: State
    public let currentState: State
    public let state: AnyPublisher<State, Never>
    
    public init(initialState state: State) {
        self.initialState = state
        self.currentState = state
        self.state = CurrentValueSubject<State, Never>(state)
            .eraseToAnyPublisher()
    }
    
    public func send(_ action: Action) { print(action) }
}
