//
//  Coordinator.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import Foundation

public protocol CoordinatorProtocol: AnyObject {

    // MARK: Properties

    var parentCoordinator: CoordinatorProtocol? { get set }

    var childCoordinator: CoordinatorProtocol? { get }

    // MARK: Functions

    func removeChildIfNeeded()

    func addChild(coordinator: CoordinatorProtocol)
}

open class Coordinator<Route, Router: RouterProtocol>: CoordinatorProtocol {

    public weak var parentCoordinator: CoordinatorProtocol?

    // MARK: Internal properties

    public let router: Router

    // MARK: Private properties

    public private(set) var childCoordinator: CoordinatorProtocol?

    // MARK: Init & Override

    public init(with router: Router) {
        self.router = router

        setup()
    }

    deinit {
        router.stop {}
    }

    // MARK: -

    open func trigger(_ route: Route) {
        assertionFailure("Method not implemented 🤷🏽‍♂️")
    }

    open func removeChildIfNeeded() {
        childCoordinator = nil
    }
}

public extension Coordinator {

    func addChild(coordinator: CoordinatorProtocol) {
        guard childCoordinator == nil else {
            assertionFailure("Child coordinator already exists")
            return
        }

        coordinator.parentCoordinator = self
        childCoordinator = coordinator
    }
}

private extension Coordinator {

    func setup() {
        router.onRouterTerminated = { [weak self] in
            self?.parentCoordinator?.removeChildIfNeeded()
        }
    }
}
