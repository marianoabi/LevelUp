//
//  AuthServiceTests.swift
//  LevelUpTests
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation
import XCTest
@testable import LevelUp

final class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var mockNetworkService: MockNetworkService!
    
    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
        sut = AuthService(networkService: mockNetworkService)
    }
    
    override func tearDownWithError() throws {
        mockNetworkService = nil
        sut = nil
    }
    
    // MARK: - Tests
    func testLoginSuccess() {
        // Given
        let expectation = expectation(description: "Login success")
        let username = "testuser"
        let password = "password123"
        
        let expectedUser = User(id: "123", username: username, email: "test@example")
        let authResponse = AuthResponse(token: "test-token", user: expectedUser)
        
        mockNetworkService.mockResult = .success(authResponse)
        
        // When
        var resultUser: User?
        var resultError: Error?
        
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultError)
        XCTAssertNotNil(resultUser)
        XCTAssertEqual(resultUser?.id, expectedUser.id)
        XCTAssertEqual(resultUser?.username, expectedUser.username)
        XCTAssertEqual(resultUser?.email, expectedUser.email)
        
        // Verify token was stored
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authToken"), "test-token")
    }
    
    func testLoginFailureInvalidCredentials() {
        // Given
        let expectation = expectation(description: "Login failure - invalid credentials")
        let username = "testuser"
        let password = "wrongpassword"
        
        mockNetworkService.mockResult = .failure(NetworkError.unauthorized)
        
        // When
        var resultUser: User?
        var resultError: Error?
        
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultUser)
        XCTAssertNotNil(resultError)
        XCTAssertTrue(resultError is AuthError)
        XCTAssertEqual(resultError as? AuthError, .invalidCredentials)
    }
    
    func testLoginFailureServerError() {
        // Given
        let expectation = expectation(description: "Login failure - server error")
        let username = "testuser"
        let password = "password123"

        mockNetworkService.mockResult = .failure(NetworkError.serverError(statusCode: 500))
        
        // When
        var resultUser: User?
        var resultError: Error?
        
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultUser)
        XCTAssertNotNil(resultError)
        XCTAssertTrue(resultError is NetworkError)
        XCTAssertEqual(resultError as? NetworkError, .serverError(statusCode: 500))
    }
    
    func testLogout() {
        // Given
        UserDefaults.standard.set("test-token", forKey: "authToken")
        
        // When
        sut.logout()
        
        // Then
        XCTAssertNil(UserDefaults.standard.string(forKey: "authToken"))
    }
}

class MockNetworkService: NetworkServiceProtocol {
    var mockResult: Result<AuthResponse, Error>?
    
    func request<T>(endpoint: LevelUp.Endpoint, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        guard let mockResult = mockResult else {
            fatalError("Mock result not set")
        }
        
        switch mockResult {
        case .success(let response):
            guard let responseT = response as? T else {
                fatalError("Mock response mismatch")
            }
            completion(.success(responseT))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func upload(data: Data, endpoint: LevelUp.Endpoint, completion: @escaping (Result<Void, any Error>) -> Void) {
        fatalError("Not implemented in mock")
    }
    
}

