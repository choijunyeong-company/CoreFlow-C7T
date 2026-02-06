import Combine
import UIKit

/// UIViewController 기반의 화면 컴포넌트입니다.
///
/// Screen은 Core(Reactor)로부터 상태를 관찰하고, UI 이벤트를 액션으로 변환하여 전송합니다.
/// `bind()` 메서드에서 상태 관찰과 액션 바인딩을 설정합니다.
@MainActor
open class Screen<Reactor: Reactable>: UIViewController, Screenable, ActionSource {
    public weak var reactor: Reactor!

    public typealias Action = Reactor.Action
    public typealias State = Reactor.State

    public init(reactor: Reactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    public required init?(coder _: NSCoder) { nil }

    /// Screen 초기화 시 호출됩니다. 서브클래스에서 초기 설정 시 오버라이드합니다.
    open func initialize() {}

    /// 상태 관찰과 액션 바인딩을 설정하는 메서드입니다.
    ///
    /// Flow의 `createScreen()`에서 Screen 생성 후 호출됩니다.
    /// `observeState`, `observeDistinctState`, `bind(onEmit:send:)` 메서드를 사용하여
    /// 상태 변경 관찰과 UI 이벤트-액션 바인딩을 구현합니다.
    open func bind() {}
}

// MARK: Sending action to Reactor

public extension Screen {
    /// 액션을 Reactor(Core)에 직접 전송합니다.
    final func send(_ action: Action) {
        reactor.send(action)
    }

    /// Publisher 이벤트를 액션으로 변환하여 Reactor에 전송합니다.
    ///
    /// - Parameters:
    ///   - pubisher: UI 이벤트를 발행하는 Publisher
    ///   - transform: Publisher 출력을 액션으로 변환하는 클로저
    final func bind<P: Publisher>(
        onEmit pubisher: () -> P,
        send transform: @escaping (P.Output) -> Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        bind(onEmit: pubisher(), send: transform, onComplete, onFailure)
    }

    final func bind<P: Publisher>(
        onEmit pubisher: P,
        send transform: @escaping (P.Output) -> Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        pubisher
            .map(transform)
            .sink { completion in
                switch completion {
                case .finished: onComplete?()
                case let .failure(error): onFailure?(error)
                }
            } receiveValue: { [weak reactor] action in
                reactor?.send(action)
            }
            .store(in: &store)
    }

    final func bind<P: Publisher>(
        onEmit publisher: () -> P,
        send action: Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        bind(onEmit: publisher(), send: action, onComplete, onFailure)
    }

    final func bind<P: Publisher>(
        onEmit publisher: P,
        send action: Action,
        _ onComplete: (() -> Void)? = nil,
        _ onFailure: ((P.Failure) -> Void)? = nil
    ) {
        publisher
            .map { _ in action }
            .sink { completion in
                switch completion {
                case .finished: onComplete?()
                case let .failure(error): onFailure?(error)
                }
            } receiveValue: { [weak reactor] action in
                reactor?.send(action)
            }
            .store(in: &store)
    }
}

// MARK: Observe Reactor's state

public extension Screen {
    /// 상태의 특정 속성을 관찰하고, 변환 후 처리합니다.
    final func observeState<T>(
        _ keyPath: KeyPath<State, T>,
        transform: @escaping (T) -> AnyPublisher<T, Never>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .eraseToAnyPublisher()
            .flatMap(transform)
            .sink(receiveValue: sink)
            .store(in: &store)
    }

    final func observeState<T>(
        _ keyPath: KeyPath<State, T>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .sink(receiveValue: sink)
            .store(in: &store)
    }

    /// 상태의 특정 속성을 관찰하고, 값이 변경될 때만 처리합니다.
    ///
    /// `Equatable`한 속성에 대해 중복 값을 자동으로 필터링합니다.
    /// UI 업데이트 시 불필요한 렌더링을 방지하는 데 유용합니다.
    final func observeDistinctState<T: Equatable>(
        _ keyPath: KeyPath<State, T>,
        sink: @escaping (_ output: T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .removeDuplicates()
            .sink(receiveValue: sink)
            .store(in: &store)
    }
    
    public func forward<Substate, Listener: StateListener>(state keyPath: KeyPath<State, Substate>, to listener: Listener) where Listener.State == Substate {
        listener.listen(to: reactor.state.map(keyPath))
    }
}
