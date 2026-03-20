//
//  Effect.swift
//  CoreFlow
//
//  Created by choijunios on 3/20/26.
//


/// A side effect returned from action processing.
///
/// Used when asynchronous work is needed in `reduce(state:action:)`.
/// - `.none`: No additional work.
/// - `.run`: Executes async work and sends derived actions.
public enum Effect<Action>: CustomStringConvertible {
    public typealias Send = @MainActor (Action) async -> Void
    public typealias RunTask = @MainActor @Sendable (Send) async -> Void

    /// No additional work needed.
    case none

    /// Executes async work and sends derived actions upon completion.
    case run(priority: TaskPriority? = nil, task: RunTask)
    
    /// Send new action.
    case send(_ action: Action)
    
    public var description: String {
        switch self {
        case .none: "none"
        case .run(_, _): "run"
        case .send(let action): "send \(action)"
        }
    }
}
