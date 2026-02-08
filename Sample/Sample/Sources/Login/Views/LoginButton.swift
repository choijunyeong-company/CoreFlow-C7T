//
//  LoginButton.swift
//  CoreFlow
//
//  Created by choijunios on 2/4/26.
//

import CoreFlow
import UIKit

final class LoginButton: UIButton, ActionSource {
    typealias Failure = Never
    enum Action {
        case buttonTapped
    }
    
    init() {
        super.init(frame: .zero)
        setTitle("로그인", for: .normal)
        setTitleColor(.black, for: .normal)
        setTitleColor(.lightGray, for: .highlighted)
        addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { nil }
    
    @objc
    private func onTap() {
        send(.buttonTapped)
    }
}
