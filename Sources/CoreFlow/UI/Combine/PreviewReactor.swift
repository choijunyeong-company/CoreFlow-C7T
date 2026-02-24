import Combine

public final class PreviewReactor<State: Equatable, Action>: Reactable {
    private let initialState: State
    public let state: AnyPublisher<State, Never>
    public init(initialState state: State) {
        self.initialState = state
        self.state = CurrentValueSubject<State, Never>(state)
            .eraseToAnyPublisher()
    }
    public func send(_ action: Action) { print(action) }
}
