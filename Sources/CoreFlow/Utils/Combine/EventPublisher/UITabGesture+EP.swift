import Combine
import UIKit

extension UITapGestureRecognizer {
    public var tapPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        GestureRecognizerPublisher(recognizer: self)
            .eraseToAnyPublisher()
    }
}
