//
//  QuestionByCategoryCell.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/08.
//

import UIKit

/// 특정 카테고리나 검색에 대한 결과를 보여주는 셀 B2, B3-1
final class QuestionByCategoryCell: BaseCollectionViewCell {
    
    //MARK: - Properteis
    private lazy var profileImageView = UIImageView(frame: .zero).then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = bounds.size.width * 0.12 / 2
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "GreenRoomIcon")
        $0.tintColor = .mainColor
        $0.layer.masksToBounds = false
    }
    
    private lazy var nameLabel = Utilities.shared.generateLabel(text: "박면접", color: .customGray, font: .sfPro(size: 12, family: .Regular))
    private lazy var categoryLabel = Utilities.shared.generateLabel(text: "디자인", color: .black, font: .sfPro(size: 12, family: .Semibold))
    private lazy var participantLabel = Utilities.shared.generateLabel(text: "N명이 참여하고 있습니다.", color: .mainColor, font: .sfPro(size: 12, family: .Bold))
    
    private lazy var questionTextView = UITextView().then {
        $0.backgroundColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.isUserInteractionEnabled = false
        $0.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        $0.setMainLayer()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        $0.attributedText = NSAttributedString(
            string: "대부분의 프로젝트는 프로세스는 어떠하며 어떤 롤이 었나요?대부분의 프로젝트는 프로세스는 어떠하며 어떤 롤이 었나요?대부분의 프로젝트는 프로세스는 어떠하며 어떤 롤이 었나요?대부분의 프로젝트는 프로세스는 어떠하며 어떤 롤이 었나요?",
            attributes: [
                NSAttributedString.Key.paragraphStyle : style,
                 NSAttributedString.Key.font: UIFont.sfPro(size: 14, family: .Regular)
                ]
        )
    }
    
    private lazy var answerLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .sfPro(size: 12, family: .Regular)
        $0.text = "작성 시 동료의 답변을 볼 수 있어요!"
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private lazy var activeLabel = UILabel().then {
        $0.text = "참여 하기"
        $0.font = .sfPro(size: 14, family: .Regular)
        $0.textColor = .customGray
    }
    
    override func configureUI(){
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(categoryLabel)
        self.contentView.addSubview(participantLabel)
        self.contentView.addSubview(questionTextView)
        
        let size = bounds.size.width * 0.12
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(13)
            make.width.height.equalTo(size)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.centerX.equalTo(profileImageView)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
        }
        
        participantLabel.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(6)
        }
        
        
        questionTextView.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel.snp.leading).offset(-4)
            make.trailing.equalToSuperview().offset(-13)
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        let underline = UIView()
        underline.backgroundColor = .backgroundGray
        
        contentView.addSubview(underline)
        underline.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.top.equalTo(questionTextView.snp.bottom).offset(15)
             
        }
        
        contentView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(underline).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(activeLabel)
        activeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
}
