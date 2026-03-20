@MainActor
public protocol ReactorBindable: ActionSource {
    associatedtype State: Equatable
    
    func bind(reactor: any Reactable<Action, State>)
    func bind(reactor: any Reactable<Action, State?>)
}

extension ReactorBindable {
    public func bind(reactor: any Reactable<Action, State>) {}
    public func bind(reactor: any Reactable<Action, State?>) {}
}
