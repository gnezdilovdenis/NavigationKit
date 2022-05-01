//
//  SheetRouter.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import UIKit

public protocol SheetViewControllerProtocol: AnyObject {

    var preferredSheetHeight: CGFloat { get }

    var canIncreaseSheetHeight: Bool { get }
}

public class SheetRouter: NSObject, RouterProtocol {

    public typealias EmptyClosure = () -> Void

    private enum Constants {

        static let backgroundWindowColor: UIColor = .black.withAlphaComponent(0.8)

        static let sheetTopViewHeight: CGFloat = 30

        static let sheetYPosition: CGFloat = -29
    }

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
                .filter ({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene else {
                    fatalError()
                }
        let popupWindow = UIWindow(windowScene: windowScene)
        return popupWindow
    }()

    private lazy var preferredHeight: CGFloat = estimatedHeight {
        didSet {
            updateViewSize()
        }
    }

    private var canIncreaseSheetHeight: Bool {
        guard let sheetViewController = navigationController.viewControllers.last as? SheetViewControllerProtocol else {
            return true
        }
        return sheetViewController.canIncreaseSheetHeight
    }

    private var estimatedHeight: CGFloat {
        if let sheetViewController = navigationController.viewControllers.last as? SheetViewControllerProtocol {
            return sheetViewController.preferredSheetHeight
        } else {
            return UIScreen.main.bounds.height * 0.8
        }
    }

    // MARK: Init & Override

    public init(navigationController: ProxyNavigationController = .init()) {
        self.navigationController = navigationController

        navigationController.apply {
            $0.view.clipsToBounds = false

            let headerSize: CGSize = .init(width: UIScreen.main.bounds.width,
                                           height: Constants.sheetTopViewHeight)
            let header = SheetTopView().apply {
                $0.frame = .init(origin: .init(x: .zero,
                                               y: Constants.sheetYPosition),
                                 size: headerSize)
            }

            $0.view.addSubview(header)
            $0.view.sendSubviewToBack(header)
        }

        super.init()

        navigationController.proxyDelegate.addDelegate(self)
    }

    // MARK: Actions

    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: navigationController.view)
        if location.y <= Constants.sheetYPosition {
            dismiss()
        }
    }

    @objc
    func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: window)

        switch sender.state {
        case .began, .changed:
            if translation.y < 0 {
                guard canIncreaseSheetHeight else { return }
                let delta = exp(-abs(0.002 * translation.y))

                UIView.animate(withDuration: CATransaction.animationDuration() / 3) {
                    self.preferredHeight += delta
                }
            } else {
                UIView.animate(withDuration: CATransaction.animationDuration() / 3,
                               delay: .zero,
                               options: [.beginFromCurrentState, .allowUserInteraction, .allowAnimatedContent],
                               animations: {
                                var origin: CGPoint = .init(x: .zero,
                                                            y: self.window.bounds.height - self.preferredHeight)
                                origin.y += translation.y

                                self.navigationController.view.frame.origin = origin

                               },
                               completion: nil)
            }

        default:
            let originY = self.navigationController.view.frame.origin.y
            let maximumOriginY = window.bounds.height - (preferredHeight * 0.5)

            if maximumOriginY < originY {
                dismiss()
            } else {
                UIView.animate(withDuration: CATransaction.animationDuration(),
                               delay: .zero,
                               options: [.layoutSubviews, .allowAnimatedContent]) {
                    self.preferredHeight = self.preferredHeight
                } completion: { _ in
                }
            }
        }
    }
}

// MARK: - Transitions

extension SheetRouter {

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

private extension SheetRouter {

    func show() {
        window.apply {
            $0.backgroundColor = .clear
            $0.makeKeyAndVisible()
            $0.addGestureRecognizer(UIPanGestureRecognizer().apply {
                $0.addTarget(self, action:  #selector(handlePan(_:)))
            })
            $0.addGestureRecognizer(UITapGestureRecognizer().apply {
                $0.addTarget(self, action:  #selector(handleTap(_:)))
                $0.delegate = self
            })
            $0.addSubview(navigationController.view)
        }

        navigationController.view.frame.size = .init(width: navigationController.view.frame.size.width,
                                                     height: preferredHeight)
        navigationController.view.frame.origin = .init(x: .zero,
                                                       y: window.bounds.height)

        UIView.animate(withDuration: CATransaction.animationDuration(),
                       delay: .zero,
                       options: [.curveEaseInOut],
                       animations: {
                        self.window.backgroundColor = Constants.backgroundWindowColor
                        self.navigationController.view.frame.origin =
                            .init(x: .zero,
                                  y: self.window.bounds.height - self.preferredHeight)
                       },
                       completion: nil)
    }

    func dismiss(completion: EmptyClosure? = nil) {
        guard window.isKeyWindow else {
            onRouterTerminated?()
            completion?()
            return
        }

        UIView.animate(withDuration: CATransaction.animationDuration(),
                       delay: .zero, options: [.beginFromCurrentState]) {
            self.navigationController.view.frame.origin = .init(x: .zero,
                                                                y: self.window.bounds.height)

            self.window.backgroundColor = .clear
        } completion: { [weak self] _ in
            self?.window.isHidden = true
            self?.onRouterTerminated?()
            completion?()
        }
    }

    func updateViewSize() {
        let origin: CGPoint = .init(x: .zero,
                                    y: self.window.bounds.height - self.preferredHeight)

        self.navigationController.view.frame =
            .init(origin: origin,
                  size: .init(width: self.navigationController.view.frame.width,
                              height: preferredHeight))
    }

}

// MARK: - UINavigationControllerDelegate

extension SheetRouter: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if preferredHeight != preferredHeight {
            UIView.animate(withDuration: CATransaction.animationDuration(),
                           delay: .zero,
                           options: [.layoutSubviews, .allowAnimatedContent]) {
                self.preferredHeight = self.preferredHeight
            } completion: { _ in
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension SheetRouter: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: navigationController.view)
        return location.y <= Constants.sheetYPosition
    }
}
