import Combine

public protocol StateListener {
    associatedtype State: Equatable
    
    func listen<P: Publisher<State, Never>>(to state: P)
}
