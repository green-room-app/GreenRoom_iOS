//
//  MyQuestionAnswerViewController.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/22.
//

import UIKit
import RxSwift

///개인 질문에 대한 답변을 설정하는
final class PrivateAnswerViewController: BaseViewController {
    
    //MARK: - Properties
    private var mode: PrivateAnswerMode = .unWritten {
        didSet {
            switch self.mode {
            case .edit:
                self.setEditMode()
            case .written(let answer):
                self.setWrittenMode(answer: answer)
            case .unWritten:
                self.setUnwrittenMode()
            }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: self.mode == .edit ? doneButton : deleteButton
            )
        }
    }
    
    private var viewModel: PrivateAnswerViewModel
    private var headerView = AnswerHeaderView(frame: .zero)
    private var keywordView: KeywordRegisterView!
    
    private lazy var defaultView = UIImageView().then {
        $0.image = UIImage(named: "NotFound")?.withRenderingMode(.alwaysOriginal)
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = false
    }
    
    private var defaultLabel = UILabel().then {
        $0.text = "등록된 글이 없어요"
        $0.font = .sfPro(size: 12, family: .Semibold)
        $0.textColor = .init(red: 87/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1.0)
    }
    
    private var answerPostButton = UIButton().then {
        $0.backgroundColor = .mainColor
        $0.setTitle("답변 작성하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Bold)
        $0.layer.cornerRadius = 8
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "trash"), for: .normal)
        $0.imageView?.tintColor = .white
    }
    
    private let doneButton = UIButton().then {
        $0.setTitle("확인",for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private lazy var answerTextView = UITextView().then {
        $0.isEditable = true
        $0.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        $0.sizeToFit()
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.mainColor.cgColor
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 2
        $0.isScrollEnabled = true
        $0.attributedText = viewModel.placeholder.addLineSpacing(foregroundColor: .lightGray)
    }
    
    //MARK: - Lifecycle
    init(viewModel: PrivateAnswerViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.configureNavigationBackButtonItem(tintColor: .white)
        self.hideTabbar()
    }
    
    //MARK: - Configure
    override func configureUI() {
        super.configureUI()
        
        self.keywordView = KeywordRegisterView(viewModel: RegisterKeywordViewModel(id: viewModel.id, answerType: .private, repository: DefaultRegisterKeywordRepository()))
        
        let headerHeight = UIScreen.main.bounds.height * 0.3
        
        self.view.addSubviews([headerView, defaultView, defaultLabel, answerPostButton])
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        defaultView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        defaultLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(defaultView.snp.bottom).offset(20)
        }
        
        answerPostButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupAttributes() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: self.mode == .edit ? doneButton : deleteButton
        )
    }
    
    override func setupBinding() {
        
        answerTextView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe(onNext: { onwer, _ in
                if onwer.answerTextView.text == self.viewModel.placeholder {
                    onwer.answerTextView.text = nil
                    onwer.answerTextView.textColor = .black
                }
            }).disposed(by: disposeBag)
        
        answerTextView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { onwer, _ in
                if onwer.answerTextView.text.isEmpty || self.answerTextView.text == nil {
                    onwer.answerTextView.attributedText = onwer.viewModel.placeholder.addLineSpacing(foregroundColor: .lightGray)
                }
                
            }).disposed(by: disposeBag)
        
        let question = answerTextView.rx.didEndEditing
            .asObservable()
            .withLatestFrom(answerTextView.rx.text.orEmpty.asObservable())
            .distinctUntilChanged()
            .filter { !$0.isEmpty }

        let input = PrivateAnswerViewModel.Input(
            text: question,
            keywords: keywordView.output.registeredKeywords.asObservable(),
            deleteButtonTrigger: deleteButton.rx.tap.flatMap { self.showAlert(title: "질문 삭제", message: "마이질문을 삭제하시겠습니까?\n한 번 삭제 후 되돌릴 수 없습니다.")},
            doneButtonTrigger: self.doneButton.rx.tap.asObservable())
        
        doneButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { onwer, _ in
                onwer.answerTextView.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        let output = viewModel.transform(input: input)
        
        answerPostButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { onwer, _ in
                onwer.mode = .edit
            }).disposed(by: disposeBag)
        
        output.answer
            .withUnretained(self)
            .subscribe(onNext: { onwer, answer in
                
                onwer.headerView.question = QuestionHeader(id: answer.id, question: answer.question, categoryName: answer.categoryName, groupCategoryName: answer.groupCategoryName)
                
                if let answer = answer.answer {
                    onwer.mode = .written(answer: answer)
                } else {
                    onwer.mode = .unWritten
                }
                
            }).disposed(by: disposeBag)
        
        output.successMessage
            .withUnretained(self)
            .emit(onNext: { onwer, message in
                let alert = onwer.comfirmAlert(title: "등록 완료", subtitle: message) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                onwer.present(alert, animated: true)
            }).disposed(by: disposeBag)
        
        output.failMessage
            .withUnretained(self)
            .emit(onNext: { onwer, message in
            let alert = self.comfirmAlert(title: "등록 실패", subtitle: message) { _ in
                
            }
            onwer.present(alert, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func configureTextViewLayout() {
        
        self.view.addSubview(keywordView)
        keywordView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom).offset(15)
            make.height.equalTo(115)
        }
        
        self.view.addSubview(answerTextView)
        answerTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(keywordView.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - SetMode
extension PrivateAnswerViewController {
    
    private func setWrittenMode(answer: String) {
        self.defaultView.isHidden = true
        self.defaultLabel.isHidden = true
        self.answerPostButton.isHidden = true
        
        self.answerTextView.attributedText = answer.addLineSpacing(foregroundColor: .black)
        self.configureTextViewLayout()
    }
    
    private func setUnwrittenMode() {
        self.defaultView.isHidden = false
        self.defaultLabel.isHidden = false
        self.answerPostButton.isHidden = false
    }
    
    private func setEditMode() {
        self.defaultView.isHidden = true
        self.defaultLabel.isHidden = true
        self.answerPostButton.isHidden = true
        
        self.configureTextViewLayout()
    }
}
