//
//  WindowedRouter.swift
//  
//
//  Created by Ivan Gorbulin on 12.01.2022.
//

import UIKit

public class WindowedRouter: NSObject, RouterProtocol {

    public typealias EmptyClosure = () -> Void

    public enum Transition {

        case show

        case push(UIViewController)

        case pop

        case dismiss
    }

    // MARK: Internal properties

    public let navigationController: ProxyNavigationController

    public var onRouterTerminated: EmptyClosure?

    // MARK: Private properties

    private let window: UIWindow = { () -> UIWindow in
        guard let windowScene = UIApplication
                .shared
                .connectedScenes
                .first as? UIWindowScene else {
            fatalError()
        }
        return UIWindow(windowScene: windowScene)
    }()

    // MARK: Init & Override

    public init(navigationController: ProxyNavigationController = .init()) {
        self.navigationController = navigationController

        super.init()
    }
}

// MARK: - Transitions

extension WindowedRouter {

    public func setup(transition: Transition) {
        switch transition {
        case .show:
            show()

        case let .push(controller):
            navigationController.pushViewController(controller, animated: true)

        case .pop:
            navigationController.popViewController(animated: true)

        case .dismiss:
            dismiss()
        }
    }

    public func stop(completion: @escaping EmptyClosure) {
        dismiss(completion: completion)
    }
}

// MARK: - Appear & Dismiss1

private extension WindowedRouter {

    func show() {
        window.apply {
            $0.alpha = .zero
            $0.makeKeyAndVisible()
            $0.rootViewController = navigationController
        }

        UIView.animate(withDuration: CATransaction.animationDuration(),
                       delay: .zero,
                       options: [.curveEaseInOut],
                       animations: {
            self.window.alpha = 1
        },
                       completion: nil)
    }

    func dismiss(completion: EmptyClosure? = nil) {
        guard window.isKeyWindow else {
            return
        }

        UIView.animate(withDuration: CATransaction.animationDuration(),
                       delay: .zero, options: [.beginFromCurrentState]) {
            self.window.alpha = .zero
        } completion: { [weak self] _ in
            self?.window.isHidden = true
            self?.onRouterTerminated?()
            completion?()
        }
    }
}
