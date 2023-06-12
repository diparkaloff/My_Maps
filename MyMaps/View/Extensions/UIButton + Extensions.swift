//
//  UIButton + Extensions.swift
//  MyMaps
//
//  
//

import UIKit

protocol ButtonExtensionProtocol { }

extension ButtonExtensionProtocol where Self: UIButton {
    init(title: String?,
         backgroundColor: UIColor,
         titleColor: UIColor,
         font: UIFont? = UIFont(name: "Avenir", size: 20),
         isShadow: Bool = false,
         cornerRadius: CGFloat = 4,
         accessibilityIdentifier: String? = nil) {
        self.init(type: .system)
        self.accessibilityIdentifier = accessibilityIdentifier
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        
        self.layer.cornerRadius = cornerRadius
        
        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.layer.shadowOpacity = 0.2
        }
    }
}

class ExtendedButton: UIButton, ButtonExtensionProtocol {
    
}
