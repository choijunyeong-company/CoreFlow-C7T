//
//  Screenable.swift
//  CoreFlow
//
//  Created by choijunios on 3/18/26.
//

import Combine
import UIKit

@MainActor
public protocol Screenable: ActionSource, ViewControllable {
    associatedtype State: Equatable
    var reactor: AnyReactor<Action, State> { get }
}

extension Screenable {
    public func send(_ action: Action) {
        reactor.send(action)
    }
}

extension Screenable {
    public func observeState<T: Equatable, R: AnyObject>(
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
    
    public func observeState<T: Equatable>(
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

// MARK: Combine latest

extension Screenable {
    public func observeLatestStates<T1: Equatable, T2: Equatable>(
        _ keyPath1: KeyPath<State, T1>,
        _ keyPath2: KeyPath<State, T2>,
        sink: @escaping (T1, T2) -> Void
    ) {
        Publishers.CombineLatest(
            reactor.state.map(keyPath1).removeDuplicates(),
            reactor.state.map(keyPath2).removeDuplicates()
        )
        .sink(receiveValue: sink)
        .store(in: &store)
    }

    public func observeLatestStates<T1: Equatable, T2: Equatable, R: AnyObject>(
        _ keyPath1: KeyPath<State, T1>,
        _ keyPath2: KeyPath<State, T2>,
        receiver: R,
        sink: @escaping (R, T1, T2) -> Void
    ) {
        Publishers.CombineLatest(
            reactor.state.map(keyPath1).removeDuplicates(),
            reactor.state.map(keyPath2).removeDuplicates()
        )
        .weakRef(receiver)
        .sink { receiver, values in
            sink(receiver, values.0, values.1)
        }
        .store(in: &store)
    }

    public func observeLatestStates<T1: Equatable, T2: Equatable, T3: Equatable>(
        _ keyPath1: KeyPath<State, T1>,
        _ keyPath2: KeyPath<State, T2>,
        _ keyPath3: KeyPath<State, T3>,
        sink: @escaping (T1, T2, T3) -> Void
    ) {
        Publishers.CombineLatest3(
            reactor.state.map(keyPath1).removeDuplicates(),
            reactor.state.map(keyPath2).removeDuplicates(),
            reactor.state.map(keyPath3).removeDuplicates()
        )
        .sink(receiveValue: sink)
        .store(in: &store)
    }

    public func observeLatestStates<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
        _ keyPath1: KeyPath<State, T1>,
        _ keyPath2: KeyPath<State, T2>,
        _ keyPath3: KeyPath<State, T3>,
        _ keyPath4: KeyPath<State, T4>,
        sink: @escaping (T1, T2, T3, T4) -> Void
    ) {
        Publishers.CombineLatest4(
            reactor.state.map(keyPath1).removeDuplicates(),
            reactor.state.map(keyPath2).removeDuplicates(),
            reactor.state.map(keyPath3).removeDuplicates(),
            reactor.state.map(keyPath4).removeDuplicates()
        )
        .sink(receiveValue: sink)
        .store(in: &store)
    }
}

// MARK: Merge

extension Screenable {
    public func observeMergedStates<T: Equatable>(
        _ keyPaths: [KeyPath<State, T>],
        sink: @escaping (T) -> Void
    ) {
        let publishers = keyPaths.map { reactor.state.map($0).removeDuplicates() }
        Publishers.MergeMany(publishers)
            .sink(receiveValue: sink)
            .store(in: &store)
    }

    public func observeMergedStates<T: Equatable, R: AnyObject>(
        _ keyPaths: [KeyPath<State, T>],
        receiver: R,
        sink: @escaping (R, T) -> Void
    ) {
        let publishers = keyPaths.map { reactor.state.map($0).removeDuplicates() }
        Publishers.MergeMany(publishers)
            .weakRef(receiver)
            .sink(receiveValue: sink)
            .store(in: &store)
    }
}
