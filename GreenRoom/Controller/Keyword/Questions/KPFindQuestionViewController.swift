//
//  KeywordViewController.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/01.
//

import UIKit
import SwiftKeychainWrapper
import NaverThirdPartyLogin
import RxSwift
import RxCocoa
import KakaoSDKUser

final class KPFindQuestionViewController: BaseViewController, UITableViewDelegate{
    //MARK: - Properties
    private let viewModel = BaseQuestionsViewModel()
    private var isPaging = false // 현재 페이징진행중인지
    
    private let searchBarView = UISearchBar().then{
        $0.placeholder = "키워드로 검색해보세요!"
        $0.searchBarStyle = .minimal
        $0.searchTextField.borderStyle = .none
        $0.searchTextField.textColor = .customGray
        $0.searchTextField.leftView?.tintColor = .customGray
        $0.layer.borderColor = UIColor.mainColor.cgColor
        $0.layer.borderWidth = 2
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private lazy var filterView = FilterView(viewModel: CategoryViewModel()).then {
        $0.backgroundColor = .white
    }
    
    private var questionListTableView = UITableView().then{
        $0.backgroundColor = .white
        $0.register(QuestionListCell.self, forCellReuseIdentifier: "QuestionListCell")
        $0.showsVerticalScrollIndicator = true
    }
    
    private let practiceInterviewButton = UIButton(type: .system).then{
        $0.backgroundColor = .mainColor
        $0.setTitle("n개의 면접 연습하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Semibold)
        $0.isHidden = true
        $0.layer.cornerRadius = 15
        $0.layer.shadowColor = UIColor.customGray.cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    //MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        hideKeyboardWhenTapped()
        configureNavigationBackButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Method
    func beginPaging(){
        self.isPaging = true
        
        let title = self.searchBarView.text
        let idString = self.viewModel.filteringObservable.value
        guard let nextPage = self.viewModel.referenceObservable.value?.currentPages else { return }
        
        KeywordPracticeService().fetchReferenceQuestions(categoryId: idString, title: title, page: nextPage+1)
            .bind(onNext: { reference in
                self.viewModel.referenceObservable.accept(reference)
                self.isPaging = false
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Bind
    override func setupBinding() {
        viewModel.baseQuestionsObservable
            .bind(to: questionListTableView.rx.items(cellIdentifier: "QuestionListCell", cellType: QuestionListCell.self)) { index, item, cell in
                cell.mainLabel.text = item.question
                cell.categoryLabel.text = item.categoryName
                cell.questionTypeLabel.text = item.questionType
                cell.isFindMode = true
            }.disposed(by: disposeBag)
        
        questionListTableView.rx.modelSelected(ReferenceQuestionModel.self)
            .bind(onNext: { question in
                self.viewModel.selectedQuestionObservable.accept(question)
                self.navigationController?.pushViewController(KPGroupsViewController(viewModel: self.viewModel), animated: true)
            }).disposed(by: disposeBag)
        
        filterView.viewModel.selectedCategoriesObservable
            .map { $0.map { String($0) }.joined(separator: ",") }
            .bind(to: self.viewModel.filteringObservable)
            .disposed(by: disposeBag)
        
        searchBarView.rx.text
            .bind(to: self.viewModel.searchTextObservable)
            .disposed(by: disposeBag)
        
        questionListTableView.rx.didScroll
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let contentHeight = self.questionListTableView.contentSize.height
                let contentOffsetY = self.questionListTableView.contentOffset.y
                let tableViewHeight = self.questionListTableView.frame.height
                
                if contentOffsetY > contentHeight - tableViewHeight {
                    if self.viewModel.hasNextPage.value && !self.isPaging {
                        self.beginPaging()
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: - ConfigureUI
    override func configureUI(){
        self.view.addSubview(searchBarView)
        self.searchBarView.snp.makeConstraints{ make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(36)
        }
        
        self.view.addSubview(self.filterView)
        self.filterView.snp.makeConstraints{ make in
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-42)
            make.top.equalTo(self.searchBarView.snp.bottom).offset(8)
            make.height.equalTo(80)
        }
        
        self.view.addSubview(self.questionListTableView)
        self.questionListTableView.snp.makeConstraints{ make in
            make.top.equalTo(filterView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
    }
}
