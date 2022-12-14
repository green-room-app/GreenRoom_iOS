//
//  ScrapedQuestionViewController.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/11.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ScrapedQuestionViewController: BaseViewController {
    
    //MARK: - Properties
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureCollectionViewLayout())
    
    private let viewModel: ScrapViewModel
    
    var editMode: Bool = false {
        didSet {
            self.collectionView.reloadData()
            self.deleteButton.isHidden = !editMode
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editMode ? cancelButton : editButton)
        }
    }
    
    private lazy var editButton = UIButton().then {
        $0.setTitle("편집", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
    }
    
    private lazy var cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
    }
    
    private lazy var deleteButton = UIButton().then {
        $0.backgroundColor = .mainColor
        $0.layer.cornerRadius = 8
        $0.setTitle("질문 삭제", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Regular)
    }
    
    //MARK: - LifeCycle
    init(viewModel: ScrapViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureUI() {
        self.view.backgroundColor = .white
        
        self.view.addSubviews([collectionView, deleteButton])
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(52)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        self.deleteButton.isHidden = true
        self.hideTabbar()
    }
    
    override func setupAttributes() {
        self.configureCollectionView()
    }
    
    override func setupBinding() {
        editButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.editMode = true
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(
            cancelButton.rx.tap.asObservable(),
            deleteButton.rx.tap.asObservable()
        )
        .subscribe(onNext: { [weak self] _ in
            self?.editMode = false
        }).disposed(by: disposeBag)
        
        let input = ScrapViewModel.Input(buttonTab: deleteButton.rx.tap.asObservable())
        
        let output = self.viewModel.transform(input: input)
        output.scrap
            .bind(to: collectionView.rx.items(dataSource: dataSource()))
            .disposed(by: disposeBag)
    }
}

//MARK: - CollectionView
extension ScrapedQuestionViewController {
    private func configureCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = view.bounds.width * 0.42
        
        let margin = view.bounds.width * 0.05
        layout.itemSize = CGSize(width: width, height: view.bounds.height * 0.3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: margin * 3, right: margin)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: view.bounds.height*0.14)
        
        return layout
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .backgroundGray
        collectionView.allowsMultipleSelection = true
        
        collectionView.registerCell(ScrapViewCell.self)
        collectionView.register(InfoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InfoHeaderView.reuseIdentifier)
    }
    
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<ScrapSectionModel> {
        
        return RxCollectionViewSectionedReloadDataSource<ScrapSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            guard let cell = collectionView.dequeueCell(ScrapViewCell.self, for: indexPath) else { return UICollectionViewCell() }
            cell.editMode = self.editMode
            cell.question = item
            cell.delegate = self
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InfoHeaderView.reuseIdentifier, for: indexPath) as? InfoHeaderView else {
                return UICollectionReusableView()
            }
            header.filterShowing = false
            header.info = Info(title: "관심 질문", subTitle: "관심을 표시한 모든 질문을 보여드려요!\n질문에 참여 시 동료들의 모든 답변을 확인할 수 있어요 :)")
            return header
        }
    }
}

//MARK: - ScrapViewCellDelegate
extension ScrapedQuestionViewController: ScrapViewCellDelegate {
    
    func didSelectScrapCell(isSelected: Bool, question: GreenRoomQuestion) {
        if isSelected {
            self.viewModel.selectedIndexesObservable
                .accept(self.viewModel.selectedIndexesObservable.value + [question.id])
        } else {
            self.viewModel.cancelIndexObservable.onNext(question.id)
        }
    }
    
}
