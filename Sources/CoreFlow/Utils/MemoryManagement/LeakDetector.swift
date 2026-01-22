#if DEBUG
    import Foundation

    @MainActor
    final class LeakDetector {
        static let shared = LeakDetector()

        private init() {}

        private var dict: [ComponentKey: WeakRef] = [:]

        func register(key: ComponentKey, object: some AnyObject) {
            dict[key] = WeakRef(object: object)
        }

        func checkMemoryLeak(key: ComponentKey) {
            guard let weakRef = dict[key] else { return }

            dict.removeValue(forKey: key)
            Executor.execute { [weakRef] in
                if let object = weakRef.object {
                    assertionFailure("🚨 Memory Leak: \(type(of: object))")
                }
            }
        }

        private nonisolated struct WeakRef: @unchecked Sendable {
            weak var object: (any AnyObject)?
        }
    }

    private enum Executor {
        final nonisolated class Context: @unchecked Sendable {
            var lastTime: TimeInterval = 0.0
            var properFrameTime: TimeInterval = 0.0
        }

        static func execute(
            delay: TimeInterval = 1.0,
            onTime: @Sendable @escaping () -> Void
        ) {
            let maxFrameDuration = Double(33.0 / 1000.0) // 33ms
            let interval = TimeInterval(maxFrameDuration / 3.0)
            let context = Context()
            context.lastTime = Date().timeIntervalSinceReferenceDate

            Timer.scheduledTimer(
                withTimeInterval: interval,
                repeats: true
            ) { timer in
                let currentTime = Date().timeIntervalSinceReferenceDate
                let trueElapsedTime = currentTime - context.lastTime
                context.lastTime = currentTime

                let boundedElapsedTime = min(trueElapsedTime, maxFrameDuration)
                context.properFrameTime += boundedElapsedTime

                if timer.isValid, context.properFrameTime >= delay {
                    onTime()
                    timer.invalidate()
                }
            }
        }
    }
#endif
