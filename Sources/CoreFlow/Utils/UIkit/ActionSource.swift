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

private let objectTable = Table()

private final class Table: @unchecked Sendable {
    typealias Key = ObjectIdentifier
    private var dictionary: [Key: WeakValue] = [:]
    private let lock = NSLock()
    
    func set(_ key: Key, value: AnyObject) {
        defer { lock.unlock() }
        lock.lock()
        
        dictionary[key] = WeakValue(object: value)
    }
    
    func get<T: AnyObject>(_ key: Key) -> T? {
        defer { lock.unlock() }
        lock.lock()
        
        return dictionary[key]?.object as? T
    }
    
    func remove(_ key: Key) {
        defer { lock.unlock() }
        lock.lock()
        
        dictionary.removeValue(forKey: key)
    }
}

private struct WeakValue {
    weak var object: AnyObject?
    init(object: AnyObject) {
        self.object = object
    }
}

private final class DeinitDetector {
    private let onDeinit: () -> Void
    private let object: AnyObject
    init(_ object: AnyObject, onDeinit: @escaping () -> Void) {
        self.object = object
        self.onDeinit = onDeinit
    }
    deinit { onDeinit() }
}
