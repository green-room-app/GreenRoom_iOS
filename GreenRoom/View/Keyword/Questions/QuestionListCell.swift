//
//  QuestionListCell.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/22.
//

import UIKit
import RxSwift

class QuestionListCell: UITableViewCell {
    let disposeBag = DisposeBag()
    
    var isEditMode = false {
        didSet {
            if self.isEditMode {
                self.chevronButton.isHidden = true
                self.checkBox.isHidden = false
            } else {
                self.chevronButton.isHidden = false
                self.checkBox.isHidden = true
            }
        }
    }
    
    var isFindMode = false {
        didSet{
            self.chevronButton.isEnabled = false
            chevronButton.setImage(UIImage(named: "box"), for: .normal)
            chevronButton.tintColor = .customGray
        }
    }
    
    //MARK: - Properties
    override var isSelected: Bool {
        didSet {
            if isEditMode {
                if isSelected {
                    self.checkBox.backgroundColor = .mainColor
                    self.checkBox.layer.borderWidth = 0
                } else {
                    self.checkBox.backgroundColor = .white
                    self.checkBox.layer.borderWidth = 1
                }
            } else {
                if isSelected {
                    self.mainLabel.textColor = .darken
                }else {
                    self.mainLabel.textColor = .black
                }
            }
        }
    }
    
    let mainLabel = UILabel().then {
        $0.text = "여기는 면접질문 항목란입니다."
        $0.numberOfLines = 0
        $0.textColor = .black
        $0.font = .sfPro(size: 20, family: .Regular)
    }
    
    let questionTypeLabel = UILabel().then {
        $0.text = "기본질문"
        $0.font = .sfPro(size: 12, family: .Semibold)
        $0.textColor = .mainColor
        
    }
    
    let categoryLabel = UILabel().then {
        $0.text = "공통"
        $0.font = .sfPro(size: 12, family: .Regular)
        $0.textColor = .customGray
        
        let attributedString = NSMutableAttributedString.init(string: "공통")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange(location: 0, length: "공통".count))
        $0.attributedText = attributedString
    }
    
    let checkBox = UIImageView().then {
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.customGray.cgColor
        $0.image = UIImage(named: "check.white")?.withRenderingMode(.alwaysOriginal)
        $0.isHidden = true
        $0.contentMode = .center
    }
    
    let chevronButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .customGray
        $0.isHidden = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        bind()
        
        self.backgroundColor = .white
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        chevronButton.rx.tap
            .bind(onNext: {
                NotificationCenter.default.post(name: .editQuestionObserver, object: nil, userInfo: ["id" : self.tag])
            }).disposed(by: disposeBag)
    }
    
    //MARK: - ConfigureUI
    func configureUI(){
        self.contentView.addSubview(mainLabel)
        self.mainLabel.snp.makeConstraints{ make in
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(17)
        }
        
        self.contentView.addSubview(questionTypeLabel)
        self.questionTypeLabel.snp.makeConstraints{ make in
            make.leading.equalToSuperview().offset(40)
            make.top.equalTo(self.mainLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-17)
        }
        
        self.contentView.addSubview(categoryLabel)
        self.categoryLabel.snp.makeConstraints{ make in
            make.leading.equalTo(questionTypeLabel.snp.trailing).offset(10)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }
        
        self.contentView.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        self.contentView.addSubview(chevronButton)
        self.chevronButton.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }
}
