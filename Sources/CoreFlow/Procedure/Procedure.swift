import Combine

/// 여러 CoreFlow를 거치는 워크플로우를 선언적으로 정의하는 클래스입니다.
///
/// `Procedure`를 상속하여 `init()`에서 `onStep`과 `finalStep`을 체이닝하여
/// 워크플로우를 구성합니다. Core가 Step 프로토콜을 구현하여 각 단계의 동작을 정의합니다.
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

    /// 서브클래스에서 오버라이드하여 워크플로우를 시작합니다.
    open func start() {
        preconditionFailure("must override this method")
    }

    /// 첫 번째 Step을 정의합니다.
    ///
    /// - Parameter onStep: RootStep을 받아 다음 Step과 전달 데이터를 포함한 Publisher를 반환하는 클로저
    /// - Returns: 다음 Step을 체이닝할 수 있는 `ProcedureStep`
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

    /// 워크플로우를 실행합니다.
    ///
    /// RootStep 프로토콜을 구현한 Core를 전달하여 워크플로우를 시작합니다.
    /// 반환된 `AnyCancellable`을 저장하여 워크플로우 생명주기를 관리합니다.
    ///
    /// - Parameters:
    ///   - root: RootStep 프로토콜을 구현한 객체 (일반적으로 Core)
    ///   - onProcedureFinish: 워크플로우 완료 시 호출되는 콜백
    /// - Returns: 워크플로우 생명주기를 관리하는 `AnyCancellable`
    @discardableResult
    public final func start(
        _ root: RootStep,
        onProcedureFinish onFinish: (() -> Void)? = nil
    ) -> AnyCancellable {
        completionHolder.onFinish = onFinish
        stepStreamSubject.send((root, ()))
        return workflowCancellable
    }
}

extension Procedure {
    final class CompletionHolder {
        var onFinish: (() -> Void)?
    }
}

/// 워크플로우의 개별 단계를 나타내는 클래스입니다.
///
/// `onStep`으로 다음 Step을 체이닝하거나, `finalStep`으로 워크플로우를 종료합니다.
/// Combine의 `flatMap`을 사용하여 Step 간 데이터 전달을 구현합니다.
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

    /// 다음 Step을 정의합니다.
    ///
    /// - Parameter onStep: 현재 Step과 전달받은 데이터를 사용하여 다음 Step Publisher를 반환하는 클로저
    /// - Returns: 다음 Step을 체이닝할 수 있는 `ProcedureStep`
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

    /// 마지막 Step을 정의하고 워크플로우를 완료합니다.
    ///
    /// 이 메서드 호출 후에는 더 이상 Step을 체이닝할 수 없습니다.
    ///
    /// - Parameter onStep: 최종 동작을 수행하는 클로저
    public func finalStep(
        _ onStep: @escaping (CurrentStep, Value) -> Void
    ) {
        procedure.workflowCancellable = stream
            .map { [holder = procedure.completionHolder] actionable, value in
                onStep(actionable, value)
                holder.onFinish?()
                return ((), ())
            }
            .sink(receiveValue: { _ in })
    }
}
