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
    
    init(window: UIWindow, dependencies: AppDependencies, navigationController: UINavigationController, authCoordinator: AuthCoordinator? = nil) {
        self.window = window
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.authCoordinator = authCoordinator
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // show auth or main
        showAuthFlow()
    }
    
    private func showAuthFlow() {
        
    }
}
