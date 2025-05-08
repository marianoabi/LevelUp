//
//  AuthPresenterTests.swift
//  LevelUpTests
//
//  Created by Abigail Mariano on 5/8/25.
//

import XCTest
@testable import LevelUp

final class AuthPresenterTests: XCTestCase {
    
    var sut: AuthPresenter!
    var mockView: MockAuthView!
    var mockInteractor: MockAuthInteractor!
    var mockRouter: MockAuthRouter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mockView = MockAuthView()
        mockInteractor = MockAuthInteractor()
        mockRouter = MockAuthRouter()
        
        sut = AuthPresenter(
            view: mockView,
            interactor: mockInteractor,
            router: mockRouter
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        sut = nil
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testLoginButtonTappedWithValidCredentials() {
        // Given
        let username = "testUser"
        let password = "password123"
        
        // When
        sut.loginButtonTapped(username: username, password: password)
        
        // Then
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockInteractor.loginUsername, username)
        XCTAssertEqual(mockInteractor.loginPassword, password)
    }

    func testLoginButtonTappedWithEmptyCredentials() {
        // When
        sut.loginButtonTapped(username: "", password: "")
        
        XCTAssertFalse(mockView.showLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "Username and password cannot be empty")
    }
    
    func testRegisterButtonTapped() {
        // When
        sut.registerButtonTapped()
        
        // Then
        XCTAssertTrue(mockRouter.navigateToRegistrationCalled)
    }
    
    func testLoginDidSucceed() {
        // Given
        let user = User(id: "123", username: "testuser", email: "test@example")
        
        // When
        sut.loginDidSucceed(with: user)
        
        // Then
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockRouter.navigateToMainCalled)
    }
    
    func testLoginDidFailWithInvalidCredentials() {
        // When
        sut.loginDidFail(with: AuthError.invalidCredentials)
        
        // Then
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "Invalid username or password")
    }
    
    func testLoginDidFailWithNetworkError() {
        // When
        sut.loginDidFail(with: AuthError.networkError)
        
        // Then
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "Network error. Please try again.")
    }
    
    func testLoginDidFailWithServerError() {
        // When
        sut.loginDidFail(with: AuthError.serverError)
        
        // Then
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "Server error. Please try again later.")
    }
    
    func testLoginDidFailWithUnknownError() {
        // When
        sut.loginDidFail(with: NSError(domain: "test", code: 0))
        
        // Then
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.errorMessage, "An unknown error occurred")
    }
}

class MockAuthView: AuthViewProtocol {
    var presenter: AuthPresenterProtocol?
    
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showErrorCalled = false
    var errorMessage: String?
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
        errorMessage = message
    }
    
}

class MockAuthInteractor: AuthInteractorProtocol {
    weak var presenter: AuthInteractorOutputProtocol?
    
    var loginUsername: String?
    var loginPassword: String?
    
    func login(username: String, password: String) {
        loginUsername = username
        loginPassword = password
    }
}

class MockAuthRouter: AuthRouterProtocol {
    var navigateToMainCalled = false
    var navigateToRegistrationCalled = false
    
    func navigateToMain() {
        navigateToMainCalled = true
    }
    
    func navigateToRegistration() {
        navigateToRegistrationCalled = true
    }
}
