import Combine

public extension Publisher {
    func weakRef<T: AnyObject>(_ object: T) -> AnyPublisher<(T, Output), Failure> {
        compactMap { [weak object] output -> (T, Output)? in
            guard let object else { return nil }

            return (object, output)
        }
        .eraseToAnyPublisher()
    }
}
