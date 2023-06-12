//
//  LoginViewController.swift
//  MyMaps
//
//  
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Colors.whiteColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "MyMap"
        label.textColor = Colors.mainBlueColor
        label.font = UIFont(name: "Geeza Pro Bold", size: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton = ExtendedButton(title: "Log in",
                                             backgroundColor: Colors.whiteColor,
                                             titleColor: .black,
                                             isShadow: true,
                                             accessibilityIdentifier: "loginButton")
    private let registrationButton = ExtendedButton(title: "Sign up",
                                                    backgroundColor: Colors.mainBlueColor,
                                                    titleColor: Colors.whiteColor,
                                                    isShadow: false,
                                                    accessibilityIdentifier: "registrationButton")
    
    private let loginStandardTextField = MyMapsStandardTextField(labelText: "Login",
                                                                 accessibilityIdentifier: "loginTF",
                                                                 autocorrectionType: .no)
    private let passwordStandardTextField = MyMapsStandardTextField(labelText: "Password",
                                                                    isSecured: true,
                                                                    accessibilityIdentifier: "passwordTF",
                                                                    autocorrectionType: .no)
    
    private var isKeyboardShown = false
    private var isInputFilled = false
    
    private let userDataRealm = UserDataRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizer()
        setupViews()
        addTargetToButtons()
        configureLoginBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
}

// MARK: - Setup views
private extension LoginViewController {
    func setupViews() {
        setupScrollView()
        setupAuthForm()
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupAuthForm() {
        let loginFormStackView = UIStackView(arrangedSubviews: [loginStandardTextField,
                                                                passwordStandardTextField])
        loginFormStackView.axis = .vertical
        loginFormStackView.spacing = 10
        loginFormStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsStackView = UIStackView(arrangedSubviews: [loginButton, registrationButton])
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 20
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(logoLabel)
        scrollView.addSubview(loginFormStackView)
        scrollView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100),
            
            loginFormStackView.topAnchor.constraint(equalTo: logoLabel.topAnchor, constant: 100),
            loginFormStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginFormStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            buttonsStackView.topAnchor.constraint(equalTo: loginFormStackView.bottomAnchor, constant: 50),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
    
    func presentAlertInfo(title: String, text: String, withOneOkButton: Bool) {
        DispatchQueue.main.async {
            let toVC = AlertInfoViewController(title: title,
                                               text: text,
                                               withOneOkButton: withOneOkButton)
            toVC.modalPresentationStyle = .overCurrentContext
            toVC.modalTransitionStyle = .crossDissolve
            self.present(toVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Setup observers and gestures recognizer
private extension LoginViewController {
    func addTapGestureRecognizer() {
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardGesture)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHiden),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    func configureLoginBindings() {
        _ = Observable.combineLatest(loginStandardTextField.textfield.rx.text, passwordStandardTextField.textfield.rx.text).map { login, password in
            return !(login ?? "").isEmpty && !(password ?? "").isEmpty
        }.bind { [weak self] inputFilled in
            self?.isInputFilled = inputFilled
        }
    }
    
    @objc func keyboardWillBeShown(notification: Notification) {
        guard !isKeyboardShown else { return }
        let info = notification.userInfo as NSDictionary?
        let keyboardSize = (info?.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize?.height ?? 0.0, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        isKeyboardShown = true
    }
    
    @objc func keyboardWillBeHiden() {
        guard isKeyboardShown else { return }
        
        let contentInsets = UIEdgeInsets.zero
        
        scrollView.contentInset = contentInsets
        isKeyboardShown = false
    }
    
    @objc func hideKeyboard() {
        scrollView.endEditing(true)
    }
}

// MARK: - Setup targets
private extension LoginViewController {
    func addTargetToButtons() {
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        registrationButton.addTarget(self,
                                     action: #selector(registrationButtonTapped),
                                     for: .touchUpInside)
    }
    
    @objc func loginButtonTapped() {
        guard
            let login = loginStandardTextField.textfield.text,
            let password = passwordStandardTextField.textfield.text,
            isInputFilled == true
        else { presentAlertInfo(title: "Warning",
                                text: "Login or password is wrong",
                                withOneOkButton: true)
            return
        }

        userDataRealm.getSpecificUserData(for: login) { [weak self] userData in
            guard
                let userData = userData
            else { self?.presentAlertInfo(title: "Warning",
                                    text: "Login or password is wrong",
                                    withOneOkButton: true)
                return
            }
            if password == userData.password {
                let toVC = MainViewController()
                toVC.name = login
                navigationController?.pushViewController(toVC, animated: true)
            } else {
                self?.presentAlertInfo(title: "Warning",
                                        text: "Login or password is wrong",
                                        withOneOkButton: true)
            }
        }
    }
    
    @objc func registrationButtonTapped() {
        let toVC = RegistrationViewController()
        navigationController?.pushViewController(toVC, animated: true)
    }
}

