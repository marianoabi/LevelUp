//
//  AppCoordinator.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let dependencies: AppDependencies
    private let navigationController: UINavigationController
    private var authCoordinator: AuthCoordinator?
    
    init(window: UIWindow, dependencies: AppDependencies) {
        self.window = window
        self.dependencies = dependencies
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // show auth or main
        if dependencies.authService.isAuthenticated {
            // Main
        } else {
            showAuthFlow()
        }
    }
    
    private func showAuthFlow() {
        authCoordinator = AuthCoordinator(navigationController: navigationController, dependencies: dependencies, completion: { [weak self] in
            self?.showAuthFlow()
        })
        authCoordinator?.start()
    }
}
