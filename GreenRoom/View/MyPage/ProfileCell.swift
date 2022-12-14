//
//  ProfileCell.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/08/16.
//

import Foundation
import UIKit
import Then
import Kingfisher

protocol ProfileCellDelegate: AnyObject {
    func didTapEditProfileImage()
    func didTapEditProfileInfo(name: String)
}

final class ProfileCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    weak var delegate: ProfileCellDelegate?
    
    var user: User? {
        didSet { self.configure() }
    }
    
    private var editIconView = UIImageView().then {
        $0.image = UIImage(named:"editButton")
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .mainColor
    }
    
    private lazy var profileImageView = ProfileImageView()
    
    private var nameLabel = UILabel().then {
        $0.text = "김면접"
        $0.font = .sfPro(size: 16, family: .Bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private lazy var editButton = UIButton().then {
        $0.setTitle("수정하기 ", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        
        $0.titleLabel?.font = .sfProText(size: 12, family: .Regular)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.textColor = .black
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.imageView?.tintColor = .customGray
        $0.semanticContentAttribute = .forceRightToLeft
    }
    
    //MARK: - Configure
    private func configure() {
        guard let user = user, let category = Category(rawValue: user.categoryID) else {
            return
        }
        
        nameLabel.attributedText = Utilities.shared.textWithIcon(text: " \(user.name)", image: UIImage(named: category.selectedImageName), font: .sfPro(size: 12, family: .Regular), textColor: .black, imageColor: nil, iconPosition: .left)
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 4
        profileImageView.setImage(at: user.profileImage)
    }
    
    override func configureUI(){

        contentView.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 15
        contentView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel,editButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        
        contentView.addSubviews([profileImageView, editIconView, stackView])
        profileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(90)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(33)
        }
        
        editIconView.snp.makeConstraints { make in
            make.width.height.equalTo(26)
            make.trailing.equalTo(profileImageView.snp.trailing)
            make.bottom.equalTo(profileImageView.snp.bottom)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.height.equalTo(60)
            make.width.equalTo(172)
        }
    }
    
    override func bind() {
        profileImageView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didTapEditProfileImage()
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                guard let name = self.user?.name else { return }
                self.delegate?.didTapEditProfileInfo(name: name)
            }
            .disposed(by: disposeBag)
    }
}
