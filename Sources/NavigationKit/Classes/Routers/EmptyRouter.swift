//
//  EmptyRouter.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import Foundation

public final class EmptyRouter: RouterProtocol {

    public enum Transition {
    }

    // MARK: Internal properties

    public var onRouterTerminated: EmptyClosure?

    // MARK: Init & Override

    public init() {}

    // MARK: Functions

    public func setup(transition: Transition) {
    }

    public func stop(completion: () -> Void) {
        completion()
    }
}
