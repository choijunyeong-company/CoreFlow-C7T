import Combine

final class SubReactor<Action, State: Equatable>: Reactable {
    let state: AnyPublisher<State, Never>
    var currentState: State { onCurrentState() }
    
    private let onAction: (Action) -> Void
    private let onCurrentState: () -> State
    
    init<P: Publisher<State, Never>>(
        state: P,
        onAction: @escaping (Action) -> Void,
        onCurrentState: @escaping () -> State
    ) {
        self.state = state.eraseToAnyPublisher()
        self.onAction = onAction
        self.onCurrentState = onCurrentState
    }
    func send(_ action: Action) { onAction(action) }
}

final class OptionalStateSubReactor<Action, State: Equatable>: Reactable {
    let state: AnyPublisher<State?, Never>
    var currentState: State? { onCurrentState() }
    
    private let onAction: (Action) -> Void
    private let onCurrentState: () -> State?
    
    init<P: Publisher<State?, Never>>(
        state: P,
        onAction: @escaping (Action) -> Void,
        onCurrentState: @escaping () -> State?
    ) {
        self.state = state.eraseToAnyPublisher()
        self.onAction = onAction
        self.onCurrentState = onCurrentState
    }
    func send(_ action: Action) { onAction(action) }
}
