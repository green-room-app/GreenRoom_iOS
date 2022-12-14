//
//  AuthManager.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/03.
//

import Alamofire
import SwiftKeychainWrapper

class AuthManager: RequestInterceptor {
    
    private var retryLimit = 3
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        guard urlRequest.url?.absoluteString.hasPrefix(Constants.baseURL) == true else { return }
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .authenticationObserver, object: nil)
            }
            return
        }
   
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        urlRequest.headers.add(.contentType("application/json"))
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 || response.statusCode == 403 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)/api/auth/reissue") else { return }
        
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
                let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken") else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .authenticationObserver, object: nil)
            }
            return
        }

        let parameters: Parameters = [
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ] 
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Auth.self) { response in

            switch response.result {
            case .success(let token):
                
                KeychainWrapper.standard.removeAllKeys()
                KeychainWrapper.standard.set(token.accessToken, forKey: "accessToken")
                KeychainWrapper.standard.set(token.refreshToken, forKey: "refreshToken")
                
                request.retryCount < self.retryLimit ? completion(.retry) : completion(.doNotRetry)
            case .failure(_):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationObserver, object: nil)
                }
            }
        }
        
    }
}
