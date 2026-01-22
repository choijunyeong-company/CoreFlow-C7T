import UIKit

@MainActor
open class ScreenLessFlow<Core: Activatable>: Flowable {
    public typealias Screen = UIViewController

    public private(set) lazy var core = {
        let core = createCore()
        core.didBecomeActive()
        #if DEBUG
            let key = ComponentKey(objectId: objectId, component: .core)
            LeakDetector.shared.register(key: key, object: core)
        #endif
        return core
    }()

    #if DEBUG
        private nonisolated var objectId: ObjectIdentifier { ObjectIdentifier(self) }
    #endif

    public init() {}

    @MainActor
    deinit {
        core.willResignActive()

        #if DEBUG
            let _objectId = objectId
            Task(priority: .utility) { @MainActor in
                let key = ComponentKey(objectId: _objectId, component: .core)
                LeakDetector.shared.checkMemoryLeak(key: key)
            }
        #endif
    }

    public var screen: Screen {
        preconditionFailure("This flow does not present a screen")
    }

    open func createCore() -> Core {
        preconditionFailure("you must override this method")
    }
}
