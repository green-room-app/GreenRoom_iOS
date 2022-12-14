//
//  Provider.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/11/04.
//

import Foundation
import RxSwift
import Alamofire

protocol Provider {
    func request(with request: EndPoint) -> Single<Data>
}

final class NetworkManager: Provider {
    
    static let shared = NetworkManager()
    
    private init () { }
    
    func request(with request: EndPoint) -> Single<Data> {
        return Single.create { single in
        
            guard let AFRequest = request.getRequest() else { return Disposables.create() }
            AFRequest
                .validate(statusCode: 200..<300)
                .responseData(completionHandler: { response in
                switch response.result {
                case .success(let result):
                    single(.success(result))
                case .failure(let error):
                    single(.failure(error))
                }
            })
            return Disposables.create()
        }
    }
    
    func request<T: Codable>(with request: EndPoint, type: T.Type) -> Single<T> {
        return Single.create { single in
        
            guard let AFRequest = request.getRequest() else { return Disposables.create() }
            AFRequest
                .validate(statusCode: 200..<300)
                .responseDecodable(of: type.self, completionHandler: { response in
                    switch response.result {
                    case .success(let result):
                        single(.success(result))
                    case .failure(let error):
                        single(.failure(error))
                    }
                })
            return Disposables.create()
        }
    }
    
    func upload(url: String, data: Data) -> Single<Data> {
        return Single.create { single in
            AF.upload(data, to: url, method: .put).response { response in
                switch response.result {
                case .success(let data):
                    single(.success(data ?? Data()))
                    print("image upload success with AWS S3")
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
