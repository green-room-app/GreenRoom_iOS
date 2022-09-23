//
//  AnswerViewModel.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/22.
//

import Foundation
import RxSwift

struct Answer {
    let answer: String
    let keywords: [String]
}

final class AnswerViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let trigger: Observable<Bool>
        let keyword: Observable<String>
    }
    
    struct Output {
        let answer: Observable<String?>
        let keywrods: Observable<[String]>
    }
    
    private let answer = BehaviorSubject<String?>(value: nil)
    private let keywords = BehaviorSubject<[String]>(value: [])
    
//    private let question: BehaviorSubject<Question>
    private var question: Question!
    
    init(question: Question){
        self.question = question
//        self.question = BehaviorSubject<Question>(value: question)
    }
    
    func transform(input: Input) -> Output {
        let output = input.trigger.flatMap { _ in
//            guard let self = self else { return }
            return self.fetchAnswer(question: (self.question))
        }
        
        return Output(answer: self.answer.asObserver(), keywrods: self.keywords.asObserver())
    }
}

extension AnswerViewModel {
    
    func fetchAnswer(question: Question) -> Observable<Answer?> {
        return Observable.create { emitter in
            emitter.onNext(Answer(answer: """
                                            앞서 말한 것과 같이 이미 있는 제품의 디자인을 제 시각으로 새롭게 바꾸는 실험을 해보았습니다. 지루한 제품 설명서를 새로 편집해보거나, 명함을 만들어보기도 하고, 좋아하는 브랜드를 정해서 그 브랜드의 철학, 이야기, 가치 등을 이해한 후, 그에 맞는 이미지를 찾아 새로운 배열과 그리드를 이용하여 브랜드 매뉴얼을 만들어 보기도 했습니다. 단편적인 시각물로 사람들과 소통하는 것은 어려운 일이지만 그럼에도 불구하고 깊은 울림과 감동을 주는 디자이너가 될 수 있도록 꾸준한 실험을 통해 발전하고 성장하겠습니다.
                                            """,
                                  keywords: ["새롭게 바꾸는 실험","브랜드 매뉴얼", "꾸준한 실험"]))
            return Disposables.create()
        }
    }
}