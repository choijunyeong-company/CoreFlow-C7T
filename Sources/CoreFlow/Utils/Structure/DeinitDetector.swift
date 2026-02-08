final class DeinitDetector {
    private let onDeinit: () -> Void
    private let object: Any
    init(_ object: Any, onDeinit: @escaping () -> Void) {
        self.object = object
        self.onDeinit = onDeinit
    }
    deinit { onDeinit() }
}
