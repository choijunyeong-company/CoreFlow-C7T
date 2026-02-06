import Combine
import UIKit

extension UIButton {
    public var touchUpInside: AnyPublisher<UIButton, Never> {
        UIControlEventPublisher(uiControl: self, event: .touchUpInside)
            .eraseToAnyPublisher()
    }
}
