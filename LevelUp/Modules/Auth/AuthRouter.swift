//
//  AuthRouter.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit

protocol AuthRouterProtocol: AnyObject {
    func navigateToMain()
    func navigateToRegistration()
}

final class AuthRouter {
    private weak var viewController: UIViewController?
    private let dependencies: AppDependencies
    private let completion: () -> Void
    
    init(viewController: UIViewController, dependencies: AppDependencies, completion: @escaping () -> Void) {
        self.viewController = viewController
        self.dependencies = dependencies
        self.completion = completion
    }
}

extension AuthRouter: AuthRouterProtocol {
    func navigateToMain() {
        completion()
    }
    
    func navigateToRegistration() {
        
    }
}
