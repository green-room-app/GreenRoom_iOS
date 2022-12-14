//
//  GreenRoomViewController.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/01.
//

import UIKit
import RxSwift
import SwiftKeychainWrapper
import RxCocoa
import RxDataSources
import RxViewController

class GreenRoomViewController: BaseViewController {
    
    //MARK: - Properties
    private let viewModel: MainGreenRoomViewModel
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: greenRoomLayout())
    
    private let nextButtonTrigger = PublishRelay<Void>()
    private let prevButtonTrigger = PublishRelay<Void>()
    
    private let greenRoomButton = UIButton().then {
        $0.setTitle("그린룸", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Bold)
        $0.backgroundColor = .clear
    }
    
    private let questionListButton = UIButton().then {
        $0.setTitle("마이 리스트", for: .normal)
        $0.setTitleColor(.customGray, for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Bold)
        $0.backgroundColor = .clear
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "magnifyingglass"), for: .normal)
        $0.titleLabel?.font = .sfPro(size: 20, family: .Bold)
        $0.backgroundColor = .clear
    }
    
    private let bookmarkButton = UIButton().then {
        $0.setImage(UIImage(named: "bookmark"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.titleLabel?.font = .sfPro(size: 20, family: .Bold)
        $0.backgroundColor = .clear
    }
    
    private let underline = UIView().then {
        $0.backgroundColor = .mainColor
        $0.setGradient()
    }
    
    //MARK: - LifeCycle
    init(viewModel: MainGreenRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showTabbar()
        self.configureNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        self.underline.setGradient(
            color1: UIColor(red: 110/255.0, green: 234/255.0, blue: 174/255.0, alpha: 1.0),
            color2: UIColor(red: 87/255.0, green: 193/255.0, blue: 183/255.0, alpha: 1.0))
        super.viewWillLayoutSubviews()
    }
    
    //MARK: - setup/configure
    override func setupAttributes() {
        self.configureNavigationBar()
        self.configureCollecitonView()
    }
    
    override func setupBinding() {
        
        let dataSource = self.dataSource()
        
        let input = MainGreenRoomViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable(),
            mainStatus: Observable.merge(greenRoomButton.rx.tap.map { 0 }, questionListButton.rx.tap.map { 1 }),
            nextButtonTrigger: self.nextButtonTrigger.asObservable(),
            prevButtonTrigger: self.prevButtonTrigger.asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.greenroom.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(GreenRoomSectionModel.Item.self).subscribe(onNext: { [weak self] item in
            guard let self else { return }
            
            switch item {
            case .filtering(interest: let category):
                let viewModel = FilteringViewModel(
                    mode: .filter(id: category.rawValue),
                    fileringRepository: DefaultFilteringRepository())
                let vc = FilteringQuestionViewController(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            case .popular(question: let question):
                let vc = PublicAnswerListViewController(viewModel: PublicAnswerViewModel(
                    id: question.id,
                    scrapRepository: DefaultScrapRepository(),
                    detailGreenRoomRepository: DefaultDetailGreenRoomRepository()))
                self.navigationController?.pushViewController(vc, animated: true)
            case .recent(question: let question):
                let vc = PublicAnswerListViewController(viewModel: PublicAnswerViewModel(
                    id: question.id,
                    scrapRepository: DefaultScrapRepository(),
                    detailGreenRoomRepository: DefaultDetailGreenRoomRepository()))
                self.navigationController?.pushViewController(vc, animated: true)
            case .MyGreenRoom(question: let question):
                guard let id = question.id else { return }
                let vc = PublicAnswerListViewController(viewModel: PublicAnswerViewModel(
                    id: id,
                    scrapRepository: DefaultScrapRepository(),
                    detailGreenRoomRepository: DefaultDetailGreenRoomRepository()))
                self.navigationController?.pushViewController(vc, animated: true)
            case .MyQuestionList(question: let question):
                let vc = PrivateAnswerViewController(
                    viewModel:
                        PrivateAnswerViewModel(
                            id: question.id,
                            repository: DefaultPrivateAnswerRepository()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag)
        
        Observable.merge(
            greenRoomButton.rx.tap.map { 0 },
            questionListButton.rx.tap.map { 1 }
        )
        .subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            let questionColor: UIColor = tag == 0 ? .customGray : .mainColor
            let greenRoomColor: UIColor = tag == 0 ? .mainColor : .customGray
            
            self.questionListButton.setTitleColor(questionColor, for: .normal)
            self.greenRoomButton.setTitleColor(greenRoomColor, for: .normal)
            self.disposeBag = DisposeBag()
            self.setupBinding()
            
            let layout = tag == 0 ? self.greenRoomLayout() : self.myListLayout()
            self.collectionView.setCollectionViewLayout(layout, animated: true)
            self.collectionView.layoutSubviews()
            
        }).disposed(by: disposeBag)
        
        searchButton.rx.tap.subscribe(onNext: {
            let vc = GreenRoomSearchViewController(viewModel: SearchViewModel(repository: DefaultSearchRepository()))
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        bookmarkButton.rx.tap.subscribe(onNext: {
            let viewModel = ScrapViewModel(scrapRepositry: DefaultScrapRepository())
            let vc = ScrapedQuestionViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        iconView.image = UIImage(named: "GreenRoomIcon")?.withRenderingMode(.alwaysOriginal)
        iconView.contentMode = .scaleAspectFit
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iconView)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: bookmarkButton),
            UIBarButtonItem(customView: searchButton)
        ]
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .mainColor
    }
    
    override func configureUI(){
        
        self.view.backgroundColor = .white
        
        let buttonStack = UIStackView(arrangedSubviews: [greenRoomButton,questionListButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalSpacing
        
        self.view.addSubviews([buttonStack, underline, collectionView])
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(27)
            make.leading.equalToSuperview().offset(view.frame.width / 5)
            make.trailing.equalToSuperview().offset(-view.frame.width / 5)
            make.height.equalTo(30)
        }
        
        underline.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(view.frame.width/15)
            make.trailing.equalToSuperview().offset(-view.frame.width/15)
            make.height.equalTo(3)
        }

        collectionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(underline.snp.bottom)
        }
    }
}

//MARK: - collectionView
extension GreenRoomViewController {
    private func configureCollecitonView() {
        
        collectionView.backgroundColor = .white
        [GRFilteringCell.self, PopularQuestionCell.self, RecentQuestionCell.self, MyQuestionListCell.self, MyGreenRoomCell.self]
            .forEach { collectionView.registerCell($0) }
        
        [GRFilteringHeaderView.self, GreenRoomSectionHeader.self, RecentPageFooterView.self, MyGreenRoomFooterView.self]
            .forEach { collectionView.registerResuableView($0) }
    }
    
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<GreenRoomSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<GreenRoomSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            
            switch item {
            case .filtering(interest: let category):
                guard let cell = collectionView.dequeueCell(GRFilteringCell.self, for: indexPath) else { return UICollectionViewCell() }
                cell.configure(title: category.title)
                return cell
                
            case .popular(question: let question):
                guard let cell = collectionView.dequeueCell(PopularQuestionCell.self, for: indexPath) else { return UICollectionViewCell() }
                cell.configure(question: question)
                return cell
                
            case .recent(question: let question):
                guard let cell = collectionView.dequeueCell(RecentQuestionCell.self, for: indexPath) else { return UICollectionViewCell() }
                cell.configure(question: question)
                return cell
            case .MyGreenRoom(question: let question):
                guard let cell = collectionView.dequeueCell(MyGreenRoomCell.self, for: indexPath) else { return UICollectionViewCell() }
                cell.configure(question: question)
                cell.delegate = self
                return cell
            case .MyQuestionList(question: let question):
                guard let cell = collectionView.dequeueCell(MyQuestionListCell.self, for: indexPath) else { return UICollectionViewCell() }
                cell.configure(question: question)
                return cell
            }
        } configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
            
            guard let self else { return UICollectionReusableView() }
            
            switch kind {
            case GRFilteringHeaderView.reuseIdentifier:
                guard let headerView = collectionView.dequeReusableView(GRFilteringHeaderView.self, for: indexPath) else { return UICollectionReusableView() }
                return headerView
            case RecentPageFooterView.reuseIdentifier:
                guard let footerView = collectionView.dequeReusableView(RecentPageFooterView.self, for: indexPath) else { return UICollectionReusableView() }
                footerView.bind(input: self.viewModel.currentBannerPage, pageNumber: 3)
                return footerView
            case MyGreenRoomFooterView.reuseIdentifier:
                guard let footerView = collectionView.dequeReusableView(MyGreenRoomFooterView.self, for: indexPath) else { return UICollectionReusableView() }
                if case let .MyGreenRoom(question) = dataSource[indexPath.section].items[indexPath.row] {
                    footerView.configure(with: question)
                }
                return footerView
            default:
                guard let headerView = collectionView.dequeReusableView(GreenRoomSectionHeader.self, for: indexPath) else { return UICollectionReusableView() }
                headerView.delegate = self
                headerView.type = dataSource[indexPath.section]
                return headerView
            }
        }
    }
    
    //MARK: - MyListLayout
    private func myListLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return sectionIndex == 0 ? self?.generateMyGreenRoomLayout() : self?.generateMyQuestionListLayout()
        }
    }
    
    private func generateMyQuestionListLayout() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
        )
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item])
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.09))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: GreenRoomSectionHeader.reuseIdentifier, alignment: .topLeading)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        return section
        
    }
    //MARK: - GreenRoomLayout
    private func greenRoomLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0: return self?.generateFilteringLayout()
            case 1: return self?.generatePopularQuestionLayout()
            case 2: return self?.generateRecentQuestionLayout()
            default: return self?.generateMyGreenRoomLayout()
            }
        }
    }
    
    private func generateFilteringLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(60),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(3.0),
            heightDimension: .absolute(38)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(14)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: GRFilteringHeaderView.reuseIdentifier, alignment: .topLeading)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 0)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func generatePopularQuestionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.4))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)),
            elementKind: GreenRoomSectionHeader.reuseIdentifier,
            alignment: .top)
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)),
            elementKind: RecentPageFooterView.reuseIdentifier,
            alignment: .bottom
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader,sectionFooter]
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
            
            let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
            
            self?.viewModel.currentBannerPage.onNext(bannerIndex)
        }
        
        return section
    }
    
    private func generateRecentQuestionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.4),
            heightDimension: .fractionalHeight(0.24))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 16,
            bottom: 5,
            trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.09))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: GreenRoomSectionHeader.reuseIdentifier,
            alignment: .topLeading)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    func generateMyGreenRoomLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize:
                NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.2)), subitems: [item])
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)),
            elementKind: GreenRoomSectionHeader.reuseIdentifier,
            alignment: .top)
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)),
            elementKind: MyGreenRoomFooterView.reuseIdentifier,
            alignment: .bottom)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}

//MARK: - RecentHeaderDelegate
extension GreenRoomViewController: RecentHeaderDelegate {
    func didTapViewAllQeustionsButton(type: GreenRoomSectionModel?) {
        
        guard let type else { return }
        
        switch type {
        case .recent:
            let vc = RecentPublicQuestionsViewController(viewModel: RecentPublicQuestionsViewModel(repository: DefaultRecentPublicQuestionRepository()))
            self.navigationController?.pushViewController(vc, animated: true)
        case .MyQuestionList:
            return
//            let vc = RecentPublicQuestionsViewController(viewModel: RecentPublicQuestionsViewModel())
//            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
        
    }
}

extension GreenRoomViewController: MyGreenRoomCellDelegate {
    
    func didTapNext() {
        self.nextButtonTrigger.accept(())
    }
    
    func didTapPrev() {
        self.prevButtonTrigger.accept(())
    }
    
}
