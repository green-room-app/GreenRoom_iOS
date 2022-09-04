//
//  Utils.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/08/17.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    
    private init() { }
    
    enum iconPosition {
        case left
        case right
    }
    
    func textWithIcon(text: String, image: UIImage?,font: UIFont = .sfProText(size: 17, family: .Regular), textColor: UIColor = .customGray, imageColor: UIColor?,iconPosition: iconPosition) -> NSMutableAttributedString{
  
        let attributedString = NSMutableAttributedString(string:"")
        
        let imageAttachment = NSTextAttachment()
        
        if imageColor == nil {
            imageAttachment.image = image?.withRenderingMode(.alwaysOriginal)
        } else {
            imageAttachment.image = image?.withTintColor(imageColor!)
        }
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 21, height: 21)
        
        let str = NSMutableAttributedString(string: "\(text)  ",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        switch iconPosition {
        case .left:
            attributedString.append(NSAttributedString(attachment:imageAttachment))
            attributedString.append(str)
        case .right:
            attributedString.append(str)
            attributedString.append(NSAttributedString(attachment:imageAttachment))
        }
        
        return attributedString
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        
        let attributedString = NSMutableAttributedString(string: text)

        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points

        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.attributedText = attributedString

        label.sizeToFit()
        return label.frame.height
    }
    
    func generateProfileImage(frame: CGRect) -> UIImageView {
        let imageView = UIImageView()
        imageView.tintColor = .customGray
        imageView.contentMode = .scaleAspectFill
        imageView.frame = frame
        imageView.layer.cornerRadius = frame.width / 2
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        
        return imageView
    }
    
    func generateLabel(text: String, color: UIColor?,font: UIFont?) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.font = font
            $0.numberOfLines = 0
            $0.textColor = color
        }
    }
}
