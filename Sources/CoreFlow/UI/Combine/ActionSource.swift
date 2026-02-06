import Combine
import Foundation

@MainActor
public protocol ActionSource: AnyObject {
    associatedtype Action
    associatedtype Failure: Error
    
    var action: AnyPublisher<Action, Failure> { get }
    func send(_ action: Action)
    func send(_ error: Failure)
}

public extension ActionSource {
    private typealias HotSubject = PassthroughSubject<Action, Failure>
    private typealias Key = ObjectIdentifier
    
    private var key: Key { Key(self) }
    
    private var _action: HotSubject {
        if let obj: HotSubject = objectTable.get(key) {
            return obj
        }
        
        let refKey = key
        let subject = HotSubject()
        let deinitDetactor = DeinitDetector(subject) {
            objectTable.remove(refKey)
        }
        associate(deinitDetactor)
        objectTable.set(refKey, value: subject)
        return subject
    }
    
    private func associate(_ target: AnyObject) {
        var associateKey: UInt8 = 0
        objc_setAssociatedObject(
            self,
            &associateKey,
            target,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
    
    var action: AnyPublisher<Action, Failure> {
        _action.eraseToAnyPublisher()
    }
    
    func send(_ action: Action) {
        _action.send(action)
    }

    func send(_ error: Failure) {
        _action.send(completion: .failure(error))
    }
}

private let objectTable = WeakValueTable()
