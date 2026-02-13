import Combine
import UIKit

/// A type that reacts to actions and emits state changes.
///
/// This protocol defines the reactive behavior of a Core component.
/// It receives actions via `send(_:)` and publishes state changes
/// through a Combine publisher, enabling unidirectional data flow.
@MainActor
public protocol Reactable<Action, State>: AnyObject {
    associatedtype Action
    associatedtype State: Equatable

    var state: AnyPublisher<State, Never> { get }
    func send(_ action: Action)
}

extension Reactable {
    public func scope<SubState: Equatable, SubAction>(
        state statePath: KeyPath<State, SubState>,
        transform: @escaping (SubAction) -> Action
    ) -> any Reactable<SubAction, SubState> {
        SubReactor<SubState, SubAction>(state: state.map(statePath)) { [weak self] subAction in
            self?.send(transform(subAction))
        }
    }
}

/// A coordinator that owns and manages both Core and Screen components.
///
/// Flow acts as the composition root for a feature, responsible for:
/// - Creating and holding references to Core and Screen
/// - Managing child flows and their lifecycle
/// - Implementing routing protocols to handle navigation requests
///
/// - Note: For screenless flows (e.g., coordinators that only manage child flows),
///   the Screen type can be set to a placeholder `UIViewController` that is never displayed.
@MainActor
public protocol Flowable: AnyObject {
    associatedtype Core
    associatedtype Screen: UIViewController

    var core: Core { get }
    var screen: Screen { get }
}

/// A view controller that serves as the visual representation of a feature.
///
/// Screens are responsible for rendering UI and forwarding user interactions
/// to their associated Core via actions.
public protocol Screenable: UIViewController {}

/// A type that supports RIBs-style activation lifecycle.
///
/// Conforming types receive lifecycle callbacks when they become active or resign.
/// Flow automatically calls these methods when the Core is created and when Flow is deallocated.
@MainActor
public protocol Activatable: AnyObject {
    /// Called when the Core becomes active (immediately after creation).
    func didBecomeActive()

    /// Called when the Core will resign active (when Flow is deallocated).
    func willResignActive()
}

public extension Activatable {
    func didBecomeActive() {}
    func willResignActive() {}
}
