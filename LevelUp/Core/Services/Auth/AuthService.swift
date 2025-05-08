//
//  AuthService.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func register(data: UserRegistrationData, completion: @escaping (Result<User, Error>) -> Void)
    func logout()
}

final class AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenKey = "authToken"
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    var isAuthenticated: Bool {
        false
    }
    
    func login(username: String, password: String, completion: @escaping (Result<User, any Error>) -> Void) {
        networkService.request(endpoint: .login(username: username, password: password)) { [weak self] (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                // Store token
                UserDefaults.standard.set(response.token, forKey: self?.tokenKey ?? "authToken")
                completion(.success(response.user))
            case .failure(let error):
                if let networkError = error as? NetworkError, networkError == .unauthorized {
                    completion(.failure(AuthError.invalidCredentials))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func register(data: UserRegistrationData, completion: @escaping (Result<User, any Error>) -> Void) {
        networkService.request(endpoint: .register(userData: data)) { [weak self] (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                // Store token
                UserDefaults.standard.set(response.token, forKey: self?.tokenKey ?? "authToken")
                completion(.success(response.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    
}
