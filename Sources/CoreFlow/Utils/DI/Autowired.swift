@preconcurrency @_exported import Swinject

/// A property wrapper that automatically injects dependencies.
///
/// Resolves dependencies from `ServiceLocator` at initialization time.
/// A runtime error occurs if the type is not registered.
///
/// ```swift
/// class LoginCore: Core<LoginAction, LoginState> {
///     @Autowired private var service: LoginService
/// }
/// ```
@propertyWrapper
public class Autowired<T> {
    public let wrappedValue: T

    /// Resolves the dependency from ServiceLocator at initialization.
    public init() {
        self.wrappedValue = ServiceLocator.shared.resolve()
    }
}

/// A singleton class that manages the dependency container.
///
/// Internally manages a Swinject Container for dependency registration and resolution.
/// Access globally via `ServiceLocator.shared`.
public final class ServiceLocator: Sendable {
    public static let shared = ServiceLocator()

    private let container: Container

    private init(container: Container = Container()) {
        self.container = container
    }
}

// MARK: Public
extension ServiceLocator {
    /// Registers multiple Assemblies at once.
    ///
    /// Register all Assemblies in `AppDelegate` at app launch.
    ///
    /// - Parameter assemblies: An array of Assemblies to register.
    public func assemble(_ assemblies: [Assembly]) {
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }

    /// Registers a single dependency.
    ///
    /// - Parameters:
    ///   - serviceType: The service type to register.
    ///   - object: A factory closure that creates the dependency.
    /// - Returns: A `ServiceEntry` for chaining (e.g., `.inObjectScope(.container)`).
    @discardableResult
    public func register<T>(
        _ serviceType: T.Type,
        object: @escaping(Resolver) -> T
    ) -> ServiceEntry<T> {
        container.register(serviceType) {
            object($0)
        }
    }

    /// Resolves and returns a registered dependency.
    public func resolve<T>() -> T {
        container.resolve(T.self)!
    }

    /// Resolves and returns a registered dependency.
    ///
    /// - Parameter serviceType: The service type to resolve.
    /// - Returns: The resolved dependency instance.
    public func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(T.self)!
    }
}
