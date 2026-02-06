import Combine

public protocol StateListener<State> {
    associatedtype State: Equatable
    
    func listen<P: Publisher<State, Never>>(to state: P)
}
