//
//  QuestionsByCategoryViewController.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/08.
//

import UIKit
import RxSwift
import RxDataSources

final class FilteringQuestionViewController: BaseViewController {
    
    var collectionView: UICollectionView!
    var viewModel: FilteringViewModel!
    
    private lazy var notFoundImageView = UIImageView().then {
        $0.image = UIImage(named: "NotFound")?.withRenderingMode(.alwaysOriginal)
    }
    
    private var defaultLabel = UILabel().then {
        $0.text = "등록된 글이 없어요"
        $0.font = .sfPro(size: 12, family: .Semibold)
        $0.textColor = .init(red: 87/255.0, green: 193/255.0, blue: 193/255.0, alpha: 0.5)
    }
    
    init(viewModel: FilteringViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        guard let tabbarcontroller = tabBarController as? MainTabbarController else { return }
        tabbarcontroller.createButton.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let tabbarcontroller = tabBarController as? MainTabbarController else { return }
        tabbarcontroller.createButton.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
     
    override func configureUI() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.collectionView.addSubview(self.notFoundImageView)
        self.notFoundImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(86)
        }
        
        self.view.addSubview(defaultLabel)
        defaultLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notFoundImageView.snp.bottom).offset(20)
        }
    }
    
    override func setupAttributes() {
        configureCollectionView()
    }
    
    override func setupBinding() {
        
        let input = FilteringViewModel.Input(trigger: self.rx.viewWillAppear.asObservable())
        
        viewModel.transform(input: input)
            .publicQuestions.bind(
                to: self.collectionView.rx.items(dataSource: dataSource())
            )
            .disposed(by: disposeBag)
    }
}

//MARK: - CollectionView
extension FilteringQuestionViewController {
    
    private func configureCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width * 0.9, height: view.bounds.height/4)
        layout.headerReferenceSize = CGSize(width: view.frame.size.width , height: view.bounds.height * 0.15)
        layout.minimumLineSpacing = view.bounds.size.height * 0.03
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .backgroundGray
        collectionView.register(InfoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InfoHeaderView.reuseIdentifier)
        collectionView.register(QuestionByCategoryCell.self, forCellWithReuseIdentifier: QuestionByCategoryCell.reuseIdentifier)
    }
    
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<FilteringSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<FilteringSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestionByCategoryCell.reuseIdentifier, for: indexPath) as? QuestionByCategoryCell else { return UICollectionViewCell() }
            
            self.notFoundImageView.isHidden = true
             
            return cell
            
        } configureSupplementaryView: { dataSource, collectionView, kind,
            indexPath in
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InfoHeaderView.reuseIdentifier, for: indexPath) as? InfoHeaderView else {
                
                    return UICollectionReusableView()
            }
            
            header.filterShowing = false
            header.info = dataSource[indexPath.row].header
            return header
        }
    }
}
