//
//  AuthCoordinator.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit

final class AuthCoordinator {
    private let navigationController: UINavigationController
    private let dependencies: AppDependencies
    private let completion: () -> Void
    
    init(navigationController: UINavigationController, dependencies: AppDependencies, completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.completion = completion
    }
    
    func start() {
        let authVC = AuthBuilder.build(dependencies: dependencies, completion: completion)
        navigationController.setViewControllers([authVC], animated: true)
    }
}

extension AuthCoordinator {
    func showRegistration() {
        
    }
}
