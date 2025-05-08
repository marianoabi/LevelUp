//
//  MockNetworkService.swift
//  LevelUpTests
//
//  Created by Abigail Mariano on 5/8/25.
//

import XCTest
@testable import LevelUp

final class MockNetworkService: NetworkServiceProtocol {
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
