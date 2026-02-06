import Foundation

final class WeakValueTable: @unchecked Sendable {
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

struct WeakValue {
    weak var object: AnyObject?
    init(object: AnyObject) {
        self.object = object
    }
}


