import Combine
import UIKit

extension UIButton {
    public var touchUpInside: AnyPublisher<Void, Never> {
        UIControlEventPublisher(
            uiControl: self,
            addTarget: { control, object, action in
                control.addTarget(object, action: action, for: .touchUpInside)
            },
            removeTarget: { control, object, action in
                control?.removeTarget(object, action: action, for: .touchUpInside)
            }
        )
        .eraseToAnyPublisher()
    }
}
