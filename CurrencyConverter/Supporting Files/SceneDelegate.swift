//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let initialViewController = CurrencyRatesViewController(nibName: nil, bundle: nil)
        navigationController.viewControllers = [initialViewController]
        window!.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}

