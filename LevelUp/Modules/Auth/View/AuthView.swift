//
//  AuthView.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import UIKit
import SnapKit

class AuthView: UIView {
    
    // UI Elements
    lazy var contentView: UIView = {
        var view = UIView()
        return view
    }()
    
    lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.accessibilityIdentifier = "Username"
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.accessibilityIdentifier = "Password"
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.accessibilityIdentifier = "Login"
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.accessibilityIdentifier = "Register"
        return button
    }()
    
    private let captchaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.accessibilityIdentifier = "captcha-container"
        return imageView
    }()
    
    private let captchaTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter CAPTCHA"
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        return textField
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
}

// MARK: - Private Methods
extension AuthView {
    private func setupViews() {
        backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [
            usernameTextField,
            passwordTextField,
            captchaImageView,
            captchaTextField,
            loginButton,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
