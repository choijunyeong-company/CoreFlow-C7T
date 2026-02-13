import Combine
import UIKit

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
