import Combine
import Foundation

/// 단방향 데이터 플로우를 관리하는 비즈니스 로직 컴포넌트입니다.
///
/// Core는 Screen으로부터 Action을 수신하고, 이를 처리하여 State를 변경합니다.
/// 상태 변경은 `reduce(state:action:)` 메서드에서 이루어지며,
/// 비동기 작업이 필요한 경우 `Effect`를 반환하여 파생 액션을 생성할 수 있습니다.
///
/// - Note: Core는 Flow에 의해 생성되고 관리됩니다.
@MainActor
open class Core<Action: Sendable, State>: Reactable, Activatable {
    private let initialState: State
    @Published public private(set) var currentState: State

    public var state: AnyPublisher<State, Never> {
        ensureStream()
        return $currentState.eraseToAnyPublisher()
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
        currentState = initialState
    }

    deinit {
        actionContinuation?.finish()
        exhaustionContinuations.values.forEach { $0.resume() }
    }

    /// 액션을 처리하고 상태를 변경하는 메서드입니다.
    ///
    /// 서브클래스에서 반드시 오버라이드하여 액션 처리 로직을 구현합니다.
    /// 상태 변경이 필요한 경우 `state` 파라미터를 직접 수정하고,
    /// 비동기 작업이 필요한 경우 `Effect.run`을 반환합니다.
    ///
    /// - Parameters:
    ///   - state: 현재 상태에 대한 참조. 직접 수정하여 상태를 변경합니다.
    ///   - action: 처리할 액션
    /// - Returns: 추가 작업이 필요한 경우 Effect, 그렇지 않으면 `.none`
    open func reduce(state _: inout State, action _: Action) -> Effect<Action> { .none }

    /// Flow가 Core를 생성한 직후 호출됩니다.
    open func didBecomeActive() {}

    /// Flow가 해제되기 직전 호출됩니다.
    open func willResignActive() {}

    /// 액션을 Core에 전송합니다.
    ///
    /// Screen이나 외부에서 이 메서드를 호출하여 액션을 전달합니다.
    /// 전달된 액션은 `reduce(state:action:)` 메서드에서 처리됩니다.
    ///
    /// - Parameter action: 전송할 액션
    public final func send(_ action: Action) {
        ensureStream()
        incrementInFlight(action)
        actionContinuation?.yield(action)
    }
}

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
        switch effect {
        case .none:
            decrementInFlight(effect)

        case let .run(priority, task):
            Task.detached(priority: priority) {
                await task { [weak self] mutation in
                    guard let self else { return }

                    send(mutation)
                }
                await MainActor.run { [weak self] in
                    guard let self else { return }

                    decrementInFlight(effect)
                }
            }
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

                    exhaustionContinuations[waitId]?.resume(throwing: TestError.timeout)
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

    private func decrementInFlight(_ effect: Effect<Action>) {
        guard isTestMode else { return }

        inFlightCount -= 1
        print("[Core] Effect.\(effect) is done")

        if inFlightCount == 0 {
            waitExhaustionTimers.values.forEach { $0.invalidate() }
            waitExhaustionTimers.removeAll()

            exhaustionContinuations.values.forEach { $0.resume() }
            exhaustionContinuations.removeAll()
        }
    }
}

/// 액션 처리 결과로 반환되는 사이드 이펙트입니다.
///
/// `reduce(state:action:)` 메서드에서 비동기 작업이 필요한 경우 사용합니다.
/// - `.none`: 추가 작업 없음
/// - `.run`: 비동기 작업 실행 후 파생 액션 전송
public enum Effect<Action: Sendable>: @unchecked Sendable {
    public typealias Send = @MainActor (Action) async -> Void
    public typealias RunTask = @MainActor @Sendable (Send) async -> Void

    /// 추가 작업이 필요 없음
    case none

    /// 비동기 작업을 실행하고, 완료 후 파생 액션을 전송
    case run(priority: TaskPriority? = nil, task: RunTask)
}

struct TestError: LocalizedError {
    let errorDescroption: String

    static let timeout: TestError = .init(errorDescroption: "[Core] waitForIdle timed out")
}
