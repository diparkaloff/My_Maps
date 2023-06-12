//
//  MyMapsStandardTextField.swift
//  MyMaps
//
//  
//

import UIKit

class MyMapsStandardTextField: UIView {
    var label = UILabel()
    var textfield = UITextField()
    var bottomView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(labelText: String,
                     isSecured: Bool = false,
                     accessibilityIdentifier: String? = nil,
                     autocorrectionType: UITextAutocorrectionType? = nil) {
        self.init()
        label.text = labelText
        textfield.accessibilityIdentifier = accessibilityIdentifier
        textfield.isSecureTextEntry = isSecured
        if let autocorrectionType = autocorrectionType {
            textfield.autocorrectionType = autocorrectionType
        }
        setupView()
    }
    
    func setupView() {
        
        self.addSubview(label)
        self.addSubview(textfield)
        self.addSubview(bottomView)
        
        label.font = UIFont(name: "Helvetica", size: 25)
        
        bottomView.backgroundColor = #colorLiteral(red: 0.7810183167, green: 0.7763768435, blue: 0.7845870852, alpha: 1)
        
        textfield.borderStyle = .none
        textfield.autocorrectionType = .no
        
        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        textfield.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            textfield.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textfield.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textfield.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textfield.heightAnchor.constraint(equalToConstant: 30),
            
            bottomView.topAnchor.constraint(equalTo: textfield.bottomAnchor, constant: 2),
            bottomView.leadingAnchor.constraint(equalTo: textfield.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: textfield.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            
            self.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

