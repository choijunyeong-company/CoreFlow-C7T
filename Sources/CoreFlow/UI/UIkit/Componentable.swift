import Combine
import UIKit

public protocol Componentable: ActionSource {
    associatedtype State: Equatable
    
    func listen<P>(to publisher: P) where P : Publisher<State, Never>
}
