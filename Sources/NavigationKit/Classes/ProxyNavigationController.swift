//
//  ProxyNavigationController.swift
//  
//
//  Created by Denis Gnezdilov on 19.10.2021.
//

import UIKit

public class ProxyNavigationController: UINavigationController {

    // MARK: Public properties

    public private(set) var proxyDelegate: NavigationDelegateProxy = .init()

    // MARK: Internal properties

    // MARK: Private properties

    // MARK: Init & Override

    public override func viewDidLoad() {
        super.viewDidLoad()

        delegate = proxyDelegate
    }
}
