import Combine
import UIKit

public struct SinkAnimation: Sendable {
    public let duration: TimeInterval
    public let delay: TimeInterval
    public let options: UIView.AnimationOptions

    public init(
        duration: TimeInterval = 0.35,
        delay: TimeInterval = 0.0,
        options: UIView.AnimationOptions = []
    ) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }

    public static let `default` = SinkAnimation()
}

public extension Publisher where Failure == Never, Output: Sendable {
    func sink(
        withAnimation animation: SinkAnimation = .default,
        animationTask: @Sendable @escaping @MainActor (Output) -> Void,
        otherTask: ((Output) -> Void)? = nil
    ) -> AnyCancellable {
        sink { output in
            Task(priority: .userInitiated) { @MainActor in
                UIView
                    .animate(
                        withDuration: animation.duration,
                        delay: animation.delay,
                        options: animation.options
                    ) { animationTask(output) }
            }
            otherTask?(output)
        }
    }
}
