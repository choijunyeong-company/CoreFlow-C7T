import UIKit

public typealias ActionView = SimpleInitUIView & ActionSource
public typealias ComponentView = SimpleInitUIView & ReactorBindable

public protocol ReactorBindable: ActionSource {
    associatedtype State: Equatable
    
    func bind(reactor: any Reactable<Action, State>)
}
