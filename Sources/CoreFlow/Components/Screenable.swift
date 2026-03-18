//
//  Screenable.swift
//  CoreFlow
//
//  Created by choijunios on 3/18/26.
//

import Combine
import UIKit

public protocol Screenable: ActionSource, ViewControllable where Action == Reactor.Action {
    associatedtype Reactor: Reactable
    typealias State = Reactor.State
    var reactor: Reactor { get }
}

extension Screenable {
    public func send(_ action: Action) {
        reactor.send(action)
    }
}

extension Screenable {
    public func observeDistinctState<T: Equatable, R: AnyObject>(
        _ keyPath: KeyPath<State, T>,
        receiver: R,
        sink: @escaping (R, T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .removeDuplicates()
            .weakRef(receiver)
            .sink(receiveValue: sink)
            .store(in: &store)
    }
    
    public func observeDistinctState<T: Equatable>(
        _ keyPath: KeyPath<State, T>,
        sink: @escaping (T) -> Void
    ) {
        reactor.state
            .map(keyPath)
            .removeDuplicates()
            .sink(receiveValue: sink)
            .store(in: &store)
    }
}
