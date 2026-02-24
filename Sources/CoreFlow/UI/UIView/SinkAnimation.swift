import Combine
import UIKit

public struct SinkAnimation: Sendable {
    let duration: TimeInterval
    let delay: TimeInterval
    let options: UIView.AnimationOptions
    
    public init(
        duration: TimeInterval = 0.35,
        delay: TimeInterval = 0.0,
        options: UIView.AnimationOptions = []
    ) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }
}

public extension Publisher where Failure == Never, Output: Sendable {
    func sink(_ animation: SinkAnimation, receiveValue: @Sendable @escaping (Output) -> Void) -> AnyCancellable {
        sink { output in
            Task(priority: .userInitiated) { @MainActor in
                UIView
                    .animate(
                        withDuration: animation.duration,
                        delay: animation.delay,
                        options: animation.options
                    ) { receiveValue(output) }
            }
        }
    }
}
