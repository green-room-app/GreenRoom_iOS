//
//  MyQuestionService.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/26.
//

import Foundation
import RxSwift
import Alamofire

final class PublicQuestionService {
    
    private let baseURL = Constants.baseURL + "/api/green-questions"
    
    /** 내가 관심있어 하는 직무에 대한 질문들 조회*/
    func fetchFilteredQuestion(categoryId: Int) -> Observable<[PublicQuestion]> {

        let requestURL = baseURL +  "?categoryId=\(categoryId)"
        
        return Observable.create { emitter in
            
            AF.request(requestURL, method: .get, encoding: URLEncoding.default, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [PublicQuestion].self) { response in
                switch response.result {
                case .success(let questions):
                    emitter.onNext(questions)
                case .failure(let error):
                    emitter.onError(error)
                }
            }

            return Disposables.create()
        }
    }
    
    /** 최근 그린룸 질문 조회*/
    func fetchRecentPublicQuestions() -> Observable<[PublicQuestion]>{
        let requestURL = baseURL + "/recent-questions"
        
        return Observable.create { emmiter in
            AF.request(requestURL, method: .get, encoding: URLEncoding.default, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [PublicQuestion].self) { response in
                    
                switch response.result {
                case .success(let questions):
                    emmiter.onNext(questions)
                case .failure(let error):
                    emmiter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /** 인기있는 그린룸 질문 조회*/
    func fetchPopularPublicQuestions() -> Observable<[PopularPublicQuestion]>{
        
        let requestURL = baseURL + "/popular-questions"
        
        return Observable.create { emmiter in
            AF.request(requestURL, method: .get, encoding: URLEncoding.default, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [PopularPublicQuestion].self) { response in
                    
                switch response.result {
                case .success(let questions):
                    emmiter.onNext(questions)
                case .failure(let error):
                    emmiter.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
    /** 그린룸 질문 생성*/
    func uploadQuestionList(categoryId: Int, question: String, expiredAt: String) -> Observable<Bool> {
        
        let parameters = UploadPublicQuestionModel(categoryId: categoryId,
                                                   question: question,
                                                   expiredAt: expiredAt)
        
        return Observable.create { emitter in
            AF.request(self.baseURL, method: .post, parameters: parameters, encoder: .json, interceptor: AuthManager()).responseString { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400 {
                        emitter.onError(QuestionError.exceedMaximumLength)
                    } else if response.response?.statusCode == 404 {
                        emitter.onError(QuestionError.invalidCategory)
                    } else {
                        emitter.onNext(true)
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /** 내가 생성한 그린룸 질문 */
    func fetchPublicQuestions(page: Int = 0) -> Observable<MyPublicQuestion>{
        
        let requestURL = baseURL + "/create-questions"
        
        return Observable.create { emitter in
            AF.request(requestURL, method: .get, encoding: URLEncoding.default, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyPublicQuestion.self) { response in
                    switch response.result {
                    case .success(let question):
                        emitter.onNext(question)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
}
