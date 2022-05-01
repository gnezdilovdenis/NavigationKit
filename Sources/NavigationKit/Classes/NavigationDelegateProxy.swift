//
//  NavigationDelegateProxy.swift
//  NavigationKit
//
//  Created by Denis Gnezdilov on 29.06.2021.
//

import UIKit
import UtilitiesKit

public final class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {

    // MARK: Private properties

    private var weakArray: NSPointerArray = .weakObjects()

    // MARK: Utilities

    public func addDelegate(_ delegate: UINavigationControllerDelegate) {
        weakArray.addObject(delegate)
    }

    public func removeDelegate(_ delegate: UINavigationControllerDelegate) {
        weakArray.removeObject(delegate)
    }
}

public extension NavigationDelegateProxy {

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        weakArray.allObjects.forEach {
            ($0 as? UINavigationControllerDelegate)?
                .navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        weakArray.allObjects.forEach {
            ($0 as? UINavigationControllerDelegate)?
                .navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
}
