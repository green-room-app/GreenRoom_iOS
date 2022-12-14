//
//  CustomGoalProgressBar.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/26.
//

import UIKit

class CustomProgressBar: UIView {
    //MARK: - Properties
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    private let progressLayer = CAGradientLayer().then{
        $0.colors = [
            UIColor(red: 0.431, green: 0.918, blue: 0.682, alpha: 1).cgColor,
            UIColor(red: 0.341, green: 0.757, blue: 0.718, alpha: 1).cgColor
        ]
        
        $0.locations = [0, 1]
        
        $0.startPoint = CGPoint(x: 0.25, y: 0.5)
        
        $0.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        $0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 15813.06, tx: 0.04, ty: -7906.53))
        
        $0.opacity = 0.9
    }
    
    private lazy var persentLabel = UILabel().then {
        $0.frame = .init(x: 0, y: 0, width: 46, height: 40)
        $0.font = .sfPro(size: 16, family: .Semibold)
        $0.textColor = .white
        
        self.addSubview($0)
    }
    
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .customGray.withAlphaComponent(0.2)
        layer.insertSublayer(self.progressLayer, at: 0)
        layer.borderWidth = 1
        layer.borderColor = UIColor.customGray.cgColor
        layer.cornerRadius = 15
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Draw
    override func draw(_ rect: CGRect) {
        let backgroundMask = CAShapeLayer()
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: 15).cgPath
        layer.mask = backgroundMask
        
        let progressRect = CGRect(origin: .zero,
                                  size: CGSize(width: rect.width * progress, height: rect.height))
        
        progressLayer.frame = progressRect
        progressLayer.speed = 3
        
        progressLayer.bounds = progressRect.insetBy(dx: -0.5*progressRect.width, dy: -0.5*progressRect.height)
        
        progressLayer.position = .zero
        
        if progress >= 0.2 {
            self.persentLabel.text = String(format: "%2.f%%", progress * 100)
            self.persentLabel.center = CGPoint(x: progressRect.width - persentLabel.frame.width/2, y: progressRect.midY)
        } else {
            self.persentLabel.text = ""
        }
        
    }
}
