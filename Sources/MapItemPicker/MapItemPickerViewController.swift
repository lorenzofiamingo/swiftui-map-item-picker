//
//  MapItemPickerViewController.swift
//
//
//  Created by Lorenzo Fiamingo on 16/02/22.
//

#if os(iOS)

import SwiftUI
import MapKit
import CoreLocation

@available(iOS 15.0, *)
class MapItemPickerViewController:
    UIViewController,
    UISheetPresentationControllerDelegate,
    UIAdaptivePresentationControllerDelegate,
    MKMapViewDelegate,
    UISearchBarDelegate,
    CLLocationManagerDelegate
{
    
    lazy private var locationManager: CLLocationManager = {
        let locationManger = CLLocationManager()
        locationManger.delegate = self
        return locationManger
    }()
    
    lazy var searchNavigationController: UINavigationController = {
        let searchNavigationController = UINavigationController(rootViewController: searchResponseTableViewController)
        searchNavigationController.modalPresentationStyle = .pageSheet
        searchNavigationController.presentationController?.delegate = self
        if let sheet = searchNavigationController.sheetPresentationController {
#if !targetEnvironment(macCatalyst)
            // Work-around to avoid memory leak.
            // The grabber causes a _UIPageSheetPresentationController to prevent the presented view controller from being released after being dismissed.
            //sheet.prefersGrabberVisible = true
#endif
            sheet.delegate = self
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        searchNavigationController.isModalInPresentation = true
        return searchNavigationController
    }()
    
    var onDismiss: ((MKMapItem?) -> Void)?
    
    private lazy var searchCompletionsTableViewController: SearchCompletionsTableViewController = {
        let tableViewController = SearchCompletionsTableViewController(style: .plain)
        tableViewController.searchRegion = searchRegion
        tableViewController.onCompletionSelection = { [weak self] completion in
            guard let self else { return }
            self.searchResponseTableViewController.tableView.isHidden = false
            self.searchController.isActive = false
            self.searchController.searchBar.text = nil //[completion.title, completion.subtitle].joined(separator: ", ")
            
            if let popover = self.searchNavigationController.popoverPresentationController {
                let sheet = popover.adaptiveSheetPresentationController
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = .medium
                }
            }
            
            let searchRequest = MKLocalSearch.Request(completion: completion)
            searchRequest.region = self.searchRegion
            let search = MKLocalSearch(request: searchRequest)
            search.start { [weak self] (response, error) in
                self?.searchResponse = response
            }
        }
        
        tableViewController.tableView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableViewController.tableView.backgroundView = blurEffectView
        tableViewController.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
        return tableViewController
    }()
    
    private lazy var searchResponseTableViewController: SearchResponseTableViewController = {
        let tableViewController = SearchResponseTableViewController(style: .insetGrouped)
        tableViewController.onMapItemSelection = { [weak self] mapItemIndex in
            guard let self else { return }
            self.selectedAnnotationIndex = mapItemIndex
            let annotation = self.annotations[mapItemIndex]
            if !self.mapView.annotations(in: self.mapView.visibleMapRect).contains(annotation as! AnyHashable) {
                self.mapView.showAnnotations([annotation], animated: true)
            }
        }
        
        tableViewController.navigationItem.searchController = searchController
        tableViewController.navigationItem.leftBarButtonItem = cancelButton
        tableViewController.navigationItem.rightBarButtonItem = selectionButton
        tableViewController.navigationItem.hidesSearchBarWhenScrolling = false
        
        tableViewController.tableView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableViewController.tableView.backgroundView = blurEffectView
        tableViewController.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
        tableViewController.onViewWillLayoutSubviews = { [weak self] in
            guard let self else { return }
            self.mapView.frame = self.view.bounds
            let bottomMargin: CGFloat
            if UIDevice.current.userInterfaceIdiom == .pad {
                bottomMargin = 1.115*self.mapView.bounds.height/2
            } else {
                bottomMargin = 1.075*self.mapView.bounds.height/2
            }
            self.mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: bottomMargin, right: 0)
            self.view.layoutIfNeeded()
        }
        
        return tableViewController
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let cancelAction = UIAction { [weak self] _ in
            self?.onDismiss?(nil)
        }
        return UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction, menu: nil)
    }()
    
    private lazy var selectionButton: UIBarButtonItem = {
        let selectionAction = UIAction { [weak self] _ in
            guard let self else { return }
            if
                let index = self.selectedAnnotationIndex,
                let response = self.searchResponse?.mapItems[index]
            {
                self.onDismiss?(response)
            }
        }
        let button = UIBarButtonItem(systemItem: .done, primaryAction: selectionAction, menu: nil)
        button.isEnabled = selectedAnnotationIndex != nil
        return button
    }()
    
    private var searchResponse: MKLocalSearch.Response? {
        didSet {
            searchResponseTableViewController.searchResponse = searchResponse
            annotations = searchResponse?.mapItems.map(\.placemark) ?? []
            if annotations.count > 0 {
                selectedAnnotationIndex = 0
            }
        }
    }
    
    var searchRegion: MKCoordinateRegion = MKCoordinateRegion(.world)  {
        didSet {
            searchCompletionsTableViewController.searchRegion = searchRegion
        }
    }
    
    private var annotations: [MKAnnotation] = [] {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    private var selectedAnnotationIndex: Int? {
        didSet {
            mapView.deselectAnnotation(nil, animated: true)
            if let annotationIndex = selectedAnnotationIndex {
                mapView.selectAnnotation(annotations[annotationIndex], animated: true)
                selectionButton.isEnabled = true
            } else {
                selectionButton.isEnabled = false
            }
        }
    }
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchCompletionsTableViewController)
        searchController.searchResultsUpdater =  searchCompletionsTableViewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Location"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let name = UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [unowned self] (_) in
            self.locationManager.requestWhenInUseAuthorization()
        })
        locationManager.requestWhenInUseAuthorization()
        
        present(searchNavigationController, animated: true)
    }
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        return mapView
    }()
    
    // MARK: UISheetPresentationControllerDelegate
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
    }
    
    // MARK: UIAdaptivePresentationControllerDelegate
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResponseTableViewController.tableView.isHidden = false
        guard let text = searchBar.text else { return }
        self.searchController.isActive = false
        self.searchController.searchBar.text = text
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region =  searchRegion
        searchRequest.naturalLanguageQuery = text
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            self?.searchResponse = response
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResponseTableViewController.tableView.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            searchResponseTableViewController.tableView.isHidden = true
        } else {
            searchResponseTableViewController.tableView.isHidden = false
        }
    }

    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchRegion = mapView.region
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotationIndex = annotations.firstIndex { annotation in
            annotation === view.annotation
        }
        if let annotationIndex = annotationIndex {
            searchResponseTableViewController.tableView.selectRow(at: IndexPath(row: annotationIndex, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let annotationIndex = annotations.firstIndex { annotation in
            annotation === view.annotation
        }
        if let annotationIndex = annotationIndex {
            searchResponseTableViewController.tableView.deselectRow(at: IndexPath(row: annotationIndex, section: 0), animated: true)
        }
    }
    
    private var initalUserLocation: MKUserLocation? {
        didSet {
            if let coordinate = initalUserLocation?.coordinate {
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if initalUserLocation == nil {
            initalUserLocation = userLocation
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
    }
}

#endif
