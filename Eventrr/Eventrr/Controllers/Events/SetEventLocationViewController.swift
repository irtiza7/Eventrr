//
//  SetEventLocationViewController.swift
//  Eventrr
//
//  Created by Dev on 8/13/24.
//

import UIKit
import MapKit
import CoreLocation

class SetEventLocationViewController: UIViewController {
    
    static let identifier = String(describing: SetEventLocationViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchStackView: UIStackView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var suggestionsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectLocationButton: UIButton!
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let locationSpanMeters: Double = 700
    private var locationSuggestions: [LocationModel] = []
    private var selectedLocation: LocationModel?
    
    // MARK: - Public Properties
    
    public var delegate: CreateEventViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        searchbar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUserInterface()
    }
    
    // MARK: - IBActions
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        clearSuggestions()
        showCurrentLocation()
    }
    
    @IBAction func selectLocationButtonPressed(_ sender: UIButton) {
        guard let selectedLocation else {
            Popups.displayFailure(message: K.StringMessages.pleaseSelectAValidLocation) { [weak self] popup in
                self?.present(popup, animated: true)
            }
            return
        }
        
        delegate?.didSelectEventLocation(location: selectedLocation)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupUserInterface() {
        suggestionsView.isHidden = true
        
        searchbar.searchTextField.textColor = UIColor(named: K.ColorConstants.BlackPrimary.rawValue)
        searchbar.searchTextField.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        
        currentLocationButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        
        selectLocationButton.layer.borderColor = UIColor(named: K.ColorConstants.AccentTertiary.rawValue)?.cgColor
        selectLocationButton.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        selectLocationButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
    }
    
    private func clearSuggestions() {
        locationSuggestions = []
        tableView.reloadData()
        searchbar.endEditing(true)
        suggestionsView.isHidden = true
    }
    
    private func showCurrentLocation() {
        switch CLLocationManager.authorizationStatus() {
    
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        
        case .denied, .restricted:
            Popups.displayFailure(
                message: K.StringMessages.locationPermissionError) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
        
        default:
            return
        }
    }
    
    private func centerMapOnLocation(location: LocationModel) {
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        mapView.addAnnotation(pointAnnotation)
        
        let region = MKCoordinateRegion(
            center: pointAnnotation.coordinate,
            latitudinalMeters: locationSpanMeters,
            longitudinalMeters: locationSpanMeters
        )
        mapView.setRegion(region, animated: true)
    }
}


// MARK: - CLLocationManager Delegate Methods

extension SetEventLocationViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        showCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        locationManager.stopUpdatingLocation()
        
        let coordinates = location.coordinate
        let clLocation = CLLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(clLocation) { placemark, error in
            guard let placemark, placemark.count != 0 else {return}
            
            let locationName = """
            \(placemark[0].name ?? ""), \
            \(placemark[0].locality ?? ""), \
            \(placemark[0].administrativeArea ?? ""), \
            \(placemark[0].country ?? "")
            """
            
            let locationModel = LocationModel(
                name: locationName,
                coordinates: coordinates
            )
            self.selectedLocation = locationModel
            self.centerMapOnLocation(location: locationModel)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[\(SetEventLocationViewController.identifier)] -  Error: \n\(error)")
        Popups.displayFailure(message: K.StringMessages.currentLocationFetchError) { [weak self] popup in
            self?.present(popup, animated: true)
        }
    }
}

// MARK: - SearchBar Delegate Methods

extension SetEventLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 2 else {return}

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region

        let search = MKLocalSearch(request: request)

        search.start { [weak self] response, error in
            guard let response, let self else {return}

            self.locationSuggestions =  response.mapItems.compactMap { (location) -> LocationModel? in
                guard let name = location.placemark.name else {return nil}

                let title = location.placemark.title ?? ""
                let coordinates = CLLocationCoordinate2D(
                    latitude: location.placemark.coordinate.latitude,
                    longitude: location.placemark.coordinate.longitude
                )
                let locationName = "\(name), \(title.split(separator: ",").first ?? "")"

                return LocationModel(
                    name: locationName,
                    coordinates: coordinates
                )
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSuggestions()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        suggestionsView.isHidden = false
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView Delegate Methods

extension SetEventLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locationSuggestions[indexPath.row]
        
        selectedLocation = location
        centerMapOnLocation(location: location)
        clearSuggestions()
    }
}

// MARK: - TableView Datasource Methods

extension SetEventLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: K.EventsStoryboardIdentifiers.locationSuggestionCell,
            for: indexPath
        )
        cell.textLabel?.text = locationSuggestions[indexPath.row].name
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 0.1
        return cell
    }
}

// MARK: - MapView Delegate Methods

extension SetEventLocationViewController: MKMapViewDelegate {}

// MARK: - Delegate Protocol Definations

protocol CreateEventViewControllerDelegate {
    func didSelectEventLocation(location: LocationModel)
}
