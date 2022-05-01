//
//  ModalProxyCoordinator.swift
//  
//
//  Created by Denis Gnezdilov on 17.12.2021.
//

import Foundation

public final
class ModalProxyCoordinator<T>: Coordinator<T, ModalNavigationRouter> {

    // MARK: Private properties

    private weak var coordinator: Coordinator<T, NavigationRouter>?

    // MARK: Init & Override

    public init(with coordinator: Coordinator<T, NavigationRouter>, router: ModalNavigationRouter) {
        super.init(with: router)

        self.coordinator = coordinator
        addChild(coordinator: coordinator)
    }

    public override func trigger(_ route: T) {
        coordinator?.trigger(route)
    }

    public override func removeChildIfNeeded() {
        parentCoordinator?.removeChildIfNeeded()
    }
}

extension ModalProxyCoordinator {

    public func present() {
        router.setup(transition: .present(true))
    }

    public func dismiss() {
        router.setup(transition: .dismiss)
    }
}
