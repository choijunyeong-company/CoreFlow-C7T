//
//  LoginButton.swift
//  CoreFlow
//
//  Created by choijunios on 2/4/26.
//

import CoreFlow
import UIKit

final class LoginButton: UIButton {
    init() {
        super.init(frame: .zero)
        setTitle("로그인", for: .normal)
        setTitleColor(.black, for: .normal)
        setTitleColor(.lightGray, for: .highlighted)
    }
    required init?(coder: NSCoder) { nil }
}
