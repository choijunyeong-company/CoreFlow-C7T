#if DEBUG
    enum FlowComponent: String, CaseIterable {
        case core, screen
    }

    struct ComponentKey: Hashable {
        private let objectId: ObjectIdentifier
        private let component: FlowComponent
        init(objectId: ObjectIdentifier, component: FlowComponent) {
            self.objectId = objectId
            self.component = component
        }
    }
#endif
