//
//  ViewController.swift
//  MyMaps
//
//  
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import RxSwift

class MapViewController: UIViewController {
    
    private let mapView = GMSMapView()
    private var buttonsStackView: UIStackView?
    
    private let myPositionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let addMarkerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mappin"), for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let updateLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let requestLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let mapTypeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let showLastPathButton: UIButton = {
        let button = UIButton()
        button.setTitle("show the last path", for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setTitle("exit", for: .normal)
        button.tintColor = Colors.whiteColor
        button.backgroundColor = Colors.mainBlueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userSelfieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        return imageView
    }()
    
    private var selfieImage = UIImage()
    
    private var isAddedMarker = false
    private var isUpdatedLocation = false
    
    private let mapCoordinate = CLLocationCoordinate2D(latitude: 55.753215,
                                                       longitude: 37.622504)
    private var marker: GMSMarker?
    private var manualMarker: GMSMarker?
    private var selfieMarker = GMSMarker()
    private var geocoder = CLGeocoder()
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var locationManager = LocationManager.instanse
    
    private let disposeBag = DisposeBag()
    
    private var allLocations:[CLLocationCoordinate2D] = []
    
    let locationRealm = LocationRealm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.whiteColor
        setupViews()
        configureMap()
        addTargetToButton()
        configureLocation()
    }
}

//MARK: - Setup views
private extension MapViewController {
    func setupViews() {
        setupMapView()
        setupButtons()
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupButtons() {
        buttonsStackView = UIStackView(arrangedSubviews: [myPositionButton,
                                                          addMarkerButton,
                                                          updateLocationButton,
                                                          requestLocationButton,
                                                          mapTypeButton])
        
        guard let buttonsStackView = buttonsStackView else { return }
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 1
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomButtonsStackView = UIStackView(arrangedSubviews: [exitButton, showLastPathButton])
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.distribution = .fillEqually
        bottomButtonsStackView.spacing = 1
        bottomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.addSubview(buttonsStackView)
        mapView.addSubview(bottomButtonsStackView)
        
        NSLayoutConstraint.activate([
            addMarkerButton.heightAnchor.constraint(equalToConstant: 35),
            
            buttonsStackView.widthAnchor.constraint(equalToConstant: 40),
            buttonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            bottomButtonsStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

//MARK: - Add targets and recognizers
private extension MapViewController {
    func addTargetToButton() {
        myPositionButton.addTarget(self,
                                   action: #selector(myPositionButtonTapped),
                                   for: .touchUpInside)
        addMarkerButton.addTarget(self,
                                  action: #selector(addMarkerButtonTapped),
                                  for: .touchUpInside)
        updateLocationButton.addTarget(self,
                                       action: #selector(updateLocationButtonTapped),
                                       for: .touchUpInside)
        requestLocationButton.addTarget(self,
                                        action: #selector(requestLocationButtonTapped),
                                        for: .touchUpInside)
        mapTypeButton.addTarget(self,
                                action: #selector(mapTypeButtonTapped),
                                for: .touchUpInside)
        showLastPathButton.addTarget(self,
                                     action: #selector(showLastPathButtonTapped),
                                     for: .touchUpInside)
        exitButton.addTarget(self,
                             action: #selector(exitButtonTapped),
                             for: .touchUpInside)
    }
    
    @objc func myPositionButtonTapped() {
        mapView.animate(toLocation: mapCoordinate)
    }
    
    @objc func addMarkerButtonTapped() {
        isAddedMarker.toggle()
        if isAddedMarker {
            addMarkerButton.setImage(UIImage(systemName: "mappin.slash"), for: .normal)
            addMarker()
        } else {
            addMarkerButton.setImage(UIImage(systemName: "mappin"), for: .normal)
            removeMarker()
        }
    }
    
    @objc func updateLocationButtonTapped() {
        isUpdatedLocation.toggle()
        if isUpdatedLocation {
            allLocations = []
            
            route?.map = nil
            route = GMSPolyline()
            routePath = GMSMutablePath()
            route?.map = mapView
            
            locationManager.startUpdatingLocation()
            updateLocationButton.setImage(UIImage(systemName: "figure.stand"), for: .normal)
        } else {
            locationManager.stopUpdatingLocation()
            locationRealm.deleteAllLocations()
            locationRealm.addCoordinate(allLocations)
            updateLocationButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        }
    }
    
    @objc func requestLocationButtonTapped() {
        locationManager.requestLocation()
    }
    
    @objc func mapTypeButtonTapped() {
        let frame = buttonsStackView?.convert(mapTypeButton.frame, to: self.view)
        let toVC = MapTypeViewController()
        toVC.containerViewFrame = frame
        toVC.onTypeButton = { [weak self] type in
            self?.mapView.mapType = type
        }
        toVC.modalPresentationStyle = .overCurrentContext
        toVC.modalTransitionStyle = .crossDissolve
        self.present(toVC, animated: true, completion: nil)
    }
    
    @objc func showLastPathButtonTapped() {
        if isUpdatedLocation {
            let toVC = AlertInfoViewController(title: "Need to stop tracking", text: "Stop tracking ?")
            toVC.modalPresentationStyle = .overCurrentContext
            toVC.modalTransitionStyle = .crossDissolve
            toVC.onOkButtonTapped = { [weak self] in
                self?.isUpdatedLocation = false
                self?.locationManager.stopUpdatingLocation()
                self?.locationRealm.deleteAllLocations()
                self?.locationRealm.addCoordinate(self?.allLocations ?? [])
                self?.createPathFromLocations()
            }
            self.present(toVC, animated: true, completion: nil)
        } else {
            createPathFromLocations()
        }
    }
    
    @objc func exitButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Configure map and location
private extension MapViewController {
    func configureMap() {
        configureMapCoordinate()
        mapView.delegate = self
    }
    
    func configureLocation() {
        if let url = UserDefaults.standard.url(forKey: "selfieImage"),
           let image = convertUrlToImage(url: url) {
            selfieImage = image
            userSelfieImageView.image = selfieImage
        }
        _ = locationManager.location.asObservable().bind { [weak self] location in
            if !self!.isUpdatedLocation {
                self?.selfieMarker = GMSMarker(position: location.coordinate)
                self?.selfieMarker.iconView = self?.userSelfieImageView
                self?.selfieMarker.map = self?.mapView
            } else {
                self?.selfieMarker.map = nil
            }
            
            self?.allLocations.append(location.coordinate)
            self?.routePath?.add(location.coordinate)
            self?.route?.path = self?.routePath
            let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
            self?.mapView.animate(to: position)
            
            self?.geocoder.reverseGeocodeLocation(location, completionHandler: { places, error in
                print(places?.first ?? "couldn't find place")
            })
        }.disposed(by: disposeBag)
    }
    
    func configureMapCoordinate() {
        let camera = GMSCameraPosition(target: mapCoordinate, zoom: 17)
        mapView.camera = camera
    }
    
    func configureMapStyle() {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: MapStyleJson.style)
        } catch {
            print(error)
        }
    }
    
    func addMarker() {
        marker = GMSMarker(position: mapCoordinate)
        marker?.map = mapView
        marker?.title = "Moscow"
        marker?.snippet = "Hello"
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func createPathFromLocations() {
        route?.map = nil
        routePath = GMSMutablePath()
        route = GMSPolyline()
        locationRealm.getAllLocations { [weak self] locations in
            for location in locations {
                self?.routePath?.add(location)
                self?.route?.path = routePath
                route?.strokeColor = .blue
                route?.strokeWidth = 10
                route?.map = mapView
            }
            let bounds = GMSCoordinateBounds(path: routePath!)
            self?.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            marker.icon = GMSMarker.markerImage(with: .green)
            self.manualMarker = marker
        }
    }
    
    private func convertUrlToImage(url: URL) -> UIImage? {
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else { return nil }
        
        return image
    }
}
