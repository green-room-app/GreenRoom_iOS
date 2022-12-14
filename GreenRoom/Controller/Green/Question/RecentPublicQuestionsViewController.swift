//
//  DetailRecentQuestionViewController.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class RecentPublicQuestionsViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    private let viewModel: RecentPublicQuestionsViewModel
    
    init(viewModel: RecentPublicQuestionsViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBackButtonItem()
        self.hideTabbar()
    }
    
    override func configureUI() {
        self.view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupAttributes() {
        configureCollectionView()
    }
    
    override func setupBinding() {
        
        let output = self.viewModel.transform(input: RecentPublicQuestionsViewModel.Input())
        
        output.recent.bind(to: collectionView.rx.items(dataSource: dataSource())).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(GreenRoomSectionModel.Item.self)
            .withUnretained(self)
            .subscribe(onNext: { onwer, item in
                if case .recent(let question) = item {
                    
                    let viewModel = PublicAnswerViewModel(id: question.id, scrapRepository: DefaultScrapRepository(), detailGreenRoomRepository: DefaultDetailGreenRoomRepository())

                    let vc = PublicAnswerListViewController(viewModel: viewModel)
                    onwer.navigationController?.pushViewController(vc, animated: false)
                }
            }).disposed(by: disposeBag)
    }
}

extension RecentPublicQuestionsViewController {
    
    private func configureCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height/8)
        layout.headerReferenceSize = CGSize(width: view.bounds.width , height: view.bounds.height * 0.22)
        layout.minimumLineSpacing = -1
        return layout
    }
    
    private func configureCollectionView() {
        self.collectionView.backgroundColor = .white
        collectionView.registerCell(PublicQuestionsCell.self)
        collectionView.registerResuableView(InfoHeaderView.self)
    }
    
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<GreenRoomSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<GreenRoomSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicQuestionsCell.reuseIdentifier, for: indexPath) as? PublicQuestionsCell else { return UICollectionViewCell() }
            
            if case let .recent(question) = item {
                cell.configure(question: question)
            }
            return cell
            
        } configureSupplementaryView: { dataSource, collectionView, kind,
            indexPath in
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: InfoHeaderView.reuseIdentifier, withReuseIdentifier: InfoHeaderView.reuseIdentifier, for: indexPath) as? InfoHeaderView else {
                return UICollectionReusableView()
            }
            header.filterShowing = true
            header.info = Info(title: "최근 질문", subTitle: "방금 올라온 모든 질문리스트를 보여드려요!\n질문에 참여 시 동료들의 모든 답변을 확인할 수 있어요 :)")
            return header
        }
    }
}
