//
//  ViewController.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit

protocol AuthViewProtocol: AnyObject {
    var presenter: AuthPresenterProtocol? { get set }
    func showLoading()
    func hideLoading()
    func showError(message: String)
}

class AuthViewController: UIViewController {
    var presenter: AuthPresenterProtocol?
    
    private let contentView = AuthView()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
        setupActions()
    }


}

// MARK: - Private
extension AuthViewController {
    private func setupLoadingIndicator() {
        contentView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        contentView.loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        contentView.registerButton.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
    }
}

// MARK: - Actions
extension AuthViewController {
    @objc private func loginButtonTapped(_ sender: UIButton) {
        presenter?.loginButtonTapped(
            username: contentView.usernameTextField.text ?? "",
            password: contentView.passwordTextField.text ?? "")
    }
    
    @objc private func registerButtonTapped(_ sender: UIButton) {
        presenter?.registerButtonTapped()
    }
}

extension AuthViewController: AuthViewProtocol {
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
}

