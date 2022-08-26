//
//  KeywordViewModel.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/01.
//

import UIKit
import RxCocoa
import RxSwift

class KeywordViewModel {
    let filteringObservable = PublishSubject<[Int]>() //필터링된 카테고리 observable
    let selectedQuestionObservable = PublishSubject<[String]>()
    
    let tabelTemp = Observable.of(["테스트면접질문1","테스트면접질문2는 조금 긴 질문 항목입니다. 공백 포함해 35자가 넘어가면","테스트면접질문3"])
    
    var filteringList = [Int]() { // 필터링중인 카테고리 담는 변수
        didSet{
            filteringObservable.onNext(filteringList)
        }
    }
    
    var selectedQuestionTemp = [String]() {
        didSet{
            selectedQuestionObservable.onNext(self.selectedQuestionTemp)
        }
    }
    
}
