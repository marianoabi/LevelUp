//
//  AppDependencies.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

final class AppDependencies {
    
    // Core
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    // Services
    lazy var authService: AuthServiceProtocol = AuthService(networkService: networkService)
}
