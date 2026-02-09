import Combine

/// A class that declaratively defines a workflow spanning multiple CoreFlows.
///
/// Subclass `Procedure` and chain `onStep` and `finalStep` in `init()` to
/// compose the workflow. Core implements Step protocols to define each step's behavior.
///
/// ```swift
/// final class LaunchProcedure: Procedure<RootProcedureStep> {
///     override init() {
///         super.init()
///         onStep { step in step.waitForLogin() }
///         .finalStep { step, user in step.routeToMain(user: user) }
///     }
/// }
/// ```
@MainActor
open class Procedure<RootStep>: @unchecked Sendable {
    private let stepStreamSubject = PassthroughSubject<(RootStep, ()), Never>()
    fileprivate var workflowCancellable: AnyCancellable = .init {}
    fileprivate let completionHolder = CompletionHolder()

    public init() {}

    /// Override in subclasses to start the workflow.
    open func start() {
        preconditionFailure("must override this method")
    }

    /// Defines the first step.
    ///
    /// - Parameter onStep: A closure that takes RootStep and returns a Publisher containing the next Step and data.
    /// - Returns: A `ProcedureStep` that can chain to the next step.
    public final func onStep<NextStep, NextValue>(
        _ onStep: @escaping (RootStep) -> AnyPublisher<(NextStep, NextValue), Never>
    ) -> ProcedureStep<RootStep, NextStep, NextValue> {
        ProcedureStep(
            procedure: self,
            stream: stepStreamSubject.eraseToAnyPublisher()
        )
        .onStep { actionable, _ in
            onStep(actionable)
        }
    }

    /// Executes the workflow.
    ///
    /// Pass a Core that implements the RootStep protocol to start the workflow.
    /// Store the returned `AnyCancellable` to manage the workflow lifecycle.
    ///
    /// - Parameters:
    ///   - root: An object implementing the RootStep protocol (typically a Core).
    ///   - onProcedureFinish: A callback invoked when the workflow completes.
    /// - Returns: A Cancellable to cancel the workflow stream.
    @discardableResult
    public final func start(
        _ root: RootStep,
        onProcedureFinish onFinish: (() -> Void)? = nil
    ) -> Self {
        completionHolder.onFinish = onFinish
        stepStreamSubject.send((root, ()))
        return self
    }
    
    public final func cancel() {
        completionHolder.finish()
    }
}

extension Procedure {
    final class CompletionHolder {
        var streamCancellable: AnyCancellable?
        var onFinish: (() -> Void)?
        
        func finish() {
            streamCancellable?.cancel()
            streamCancellable = nil
            onFinish?()
        }
    }
}

/// Represents an individual step in the workflow.
///
/// Chain to the next step with `onStep`, or terminate the workflow with `finalStep`.
/// Uses Combine's `flatMap` to pass data between steps.
@MainActor
public final class ProcedureStep<RootStep, CurrentStep, Value> {
    private let procedure: Procedure<RootStep>
    private var stream: AnyPublisher<(CurrentStep, Value), Never>

    init(
        procedure: Procedure<RootStep>,
        stream: AnyPublisher<(CurrentStep, Value), Never>
    ) {
        self.procedure = procedure
        self.stream = stream
    }

    /// Defines the next step.
    ///
    /// - Parameter onStep: A closure that uses the current Step and received data to return the next Step Publisher.
    /// - Returns: A `ProcedureStep` that can chain to the next step.
    public func onStep<NextStep, NextValue>(
        _ onStep: @escaping (CurrentStep, Value) -> AnyPublisher<(NextStep, NextValue), Never>
    ) -> ProcedureStep<RootStep, NextStep, NextValue> {
        let layeredStream = stream
            .flatMap { actionable, value in
                onStep(actionable, value)
            }
            .eraseToAnyPublisher()

        return ProcedureStep<RootStep, NextStep, NextValue>(
            procedure: procedure,
            stream: layeredStream
        )
    }

    /// Defines the final step and completes the workflow.
    ///
    /// No further steps can be chained after calling this method.
    ///
    /// - Parameter onStep: A closure that performs the final action.
    public func finalStep(
        _ onStep: @escaping (CurrentStep, Value) -> Void
    ) {
        let holder = procedure.completionHolder
        procedure.completionHolder.streamCancellable = stream
            .map { [holder] actionable, value in
                onStep(actionable, value)
                holder.finish()
            }
            .sink(receiveValue: { _ in })
    }
}
