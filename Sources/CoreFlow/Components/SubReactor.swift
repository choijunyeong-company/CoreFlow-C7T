import Combine

final class SubReactor<State: Equatable, Action>: Reactable {
    let state: AnyPublisher<State, Never>
    private let onAction: (Action) -> Void
    
    init<P: Publisher<State, Never>>(state: P, onAction: @escaping (Action) -> Void) {
        self.state = state.eraseToAnyPublisher()
        self.onAction = onAction
    }
    func send(_ action: Action) { onAction(action) }
}

final class OptionalStateSubReactor<State: Equatable, Action>: Reactable {
    let state: AnyPublisher<State?, Never>
    private let onAction: (Action) -> Void
    
    init<P: Publisher<State?, Never>>(state: P, onAction: @escaping (Action) -> Void) {
        self.state = state.eraseToAnyPublisher()
        self.onAction = onAction
    }
    func send(_ action: Action) { onAction(action) }
}
