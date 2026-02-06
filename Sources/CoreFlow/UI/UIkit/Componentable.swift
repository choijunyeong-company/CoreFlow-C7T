import Combine
import UIKit

public protocol Componentable: ActionSource {
    associatedtype State: Equatable
    
    func bind<R: Reactable>(_ reactor: R) -> Set<AnyCancellable>
}
