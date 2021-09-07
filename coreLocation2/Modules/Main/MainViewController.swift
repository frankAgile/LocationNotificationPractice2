//
//  MainViewController.swift
//  coreLocation2
//
//  Created by Digital on 29/08/21.
//

import UIKit
import CoreLocation
import MapKit

enum PreferencesKeys: String {
    case savedItems
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var geotifications: [Geotification] = []
    lazy var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: "location.fill.viewfinder") , style: .plain, target: self, action: #selector(zoomLocation))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.title = "Geotifications:"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor =  .systemGreen
        self.navigationController?.navigationBar.isTranslucent = false
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadAllGeotifications()
    }
    
    @objc func addTapped() {
        let vc = AddZonesViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc func zoomLocation() {
        mapView.zoomToLocation(mapView.userLocation.location)
    }
    
    func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add($0) }
    }
    
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems.rawValue)
        } catch {
            print("error encoding geotifications")
        }
    }
    
    func add(_ geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(_ geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        title = "Geotifications: \(geotifications.count)"
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude &&
                coord.longitude == geotification.coordinate.longitude &&
                circleOverlay.radius == geotification.radius {
                mapView.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(
                withTitle: "Error",
                message: "Geofencing is not supported on this device!")
            return
        }
        let fenceRegion = geotification.region
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard
                let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier
            else { continue }
            
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
}


extension MainViewController: AddZonesViewControllerDelegate {
    func addZonesViewController(
        _ controller: AddZonesViewController,
        didAddGeotification geotification: Geotification
    ) {
        controller.dismiss(animated: true, completion: nil)
        
        // 1
        geotification.clampRadius(maxRadius:
                                    locationManager.maximumRegionMonitoringDistance)
        add(geotification)
        
        // 2
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
}

// MARK: - Location Manager Delegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 1
        let status = manager.authorizationStatus
        
        // 2
        mapView.showsUserLocation = (status == .authorizedAlways)
        
        // 3
        if status != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            showAlert(withTitle: "Warning", message: message)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: Error
    ) {
        guard let region = region else {
            print("Monitoring failed for unknown region")
            return
        }
        print("Monitoring failed for region with identifier: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

// MARK: - MapView Delegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        guard let geotification = view.annotation as? Geotification else { return }
        stopMonitoring(geotification: geotification)
        remove(geotification)
        saveAllGeotifications()
    }
}

