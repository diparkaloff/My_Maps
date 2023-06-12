//
//  AlertInfoViewController.swift
//  MyMaps
//
//  
//

import UIKit

class AlertInfoViewController: UIViewController {
    
    var onOkButtonTapped: (() -> ())?
    
    private var blurView = UIVisualEffectView()
    private let alertView = UIView()
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let okButton = ExtendedButton(title: "Ok",
                                  backgroundColor: Colors.mainBlueColor,
                                  titleColor: Colors.whiteColor)
    private let cancelButton = ExtendedButton(title: "cancel",
                                      backgroundColor: .red,
                                      titleColor: Colors.whiteColor)
    private var buttonStackView: UIStackView?
    
    private var titleText: String?
    private var descriptionText: String?
    
    convenience init(title: String, text: String, withOneOkButton: Bool? = false) {
        self.init()
        self.titleText = title
        self.descriptionText = text
        
        if withOneOkButton == true {
            okButton.isHidden = true
            cancelButton.setTitle("ok", for: .normal)
            cancelButton.backgroundColor = Colors.mainBlueColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addTargetToButtons()
        addGestures()
    }
}

//MARK: - Setup views
private extension AlertInfoViewController {
    func setupViews() {
        setupBlurView()
        setupAlertView()
        setupLabels()
        setupConstraints()
    }
    
    func setupBlurView() {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurView)
    }
    
    func setupAlertView() {
        blurView.contentView.addSubview(alertView)
        
        alertView.backgroundColor = Colors.whiteColor
        alertView.layer.cornerRadius = 30
        alertView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLabels() {
        buttonStackView = UIStackView(arrangedSubviews: [okButton, cancelButton])
        
        alertView.addSubview(textLabel)
        alertView.addSubview(titleLabel)
        alertView.addSubview(buttonStackView!)
        
        titleLabel.font = UIFont(name: "Helvetica", size: 25)
        titleLabel.text = titleText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        textLabel.font = UIFont(name: "Avenir Book", size: 20)
        textLabel.text = descriptionText
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        
        buttonStackView?.axis = .horizontal
        buttonStackView?.spacing = 10
        buttonStackView?.distribution = .fillEqually
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            alertView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            alertView.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 150),
            alertView.heightAnchor.constraint(equalToConstant: 250),
            alertView.widthAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10),
            
            textLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -10),
            textLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            buttonStackView!.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20),
            buttonStackView!.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            buttonStackView!.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20)
        ])
    }
}

//MARK: - Setup targets
private extension AlertInfoViewController {
    func addGestures() {
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tapViewGesture)
        
        let tapAlertViewGesture = UITapGestureRecognizer(target: self, action: #selector(alertViewTapped))
        alertView.addGestureRecognizer(tapAlertViewGesture)
    }
    
    func addTargetToButtons() {
        okButton.addTarget(self,
                           action: #selector(okButtonTapped),
                           for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
    }
    
    @objc func okButtonTapped() {
        onOkButtonTapped?()
        dismissController()
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func alertViewTapped() {
        UIView.animate(withDuration: 0.1) {
            self.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { (_) in
            UIView.animate(withDuration: 0.1) {
                self.alertView.transform = .identity
            }
        }
    }
}
