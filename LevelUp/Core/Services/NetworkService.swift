//
//  NetworkService.swift
//  LevelUp
//
//  Created by Abigail Mariano on 5/8/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void)
    func upload(data: Data, endpoint: Endpoint, completion: @escaping (Result<Void, Error>) -> Void)
}

enum Endpoint {
    case login(username: String, password: String)
    case register(userData: UserRegistrationData)
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "auth/register"
        }
    }
    
    var method: String {
        switch self {
        case .login:
            return "POST"
        case .register:
            return "GET"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .login(let username, let password):
            return [
                "username": username,
                "password": password
            ]
        case .register(let userData):
            return userData.toDictionary()
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.levelup.com/v1"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T>(endpoint: Endpoint, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        guard let url = buildURL(for: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if endpoint.method != "GET", let params = endpoint.parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(NetworkError.invalidParameters))
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(NetworkError.decodingFailed))
                }
            case 401:
                completion(.failure(NetworkError.unauthorized))
            case 403:
                completion(.failure(NetworkError.forbidden))
            case 404:
                completion(.failure(NetworkError.notFound))
            default:
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        
        task.resume()
    }
    
    func upload(data: Data, endpoint: Endpoint, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let url = buildURL(for: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        
        // Setup for multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authorization if needed
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create body with the file data
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 401:
                completion(.failure(NetworkError.unauthorized))
            case 403:
                completion(.failure(NetworkError.forbidden))
            case 404:
                completion(.failure(NetworkError.notFound))
            default:
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        
        task.resume()
    }
    
    private func buildURL(for endpoint: Endpoint) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return nil
        }
        
        if endpoint.method == "GET", let params = endpoint.parameters {
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            components.queryItems = queryItems
        }
        
        return components.url
    }
}

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidParameters
    case invalidResponse
    case noData
    case decodingFailed
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
}
