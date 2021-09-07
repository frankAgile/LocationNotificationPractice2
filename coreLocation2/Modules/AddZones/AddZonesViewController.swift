//
//  AddZonesViewController.swift
//  coreLocation2
//
//  Created by Digital on 02/09/21.
//

import UIKit
import MapKit
import CoreLocation

protocol AddZonesViewControllerDelegate: AnyObject {
    func addZonesViewController(_ controller: AddZonesViewController, didAddGeotification: Geotification)
}

class AddZonesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddLocationButton))
    var radiusTextfieldFlag: Bool?
    var noteTextFieldFlag: Bool?
    var noteTextField: String?
    var radiusTextField = "100"
    var eventTypeFlag: Geotification.EventType?
    weak var delegate: AddZonesViewControllerDelegate?
    var coordinate: CLLocationCoordinate2D?
    var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let location   = UIBarButtonItem(image:UIImage(systemName: "location.fill.viewfinder") , style: .plain, target: self, action: #selector(actionZoomLocationButton))
        
        eventTypeFlag = .onEntry
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(actionBackButton))
        navigationItem.rightBarButtonItems = [addButton,location ]
        navigationItem.title = "Add Geotifications:"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor =  .systemGreen
        self.navigationController?.navigationBar.isTranslucent = false
        addButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @objc func actionBackButton (){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func actionZoomLocationButton (){
        guard let mapView = self.mapView else { return }
        mapView.zoomToLocation(mapView.userLocation.location)
    }
    
    @objc func actionAddLocationButton (){
        guard let mapView = self.mapView else { return }
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField ?? "") ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField ?? ""
        let eventType: Geotification.EventType = eventTypeFlag!
        let geotification = Geotification(
            coordinate: coordinate,
            radius: radius,
            identifier: identifier,
            note: note,
            eventType: eventType)
        delegate?.addZonesViewController(self, didAddGeotification: geotification)
    }
}

extension AddZonesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let mapTableViewCell = UINib(nibName: "MapTableViewCell", bundle: nil)
            self.tableView.register(mapTableViewCell, forCellReuseIdentifier: "MapTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
            cell.settingDidChange = { [weak self] type in
                self?.eventTypeFlag = type
            }
            self.mapView = cell.mapView
            return cell
        }
        else if indexPath.row == 1 {
            let mapTableViewCell = UINib(nibName: "MapConfigTableViewCell", bundle: nil)
            self.tableView.register(mapTableViewCell, forCellReuseIdentifier: "MapConfigTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapConfigTableViewCell", for: indexPath) as! MapConfigTableViewCell
            cell.actionMapConfig = {
                self.radiusTextfieldFlag = cell.radiusTextFieldChange
                self.addButton.isEnabled = self.radiusTextfieldFlag!
                self.radiusTextField = cell.radiusTextField.text!
            }
            return cell
        }
        else {
            let mapTableViewCell = UINib(nibName: "MapDataTableViewCell", bundle: nil)
            self.tableView.register(mapTableViewCell, forCellReuseIdentifier: "MapDataTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapDataTableViewCell", for: indexPath) as! MapDataTableViewCell
            cell.actionMapData = {
                self.noteTextFieldFlag = cell.noteTextFieldChange
                self.noteTextField = cell.noteTextField.text
                self.addButton.isEnabled = self.noteTextFieldFlag ?? false
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        else if indexPath.row == 1 {
            return 44
        }
        else {
            return 44
        }
    }
}
