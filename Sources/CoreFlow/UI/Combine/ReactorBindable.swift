public protocol ReactorBindable: ActionSource {
    associatedtype State: Equatable
    
    func bind(reactor: any Reactable<Action, State>)
}
