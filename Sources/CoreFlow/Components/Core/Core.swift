import Combine
import Foundation

/// A business logic component that manages unidirectional data flow.
///
/// Core receives Actions from Screen, processes them, and updates State.
/// State changes occur in the `reduce(state:action:)` method.
/// For asynchronous operations, return an `Effect` to generate derived actions.
///
/// - Note: Core is created and managed by Flow.
@MainActor
open class Core<Action: Sendable, State: Equatable>: Reactable, Activatable {
    private let initialState: State
    
    public private(set) var currentState: State {
        didSet { _state.send(currentState) }
    }
    private let _state: CurrentValueSubject<State, Never>
    public var state: AnyPublisher<State, Never> {
        ensureStream()
        return _state.eraseToAnyPublisher()
    }

    private var actionStream: AsyncStream<Action>?
    private var actionContinuation: AsyncStream<Action>.Continuation?

    public var store = Set<AnyCancellable>()

    // Test mode
    private var isTestMode: Bool = false
    private var inFlightCount: Int = 0
    private var exhaustionContinuations: [UUID: CheckedContinuation<Void, Error>] = [:]
    private var waitExhaustionTimers: [UUID: Timer] = [:]

    public init(initialState: State) {
        self.initialState = initialState
        self._state = CurrentValueSubject(initialState)
        currentState = initialState
    }

    deinit {
        actionContinuation?.finish()
        exhaustionContinuations.values.forEach { $0.resume() }
    }

    /// Processes an action and updates the state.
    ///
    /// Must be overridden in subclasses to implement action handling logic.
    /// Mutate the `state` parameter directly for state changes,
    /// and return `Effect.run` for asynchronous operations.
    ///
    /// - Parameters:
    ///   - state: A reference to the current state. Mutate directly to change state.
    ///   - action: The action to process.
    /// - Returns: An `Effect` for additional work, or `.none`.
    open func reduce(state _: inout State, action _: Action) -> Effect<Action> { .none }

    /// Called immediately after Flow creates the Core.
    open func didBecomeActive() {}

    /// Called just before Flow is deallocated.
    open func willResignActive() {}

    /// Sends an action to the Core.
    ///
    /// Called from Screen or externally to deliver an action.
    /// The action is processed in `reduce(state:action:)`.
    ///
    /// - Parameter action: The action to send.
    public final func send(_ action: Action) {
        ensureStream()
        incrementInFlight(action)
        actionContinuation?.yield(action)
    }
}

// MARK: State stream

extension Core {
    private func ensureStream() {
        guard actionStream == nil else { return }

        let (steam, continuation) = AsyncStream<Action>.makeStream()
        actionStream = steam
        actionContinuation = continuation

        Task(priority: .userInitiated) { [weak self] in
            for await action in steam {
                guard let self else { return }

                let effect = reduce(state: &currentState, action: action)
                handle(effect)
            }
        }
    }

    private func handle(_ effect: Effect<Action>) {
        let description = effect.description
        switch effect {
        case .none:
            decrementInFlight(description)

        case let .run(priority, task):
            Task.detached(priority: priority) {
                await task { [weak self] mutation in
                    guard let self else { return }

                    send(mutation)
                }
                await MainActor.run { [weak self] in
                    guard let self else { return }

                    decrementInFlight(description)
                }
            }
            
        case .send(let action):
            send(action)
            decrementInFlight(description)
        }
    }
}

// MARK: Test mode

extension Core {
    public final func enableTestMode() {
        isTestMode = true
    }

    public final func exhaust(timeout seconds: TimeInterval = 10.0) async throws {
        guard seconds >= 0.0 else {
            preconditionFailure("[Core] waitForIdle: seconds must be non-negative")
        }

        guard isTestMode else {
            preconditionFailure("[Core] call enableTestMode() first")
        }

        guard inFlightCount > 0 else {
            preconditionFailure("[Core] nothing to wait for, no tasks in flight")
        }

        let waitId = UUID()

        try await withCheckedThrowingContinuation { continuation in
            exhaustionContinuations[waitId] = continuation

            waitExhaustionTimers[waitId] = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { _ in
                Task(priority: .background) { @MainActor [weak self] in
                    guard let self else { return }

                    exhaustionContinuations[waitId]?.resume(throwing: CoreTestError.timeout)
                    exhaustionContinuations.removeValue(forKey: waitId)
                }
            })
        }

        waitExhaustionTimers[waitId]?.invalidate()
        waitExhaustionTimers.removeValue(forKey: waitId)
    }

    private func incrementInFlight(_ action: Action) {
        guard isTestMode else { return }

        inFlightCount += 1
        print("[Core] Action.\(action) is in flight")
    }

    private func decrementInFlight(_ effectMessage: String) {
        guard isTestMode else { return }

        inFlightCount -= 1
        print("[Core] Effect.\(effectMessage) is done")

        if inFlightCount == 0 {
            waitExhaustionTimers.values.forEach { $0.invalidate() }
            waitExhaustionTimers.removeAll()

            exhaustionContinuations.values.forEach { $0.resume() }
            exhaustionContinuations.removeAll()
        }
    }
}

struct CoreTestError: LocalizedError {
    let errorDescroption: String

    static let timeout: CoreTestError = .init(errorDescroption: "[Core] waitForIdle timed out")
}
