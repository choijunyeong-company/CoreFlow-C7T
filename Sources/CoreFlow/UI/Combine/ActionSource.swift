import Combine
import Foundation

@MainActor
public protocol ActionSource: AnyObject {
    associatedtype Action

    var action: AnyPublisher<Action, Never> { get }
    
    func send(_ action: Action)
    func map<P: Publisher>(_ publisher: P, to: Action) -> AnyPublisher<Action, Never> where P.Failure == Never
    func map<P: Publisher>(_ publisher: P, transform: @escaping (P.Output) -> Action) -> AnyPublisher<Action, Never> where P.Failure == Never
    
    func forward(actions: [AnyPublisher<Action, Never>])
}

extension ActionSource {
    private typealias HotSubject = PassthroughSubject<Action, Never>
    private typealias Key = ObjectIdentifier

    private var key: Key { Key(self) }

    private func associate(_ target: AnyObject, onDeinit: @escaping () -> Void) {
        var associateKey: UInt8 = 0
        objc_setAssociatedObject(
            self,
            &associateKey,
            DeinitDetector(target, onDeinit: onDeinit),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    // MARK: Action

    private var _action: HotSubject {
        if let obj: HotSubject = actionSubjectTable.get(key) {
            return obj
        }

        let refKey = key
        let subject = HotSubject()
        associate(subject) { actionSubjectTable.remove(refKey) }
        actionSubjectTable.set(refKey, value: subject)
        return subject
    }

    public var action: AnyPublisher<Action, Never> {
        _action.eraseToAnyPublisher()
    }

    public func send(_ action: Action) {
        _action.send(action)
    }

    // MARK: Store

    public var store: Set<AnyCancellable> {
        get { _store.object }
        set { _store.object = newValue }
    }

    private var _store: ObjectWrapper<Set<AnyCancellable>> {
        if let obj: ObjectWrapper<Set<AnyCancellable>> = storeTable.get(key) {
            return obj
        }

        let refKey = key
        let wrappedStore = ObjectWrapper(Set<AnyCancellable>())
        associate(wrappedStore) { storeTable.remove(refKey) }
        storeTable.set(refKey, value: wrappedStore)
        return wrappedStore
    }

    // MARK: Forward actions
    
    public func forward(actions: [AnyPublisher<Action, Never>]) {
        Publishers
            .MergeMany(actions)
            .weakRef(self)
            .sink { source, action in
                source.send(action)
            }
            .store(in: &store)
    }

    public func map<P: Publisher>(_ publisher: P, to action: Action) -> AnyPublisher<Action, Never> where P.Failure == Never {
        publisher
            .map { _ in action }
            .eraseToAnyPublisher()
    }

    public func map<P: Publisher>(_ publisher: P, transform: @escaping (P.Output) -> Action) -> AnyPublisher<Action, Never> where P.Failure == Never {
        publisher
            .map { transform($0) }
            .eraseToAnyPublisher()
    }
}

private let actionSubjectTable = WeakValueTable()
private let storeTable = WeakValueTable()
