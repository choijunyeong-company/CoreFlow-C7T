public protocol ReactorBindable: ActionSource {
    associatedtype State: Equatable
    
    func bind(reactor: any Reactable<Action, State>)
    func bind(reactor: any Reactable<Action, State?>)
}

public extension ReactorBindable {
    func bind(reactor: any Reactable<Action, State>) {
        assertionFailure("not implemented.")
    }
    func bind(reactor: any Reactable<Action, State?>) {
        assertionFailure("not implemented.")
    }
}
