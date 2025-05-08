//
//  NetworkServiceTests.swift
//  LevelUpTests
//
//  Created by Abigail Mariano on 5/8/25.
//

import XCTest
@testable import LevelUp

final class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    var mockURLSession: MockURLSession!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mockURLSession = MockURLSession()
        sut = NetworkService(session: mockURLSession)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        mockURLSession = nil
        sut = nil
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRequestSuccess() {
        // Given
        let endpoint = Endpoint.login(username: "testuser", password: "password123")
        let user = User(id: "123", username: "testuser", email: "test@example.com")
        let authResponse = AuthResponse(token: "test-token", user: user)
        
        let data = try! JSONEncoder().encode(authResponse)
        let httpResponse = HTTPURLResponse(url: URL(string: "https://api.levelup.com/v1/auth/login")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.mockDataTaskData = data
        mockURLSession.mockDataTaskResponse = httpResponse
        mockURLSession.mockDataTaskError = nil
        
        let expectation = expectation(description: "Network request success")
        
        // When
        var resultResponse: AuthResponse?
        var resultError: Error?
        
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                resultResponse = response
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultError)
        XCTAssertNotNil(resultResponse)
        XCTAssertEqual(resultResponse?.token, authResponse.token)
        XCTAssertEqual(resultResponse?.user.id, authResponse.user.id)
        XCTAssertEqual(resultResponse?.user.username, authResponse.user.username)
        XCTAssertEqual(resultResponse?.user.email, authResponse.user.email)
    }

    func testRequestFailureUnauthorized() {
        // Given
        let endpoint = Endpoint.login(username: "testuser", password: "wrongpassword")
        let httpResponse = HTTPURLResponse(url: URL(string: "https://api.levelup.com/v1/auth/login")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        
        mockURLSession.mockDataTaskData = nil
        mockURLSession.mockDataTaskResponse = httpResponse
        mockURLSession.mockDataTaskError = nil
        
        let expectation = expectation(description: "Network request unauthorized")
        
        // When
        var resultResponse: AuthResponse?
        var resultError: Error?
        
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                resultResponse = response
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultResponse)
        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError as? NetworkError, .unauthorized)
    }
    
    func testRequestFailureServerError() {
        // Given
        let endpoint = Endpoint.login(username: "testuser", password: "password123")
        let httpResponse = HTTPURLResponse(url: URL(string: "https://api.levelup.com/v1/auth/login")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.mockDataTaskData = nil
        mockURLSession.mockDataTaskResponse = httpResponse
        mockURLSession.mockDataTaskError = nil
        
        let expectation = expectation(description: "Network request server error")
        
        // When
        var resultResponse: AuthResponse?
        var resultError: Error?
        
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                resultResponse = response
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultResponse)
        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError as? NetworkError, .serverError(statusCode: 500))
    }
    
    func testRequestFailureNetworkError() {
        // Given
        let endpoint = Endpoint.login(username: "testuser", password: "password123")
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        
        mockURLSession.mockDataTaskData = nil
        mockURLSession.mockDataTaskResponse = nil
        mockURLSession.mockDataTaskError = networkError
        
        let expectation = expectation(description: "Network request network error")
        
        // When
        var resultResponse: AuthResponse?
        var resultError: Error?
        
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                resultResponse = response
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultResponse)
        XCTAssertNotNil(resultError)
        XCTAssertEqual((resultError! as NSError).domain, networkError.domain)
        XCTAssertEqual((resultError! as NSError).code, networkError.code)
    }
    
    func testRequestFailureDecodingError() {
        // Given
        let endpoint = Endpoint.login(username: "testuser", password: "password123")
        let invalidData = "invalid json".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(url: URL(string: "https://api.levelup.com/v1/auth/login")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.mockDataTaskData = invalidData
        mockURLSession.mockDataTaskResponse = httpResponse
        mockURLSession.mockDataTaskError = nil
        
        let expectation = expectation(description: "Network request decoding error")

        // When
        var resultResponse: AuthResponse?
        var resultError: Error?
        
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                resultResponse = response
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(resultResponse)
        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError as? NetworkError, .decodingFailed)
    }
    
    func testBuildURLWithGETParameters() {
        // Given
        let userData = UserRegistrationData(username: "newuser", email: "new@example.com", password: "pass123", fullName: "New User")
        let endpoint = Endpoint.register(userData: userData)
        
        let urlCapturingSession = URLCapturingMockSession()
        sut = NetworkService(session: urlCapturingSession)
        
        // When
        let expectation = expectation(description: "Network request made")
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            // We don't care about the result, just that the request was made
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(urlCapturingSession.capturedRequest)
        let urlString = urlCapturingSession.capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("username=newuser"), "URL should contain username parameter")
        XCTAssertTrue(urlString.contains("email=new%40example.com"), "URL should contain email parameter")
        XCTAssertTrue(urlString.contains("password=pass123"), "URL should contain password parameter")
        XCTAssertTrue(urlString.contains("fullName=New%20User"), "URL should contain fullName parameter")
    }
    
    func testRequestURLWithGETParameters2() {
        // First, let's check the actual method for the register endpoint
        let userData = UserRegistrationData(username: "newuser", email: "new@example.com", password: "pass123", fullName: "New User")
        let endpoint = Endpoint.register(userData: userData)
        
        // Check if the method is actually GET as expected
        XCTAssertEqual(endpoint.method, "GET", "Register endpoint should use GET method")
        
        // Create a custom URLSession mock that captures the request
        let urlCapturingSession = URLCapturingMockSession()
        sut = NetworkService(session: urlCapturingSession)
        
        // When
        let expectation = expectation(description: "Network request made")
        sut.request(endpoint: endpoint) { (result: Result<AuthResponse, Error>) in
            // We don't care about the result, just that the request was made
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        
        // Verify the URL was constructed correctly
        XCTAssertNotNil(urlCapturingSession.capturedRequest)
        
        // Print the captured URL for debugging
        print("Captured URL: \(urlCapturingSession.capturedRequest?.url?.absoluteString ?? "nil")")
        
        // If this is a POST request, the parameters might be in the body instead of the URL
        if endpoint.method == "POST" {
            if let httpBody = urlCapturingSession.capturedRequest?.httpBody,
               let bodyString = String(data: httpBody, encoding: .utf8) {
                print("Request body: \(bodyString)")
                
                // Check for parameters in body instead
                XCTAssertTrue(bodyString.contains("newuser"), "Body should contain username")
                XCTAssertTrue(bodyString.contains("new@example.com"), "Body should contain email")
                XCTAssertTrue(bodyString.contains("New User"), "Body should contain fullName")
            } else {
                XCTFail("POST request should have a body")
            }
        } else {
            // For GET requests, check the URL query parameters
            let urlString = urlCapturingSession.capturedRequest?.url?.absoluteString ?? ""
            
            // Verify that key parameters are in the URL - relaxing the exact format requirements
            XCTAssertTrue(urlString.contains("username=newuser"), "URL should contain username parameter")
            XCTAssertTrue(urlString.contains("email="), "URL should contain email parameter")
            XCTAssertTrue(urlString.contains("fullName="), "URL should contain fullName parameter")
        }
    }
}

class MockURLSession: URLSession, @unchecked Sendable {
    var mockDataTaskData: Data?
    var mockDataTaskResponse: URLResponse?
    var mockDataTaskError: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(mockDataTaskData, mockDataTaskResponse, mockDataTaskError)
        return MockURLSessionDataTask()
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    override func resume() {
        // No-op for testing
    }
}

class URLCapturingMockSession: URLSession, @unchecked Sendable {
    var capturedRequest: URLRequest?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        capturedRequest = request
        
        // Create an example success response for testing
        let user = User(id: "test", username: "test", email: "test@example.com")
        let response = AuthResponse(token: "token", user: user)
        let data = try? JSONEncoder().encode(response)
        
        let httpResponse = HTTPURLResponse(url: request.url ?? URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        completionHandler(data, httpResponse, nil)
        return MockURLSessionDataTask()
    }
}
