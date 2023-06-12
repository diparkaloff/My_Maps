//
//  MapTypeViewController.swift
//  MyMaps
//
//  
//

import UIKit
import GoogleMaps

class MapTypeViewController: UIViewController {
    
    var containerViewFrame: CGRect?
    var onTypeButton: ((GMSMapViewType) -> ())?
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .init(rgb: 0x1E90FF)
        return view
    }()
    
    private let typeButtons: [UIButton] = {
        var buttons: [UIButton] = []
        for i in 0...3 {
            let button = UIButton()
            button.setTitleColor(Colors.whiteColor, for: .normal)
            button.titleLabel?.textAlignment = .left
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addRecognizers()
    }
}

//MARK: - Setup view
private extension MapTypeViewController {
    func setupView() {
        view.backgroundColor = .clear
        setupTestView()
        setupTypeButtons()
    }
    
    func setupTestView() {
        view.addSubview(containerView)
        
        guard let containterViewFrame = containerViewFrame else { return }
        
        containerView.frame = .init(x: containterViewFrame.minX - containterViewFrame.width,
                                    y: containterViewFrame.minY + containterViewFrame.height,
                                    width: 70,
                                    height: 120)
    }
    
    func setupTypeButtons() {
        typeButtons
            .enumerated()
            .forEach({ $0.element.setTitle(MapType.types[$0.offset].rawValue, for: .normal) })
        
        let stackView = UIStackView(arrangedSubviews: typeButtons)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        containerView.addSubview(stackView)
        
        stackView.frame = containerView.bounds
    }
}

//MARK: - Add targets and recognizers
private extension MapTypeViewController {
    func addRecognizers() {
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tapViewGesture)
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func typeButtonTapped(_ sender: UIButton) {
        switch MapType(rawValue: sender.titleLabel?.text ?? "normal") {
        case .normal:
            onTypeButton?(.normal)
        case .satellite:
            onTypeButton?(.satellite)
        case .hybrid:
            onTypeButton?(.hybrid)
        case .terrain:
            onTypeButton?(.terrain)
        default:
            onTypeButton?(.normal)
        }
    }
}
