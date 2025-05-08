//
//  AuthInteractor.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

protocol AuthInteractorProtocol: AnyObject {
    var presenter: AuthInteractorOutputProtocol? { get set }
    
    func login(username: String, password: String)
}

final class AuthInteractor {
    weak var presenter: AuthInteractorOutputProtocol?
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
}

extension AuthInteractor: AuthInteractorProtocol {
    func login(username: String, password: String) {
        authService.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.presenter?.loginDidSucceed(with: user)
                case .failure(let error):
                    self?.presenter?.loginDidFail(with: error)
                }
            }
        }
    }
}
