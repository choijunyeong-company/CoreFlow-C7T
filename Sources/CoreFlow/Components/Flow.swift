import UIKit

/// CoreFlow 계층을 관리하는 코디네이터 컴포넌트입니다.
///
/// Flow는 Core와 Screen을 소유하고, 하위 CoreFlow로의 라우팅을 담당합니다.
/// Routing 프로토콜을 구현하여 화면 전환 로직을 처리합니다.
///
/// - Note: Flow가 해제되면 Core와 Screen도 함께 해제됩니다.
///         해제 후에도 메모리에 남아있으면 LeakDetector가 감지합니다.
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

    /// Core 인스턴스를 생성합니다.
    ///
    /// 서브클래스에서 반드시 오버라이드하여 Core를 생성하고,
    /// listener, router 등 필요한 의존성을 설정합니다.
    open func createCore() -> Core {
        preconditionFailure("you must override this method")
    }

    /// Screen 인스턴스를 생성합니다.
    ///
    /// 서브클래스에서 반드시 오버라이드하여 Screen을 생성하고,
    /// `bind()` 메서드를 호출하여 상태 바인딩을 설정합니다.
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
