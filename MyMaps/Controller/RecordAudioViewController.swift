//
//  RecordAudioViewController.swift
//  MyMaps
//
//  
//

import UIKit
import Lottie

class RecordAudioViewController: UIViewController {
    
    private let recordAnimation: AnimationView = {
        let view = AnimationView()
        let path = Bundle.main.path(forResource: "audioRecordAnimation", ofType: "json") ?? ""
        view.animation = Animation.filepath(path)
        view.loopMode = .autoReverse
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "record.circle"), for: .normal)
        button.tintColor = .red
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tintColor = Colors.mainBlueColor
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Book", size: 20)
        label.textColor = Colors.whiteColor
        label.text = "hello"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerViewDragView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.whiteColor
        view.alpha = 0
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setTitle("exit", for: .normal)
        button.setTitleColor(Colors.mainBlueColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var interactiveAnimator = UIViewPropertyAnimator()
    
    private var isRecording = false
    private var isShowedTimer = false
    
    private let recordService = RecordAudioService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordService.delegate = self
        setupViews()
        addTargets()
        addGestures()
    }
}

//MARK: - Setup view
private extension RecordAudioViewController {
    func setupViews() {
        view.backgroundColor = Colors.whiteColor
        
        setupRecordAudioForm()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: 40)
    }
    
    func setupRecordAudioForm() {
        let stackView = UIStackView(arrangedSubviews: [recordButton, playAudioButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(exitButton)
        view.addSubview(recordAnimation)
        view.addSubview(containerView)
        containerView.addSubview(containerViewDragView)
        containerView.addSubview(stackView)
        containerView.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            exitButton.heightAnchor.constraint(equalToConstant: 30),
            exitButton.widthAnchor.constraint(equalToConstant: 40),
            
            recordAnimation.topAnchor.constraint(equalTo: exitButton.bottomAnchor),
            recordAnimation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            recordAnimation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            recordAnimation.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -20),
            
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            containerViewDragView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            containerViewDragView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 2),
            containerViewDragView.heightAnchor.constraint(equalToConstant: 5),
            containerViewDragView.widthAnchor.constraint(equalToConstant: 70),
            
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            
            timerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            timerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

//MARK: - Add targets
private extension RecordAudioViewController {
    func addTargets() {
        recordButton.addTarget(self,
                               action: #selector(recordButtonTapped),
                               for: .touchUpInside)
        playAudioButton.addTarget(self,
                                  action: #selector(playAudioButtonTapped),
                                  for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    @objc func recordButtonTapped() {
        isRecording.toggle()
        if isRecording {
            recordButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            recordAnimation.play(completion: nil)
            playAudioButton.isEnabled = false
            recordService.recordNewAudio()
        } else {
            recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
            recordAnimation.stop()
            playAudioButton.isEnabled = true
            recordService.stopRecord()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = .identity
            self.containerViewDragView.alpha = 1
        }
    }
    
    @objc func playAudioButtonTapped() {
        if !recordService.isPlaying {
            playAudioButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            recordService.playRecord()
        } else {
            recordService.stopPlayingRecord()
            playAudioButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = .identity
            self.containerViewDragView.alpha = 1
        }
    }
    
    @objc func exitButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Setup observers and gestures
extension RecordAudioViewController {
    private func addGestures() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        view.addGestureRecognizer(panRecognizer)
    }
    
    @objc func onPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interactiveAnimator.startAnimation()
            interactiveAnimator = UIViewPropertyAnimator(duration: 0.5,
                                                         dampingRatio: .greatestFiniteMagnitude,
                                                         animations: {
                self.containerView.transform = CGAffineTransform(translationX: 0,
                                                                 y: self.containerView.frame.height)
            })
            interactiveAnimator.pauseAnimation()
        case .changed:
            let translation = recognizer.translation(in: self.view)
            interactiveAnimator.fractionComplete = translation.y / 300
            let relativeTranslation = translation.y / (view?.bounds.width ?? 1)
            let progress = max(0, min(1, relativeTranslation))
            self.isShowedTimer = progress > 0.10
        case .ended:
            if isShowedTimer {
                interactiveAnimator.stopAnimation(true)
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = .init(translationX: 0, y: 40)
                } completion: { _ in
                    print("hello")
                }
            } else {
                interactiveAnimator.addAnimations {
                    self.containerView.transform = .identity
                }
                interactiveAnimator.startAnimation()
            }
        default:
            return
        }
    }
}

extension RecordAudioViewController: RecordAudioServiceDelegate {
    func recordDidFinishPlaying() {
        playAudioButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
    
    func getMeterTimer(timer: String) {
        timerLabel.text = timer    }
}
