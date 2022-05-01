//
//  ModalNavigationRouter.swift
//  
//
//  Created by Denis Gnezdilov on 10.08.2021.
//

import UIKit

public class ModalNavigationRouter: NSObject, RouterProtocol {

    public enum Transition {

        case push(UIViewController)

        case pop

        /// Parameters:
        ///      - animated: Bool
        ///
        case present(Bool)

        case dismiss
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

public extension ModalNavigationRouter {

    func setup(transition: Transition) {
        switch transition {
        case let .push(viewController):
            navigationController.pushViewController(viewController, animated: true)

        case .pop:
            navigationController.popViewController(animated: true)

        case let .present(animated):
            guard let parentViewController: UIViewController = topMostController() else {
                return
            }

            parentViewController.present(navigationController, animated: animated, completion: nil)
            navigationController.presentationController?.delegate = self

        case .dismiss:
            navigationController.dismiss(animated: true) { [weak self] in
                self?.onRouterTerminated?()
            }
        }
    }

    func stop(completion: @escaping () -> Void) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onRouterTerminated?()
            completion()
        }
    }

    private func topMostController() -> UIViewController? {
        guard let window = (UIApplication
                                .shared
                                .connectedScenes
                                .first as? UIWindowScene)?
                .windows
                .filter({ $0.isKeyWindow })
                .first,
              let rootViewController = window.rootViewController else {
                  return nil
              }
        
        var topController = rootViewController
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
}

extension ModalNavigationRouter: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        if viewController === initiatedViewController {
            onRouterTerminated?()
        }
    }
}

extension ModalNavigationRouter: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onRouterTerminated?()
    }
}
