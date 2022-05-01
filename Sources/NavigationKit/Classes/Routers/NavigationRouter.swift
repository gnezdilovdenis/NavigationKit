//
//  NavigationRouter.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import UIKit

public class NavigationRouter: NSObject, RouterProtocol {

    public enum Transition {

        case push(UIViewController)

        case pop
    }

    // MARK: Public properties

    public let navigationController: ProxyNavigationController

    public var onRouterTerminated: EmptyClosure?

    // MARK: Internal properties

    // MARK: Private properties

    private weak var initiatedViewController: UIViewController?

    // MARK: Init & Override

    public init(navigationController: ProxyNavigationController = .init()) {
        self.navigationController = navigationController

        super.init()

        navigationController.proxyDelegate.addDelegate(self)
        initiatedViewController = navigationController.viewControllers.last
    }
}

public extension NavigationRouter {

    func setup(transition: Transition) {
        switch transition {
        case let .push(viewController):
            navigationController.pushViewController(viewController, animated: true)

        case .pop:
            navigationController.popViewController(animated: true)
        }
    }

    func stop(completion: () -> Void) {
        if let initiatedViewController = initiatedViewController {
            navigationController.popToViewController(initiatedViewController, animated: true)
        }

        completion()
    }
}

extension NavigationRouter: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        if viewController === initiatedViewController {
            onRouterTerminated?()
        }
    }
}
