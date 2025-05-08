//
//  AuthEntity.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

struct User: Codable {
    let id: String
    let username: String
    let email: String
    var profileImageURL: String?
    var fullName: String?
    var createdAt: Date?
    var lastLoginAt: Date?
}

struct UserRegistrationData: Codable {
    let username: String
    let email: String
    let password: String
    let fullName: String?
    
    func toDictionary() -> [String: Any] {
        return [
            "username": username,
            "email": email,
            "password": password,
            "fullName": fullName as Any
        ]
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError
}
