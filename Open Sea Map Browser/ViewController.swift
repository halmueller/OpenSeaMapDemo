//
//  ViewController.swift
//  Open Sea Map Browser
//
//  Created by Hal Mueller on 8/5/15.
//  Copyright (c) 2015 Hal Mueller. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let regionDefaultsKeystring = "mapRegion"
let useOpenSeaMapKeystring = "useOpenSeaMap"
let mapStyleKeystring = "mapStyle"

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationFormatter: TTTGeocoordinateFormatter!
    var geocoder: CLGeocoder!
    var useOSM: Bool = true
    var openSeaMapOverlay: MKTileOverlay!
    var openSeaMapTileRenderer: MKTileOverlayRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        openSeaMapOverlay = OpenSeaMapOverlay()
        openSeaMapTileRenderer = MKTileOverlayRenderer(overlay: openSeaMapOverlay)

        useOSM = UserDefaults.standard.bool(forKey: useOpenSeaMapKeystring)
        if useOSM {
            mapView.add(openSeaMapOverlay, level: MKOverlayLevel.aboveRoads)
        }

        if let storedRegion = UserDefaults.standard.regionForKey(regionDefaultsKeystring) {
            mapView.setRegion(storedRegion, animated: true)
        }
        else {
            let demoCenter = CLLocationCoordinate2D(latitude: 54.19, longitude: 12.09)
            let demoRegion = MKCoordinateRegionMake(demoCenter, MKCoordinateSpanMake(0.04, 0.03))
            mapView.setRegion(demoRegion, animated: true)
        }

        if let mapType = MKMapType(rawValue: UInt(UserDefaults.standard.integer(forKey: mapStyleKeystring))) {
            mapView.mapType = mapType
        }
        mapView.showsScale = true

        locationManager = CLLocationManager()
        locationManager.delegate = self;

        let trackingItem = MKUserTrackingBarButtonItem(mapView:mapView)
        _ = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(ViewController.changeMap(_:)))
        toolbarItems?.insert(trackingItem, at: 0)

        locationFormatter = TTTGeocoordinateFormatter.degreesMinutes()

        geocoder = CLGeocoder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        assert(overlay is MKTileOverlay)
        return openSeaMapTileRenderer
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        let status = CLLocationManager.authorizationStatus()

        if status == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (locationFormatter != nil) {
            updateLocationNameForCenterOfMapView(mapView)
        }
        let mapRegion = mapView.region
        UserDefaults.standard.setRegion(mapRegion, forKey: regionDefaultsKeystring)
    }
    // MARK: custom

    func toggleUseOSM () {
        if useOSM {
            useOSM = false
            mapView.remove(openSeaMapOverlay)
        }
        else {
            useOSM = true
            mapView.add(openSeaMapOverlay)
        }
        UserDefaults.standard.set(useOSM, forKey: useOpenSeaMapKeystring)
    }

    func updateLocationNameForCenterOfMapView(_ mapView: MKMapView!) {
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(centerLocation, completionHandler: { (placemarks, error) -> Void in
            var newLocationName = self.locationFormatter.string(from: mapView.centerCoordinate)!
            defer {DispatchQueue.main.async(execute: { () -> Void in
                self.navigationItem.title = newLocationName})}
            if error != nil {
//                print("Error: \(error!.localizedDescription)")
                return
            }
            if let watermarks = placemarks?.filter({$0.ocean != nil || $0.inlandWater != nil}) {
                if watermarks.count > 0 {
//                    print("\(watermarks.count) watermarks")
//                    print("watermarks \(watermarks)")
                    let mark = watermarks[0]
                    if (mark.ocean != nil) {
                        newLocationName = mark.ocean!
                        if (mark.inlandWater != nil) && (mark.inlandWater != mark.ocean) {
                            newLocationName += " (\(mark.inlandWater!))"
                        }
                    }
                    else if (mark.inlandWater != nil) {
                        newLocationName = "\(mark.inlandWater!)"
                    }
                }
            }
        })
    }


    @IBAction func changeMap(_ sender: AnyObject) {
        performSegue(withIdentifier: "settingsSegue", sender: sender)
    }

    func reloadOpenSeaMapOverlay () {
        openSeaMapTileRenderer.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.mapViewController = self
        }
    }
}

