//
//  CreateGRViewModel.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/17.
//

import Foundation
import RxSwift
import RxCocoa


final class CreateGRViewModel: ViewModelType {
    
    let questionService = QuestionService()
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let question: Observable<String>
//        let date: Observable<String>
        let category: Observable<Int>
        let submit: Observable<Void>
    }
    
    struct Output {
//        let categories: Observable<[String]>
        let isValid: Observable<Bool>
        let failMessage: Signal<String>
        let successMessage: Signal<String>
        let comfirmDate: Observable<Int>
    }
    
    private let failMessage = PublishRelay<String>()
    private let successMessage = PublishRelay<String>()
    
    let date = BehaviorRelay<Int>(value: 60 * 24)
    let comfirmDate = BehaviorRelay<Int>(value: 60 * 24)
    
    let categories = Observable<[CreateSection]>.of([CreateSection(items: ["공통","인턴","대외활동","디자인","경영기획","회계","생산/품질관리","인사","마케팅","영업","IT/개발","연구개발(R&D)"])])
    
    func transform(input: Input) -> Output {
        
        input.submit.withLatestFrom(Observable.zip(input.question, input.category.map { String($0) }))
            .flatMapLatest { (question, category) -> Observable<Bool> in
                return self.questionService.uploadQuestionList(categoryId: Int(category)!, question: question)
            }.subscribe { _ in
                self.successMessage.accept("질문 작성이 완료되었어요!")
            } onError: { error in
                self.failMessage.accept(error.localizedDescription)
            }.disposed(by: disposeBag)
        
        let isValid =  Observable.combineLatest(input.question, input.category).map { text, category in
            return !text.isEmpty && text != "면접자 분들은 나에게 어떤 질문을 줄까요?" && category != -1 }
        
        self.comfirmDate.bind(to: date).disposed(by: disposeBag)
        
        return Output( isValid: isValid,
                       failMessage: failMessage.asSignal(),
                       successMessage: successMessage.asSignal(),
                       comfirmDate: comfirmDate.asObservable())
            
    }
    
    func selectDate() {
    }
    
}