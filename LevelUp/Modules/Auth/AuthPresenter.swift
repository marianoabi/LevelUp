//
//  AuthPresenter.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

protocol AuthPresenterProtocol: AnyObject {
    var view: AuthViewProtocol? { get set }
    var interactor: AuthInteractorProtocol { get set }
    var router: AuthRouterProtocol { get set }
    
    func viewDidLoad()
    func loginButtonTapped(username: String, password: String)
    func registerButtonTapped()
}

protocol AuthInteractorOutputProtocol: AnyObject {
    func loginDidSucceed(with user: User)
    func loginDidFail(with error: Error)
}

final class AuthPresenter {
    weak var view: AuthViewProtocol?
    var interactor: AuthInteractorProtocol
    var router: AuthRouterProtocol
    
    init(view: AuthViewProtocol? = nil, interactor: AuthInteractorProtocol, router: AuthRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.interactor.presenter = self
    }
}

extension AuthPresenter: AuthPresenterProtocol {
    func viewDidLoad() {
        
    }
    
    func loginButtonTapped(username: String, password: String) {
        guard !username.isEmpty, !password.isEmpty else {
            view?.showError(message: "Username and password cannot be empty")
            return
        }

        view?.showLoading()
        interactor.login(username: username, password: password)
    }
    
    func registerButtonTapped() {
        router.navigateToRegistration()
    }
}

extension AuthPresenter: AuthInteractorOutputProtocol {
    func loginDidSucceed(with user: User) {
        view?.hideLoading()
        router.navigateToMain()
    }
    
    func loginDidFail(with error: any Error) {
        view?.hideLoading()
        
        let errorMessage: String
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                errorMessage = "Invalid username or password"
            case .networkError:
                errorMessage = "Network error. Please try again."
            case .serverError:
                errorMessage = "Server error. Please try again later."
            }
        } else {
            errorMessage = "An unknown error occurred"
        }
        
        view?.showError(message: errorMessage)
    }
    
}
