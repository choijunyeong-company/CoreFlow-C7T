import UIKit

/// A coordinator component that manages the CoreFlow hierarchy.
///
/// Flow owns Core and Screen, and handles routing to child CoreFlows.
/// Implements routing protocols to manage screen transitions.
///
/// - Note: When Flow is deallocated, Core and Screen are also released.
///         LeakDetector will detect if they remain in memory after deallocation.
@MainActor
open class Flow<Core: Reactable & Activatable, Screen: Screenable>: Flowable {
    public private(set) lazy var core = {
        let core = createCore()
        core.didBecomeActive()
        #if DEBUG
            detactLeak(object: core, component: .core)
        #endif
        return core
    }()

    public private(set) lazy var screen = {
        let screen = createScreen()
        #if DEBUG
            detactLeak(object: screen, component: .screen)
        #endif
        return screen
    }()

    public init() {}

    @MainActor
    deinit {
        core.willResignActive()

        #if DEBUG
            let _objectId = objectId
            for component in FlowComponent.allCases {
                let key = ComponentKey(objectId: _objectId, component: component)
                LeakDetector.shared.checkMemoryLeak(key: key)
            }
        #endif
    }

    /// Creates a Core instance.
    ///
    /// Must be overridden in subclasses to create the Core
    /// and configure dependencies such as listener and router.
    open func createCore() -> Core {
        preconditionFailure("you must override this method")
    }

    /// Creates a Screen instance.
    ///
    /// Must be overridden in subclasses to create the Screen
    /// and call `bind()` to configure state binding.
    open func createScreen() -> Screen {
        preconditionFailure("you must override this method")
    }
}

#if DEBUG
    private extension Flow {
        private nonisolated var objectId: ObjectIdentifier { ObjectIdentifier(self) }
        private func detactLeak(object: any AnyObject, component: FlowComponent) {
            let key = ComponentKey(objectId: objectId, component: component)
            LeakDetector.shared.register(key: key, object: object)
        }
    }
#endif
