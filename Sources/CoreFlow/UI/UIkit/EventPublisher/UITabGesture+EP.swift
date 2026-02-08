import Combine
import UIKit

extension UITapGestureRecognizer {
    public var gesture: AnyPublisher<UITapGestureRecognizer, Never> {
        GestureRecognizerPublisher(recognizer: self)
            .eraseToAnyPublisher()
    }
}
