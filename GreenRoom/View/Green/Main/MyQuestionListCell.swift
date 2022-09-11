//
//  MyQuestionListCell.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/09.
//

import UIKit

class MyQuestionListCell: UICollectionViewCell {
    
    static let reuseIedentifier = "MyQuestionListCell"
    
    var question: Question! {
        didSet {
            configureUI()
        }
    }
    
    private lazy var scrapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 12)).then {
        $0.setImage(UIImage(named: "scrap"), for: .normal)
        $0.tintColor = .customGray
        $0.imageView?.tintColor = .customGray
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.mainColor.cgColor
        $0.backgroundColor = .white
        
    }
    private lazy var profileImageView = UIImageView(frame: .zero).then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 35 / 2
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "GreenRoomIcon")
        $0.tintColor = .mainColor
        $0.layer.masksToBounds = false
    }
    
    private let categoryLabel = Utilities.shared.generateLabel(text: "디자인", color: .black, font: .sfPro(size: 12, family: .Semibold))
    
    private lazy var questionTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.textContainerInset = UIEdgeInsets(top: 6, left: -4, bottom: 13, right:13)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        $0.attributedText = NSAttributedString(
            string: "대부분의 프로젝트는 프로세스는 어떠하며 어떤 롤이 었나요?",
            attributes: [
                NSAttributedString.Key.paragraphStyle : style,
                NSAttributedString.Key.font: UIFont.sfPro(size: 16, family: .Regular) ?? .systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ])
        
        $0.isUserInteractionEnabled = false
    }
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Configure
    private func configureUI(){
        
        self.backgroundColor = .white
        
        self.containerView.addSubview(profileImageView)
        self.containerView.addSubview(categoryLabel)
        self.containerView.addSubview(questionTextView)
        self.contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(bounds.size.height*0.18)
            make.leading.equalToSuperview().offset(bounds.size.width * 0.06)
            make.trailing.equalToSuperview().offset(-bounds.size.width * 0.06)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        let size = bounds.width / 15
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(size)
        }
        
        profileImageView.layer.cornerRadius = containerView.bounds.height/6

        self.categoryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }

        self.questionTextView.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel.snp.leading)
            make.top.equalTo(categoryLabel.snp.bottom)
            make.trailing.bottom.equalToSuperview()
        }
        
        self.contentView.addSubview(scrapButton)
        scrapButton.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading)
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(15)
        }
    }
    
    private func configure(){
        guard let category = CategoryID(rawValue: question.category) else { return }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        
        self.questionTextView.attributedText = NSAttributedString(string: question.question, attributes: [NSAttributedString.Key.paragraphStyle : style])
        self.categoryLabel.text = category.title
        self.profileImageView.image = UIImage(named: question.image)
        
    }
}
