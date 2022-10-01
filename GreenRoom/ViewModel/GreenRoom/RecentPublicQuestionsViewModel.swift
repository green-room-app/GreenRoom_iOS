//
//  GRDetailViewModel.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/11.
//

import Foundation
import RxSwift

final class RecentPublicQuestionsViewModel: ViewModelType {
    
    private var publicQuestionService = PublicQuestionService()
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let trigger: Observable<Bool>
    }
    
    struct Output {
        let recent: Observable<[GreenRoomSectionModel]>
    }
    
    func transform(input: Input) -> Output {
         
        let recent = input.trigger.flatMap { _ in
            self.publicQuestionService.fetchRecentPublicQuestions()
        }.map { questions in
            [GreenRoomSectionModel.recent(items:
                questions.map{ GreenRoomSectionModel.Item.recent(question: $0) } )]
        }
  
        return Output(recent: recent)
    }

}