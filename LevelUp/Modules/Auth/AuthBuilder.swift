//
//  AuthBuilder.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit

final class AuthBuilder {
    static func build(dependencies: AppDependencies, completion: @escaping () -> Void) -> UIViewController {
        let view = AuthViewController()
        let interactor = AuthInteractor(
            authService: dependencies.authService
        )
        let router = AuthRouter(
            viewController: view,
            dependencies: dependencies,
            completion: completion)
        
        let presenter = AuthPresenter(
            view: view,
            interactor: interactor,
            router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
}
