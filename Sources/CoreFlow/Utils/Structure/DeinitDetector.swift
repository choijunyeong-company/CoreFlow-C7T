final class DeinitDetector {
    private let onDeinit: () -> Void
    private let object: AnyObject
    init(_ object: AnyObject, onDeinit: @escaping () -> Void) {
        self.object = object
        self.onDeinit = onDeinit
    }
    deinit { onDeinit() }
}
