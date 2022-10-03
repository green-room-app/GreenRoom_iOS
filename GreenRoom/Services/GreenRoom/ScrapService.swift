//
//  ScrapService.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/27.
//

import Foundation
import RxSwift
import Alamofire

final class ScrapService {
    
    func fetchScrapQuestions() -> Observable<[PublicQuestion]> {
        let url = "\(Constants.baseURL)/api/green-questions/scrap"
        
        return Observable.create { emitter in
            AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [PublicQuestion].self) { response in
                    switch response.result {
                    case .success(let scrapQuestions):
                        emitter.onNext(scrapQuestions)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    func updateScrapQuestion(id: Int) -> Observable<Bool> {
        let url = "\(Constants.baseURL)/api/green-questions/scrap"
        
        let parameter: Parameters = ["id" : id]
        return Observable.create { emitter in
            AF.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default,interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseString { response in
                switch response.result {
                case .success(_):
                    emitter.onNext(true)
                case .failure(_):
                    emitter.onNext(false)
                }
            }
            return Disposables.create()
        }
    }
    
    func deleteScrapQuestion(ids: [Int]) {
        let url = "\(Constants.baseURL)/api/green-questions/scrap"
        
        let parameter = ["ids" : ids]
        
        AF.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default,interceptor: AuthManager()).validate(statusCode: 200..<300).responseString { response in
            
            switch response.result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
            
        }
    }
}
