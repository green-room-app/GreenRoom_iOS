//
//  MyGreenRoomFooterView.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/05.
//

import UIKit

final class MyGreenRoomFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = "MyGreenRoomFooterView"
    
    private let participantLabel = UILabel().then {
        $0.text = "N명이 참여하고 있습니다."
        $0.textColor = .mainColor
        $0.font = .sfPro(size: 12, family: .Bold)
    }
    
    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = .backgroundGray
        self.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.equalTo(80)
            make.height.equalTo(frame.width * 0.08)
        }
        
        self.addSubview(participantLabel)
        participantLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(profileImageView.snp.top).offset(-5)
        }
    }
    
    func configure(with question: MyPublicQuestion) {
        self.participantLabel.text = "\(question.participants)명이 참여하고 있습니다."
        
        guard let images = question.profileImages else { return }
        configureImageStack(urls: images)
    }
    
    func configureImageStack(urls: [String]) {
        
        
        
        DispatchQueue.global().async {
            
            var images: [UIImage] = []
            
            urls.map { URL(string: $0) }
                .forEach { url in
                    guard let url = url,
                          let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data)else { return }
                    images.append(image)
                }
            
            DispatchQueue.main.async {
                self.profileImageView.setImageStack(images: images)
            }
        }
    }
}
