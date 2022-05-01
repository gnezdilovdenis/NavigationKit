//
//  RouterProtocol.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import Foundation

public protocol RouterProtocol: AnyObject {

    typealias EmptyClosure = () -> Void

    associatedtype Transition

    // MARK: Properties

    var onRouterTerminated: EmptyClosure? { get set }

    // MARK: Functions

    func setup(transition: Transition)

    func stop(completion: @escaping EmptyClosure)

}
