//
//  MapTableViewCell.swift
//  coreLocation2
//
//  Created by Digital on 02/09/21.
//

import UIKit
import CoreLocation
import MapKit



class MapTableViewCell: UITableViewCell {
    var settingDidChange: ((Geotification.EventType) -> Void)? = nil
    var coordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func SegmentedControlChange(_ sender: UISegmentedControl) {
        let eventType:Geotification.EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        self.settingDidChange?(eventType)
    }
    
}
