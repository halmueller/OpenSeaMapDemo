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

        useOSM = NSUserDefaults.standardUserDefaults().boolForKey(useOpenSeaMapKeystring)
        if useOSM {
            mapView.addOverlay(openSeaMapOverlay, level: MKOverlayLevel.AboveRoads)
        }

        if let storedRegion = NSUserDefaults.standardUserDefaults().regionForKey(regionDefaultsKeystring) {
            mapView.setRegion(storedRegion, animated: true)
        }
        else {
            let demoCenter = CLLocationCoordinate2D(latitude: 54.19, longitude: 12.09)
            let demoRegion = MKCoordinateRegionMake(demoCenter, MKCoordinateSpanMake(0.04, 0.03))
            mapView.setRegion(demoRegion, animated: true)
        }

        if let mapType = MKMapType(rawValue: UInt(NSUserDefaults.standardUserDefaults().integerForKey(mapStyleKeystring))) {
            mapView.mapType = mapType
        }
        mapView.showsScale = true

        locationManager = CLLocationManager()
        locationManager.delegate = self;

        let trackingItem = MKUserTrackingBarButtonItem(mapView:mapView)
        _ = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "changeMap:")
        toolbarItems?.insert(trackingItem, atIndex: 0)

        locationFormatter = TTTGeocoordinateFormatter.degreesMinutesGeocoordinateFormatter()

        geocoder = CLGeocoder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        assert(overlay is MKTileOverlay)
        return openSeaMapTileRenderer
    }

    func mapViewWillStartLocatingUser(mapView: MKMapView) {
        let status = CLLocationManager.authorizationStatus()

        if status == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (locationFormatter != nil) {
            updateLocationNameForCenterOfMapView(mapView)
        }
        let mapRegion = mapView.region
        NSUserDefaults.standardUserDefaults().setRegion(mapRegion, forKey: regionDefaultsKeystring)
    }
    // MARK: custom

    func toggleUseOSM () {
        if useOSM {
            useOSM = false
            mapView.removeOverlay(openSeaMapOverlay)
        }
        else {
            useOSM = true
            mapView.addOverlay(openSeaMapOverlay)
        }
        NSUserDefaults.standardUserDefaults().setBool(useOSM, forKey: useOpenSeaMapKeystring)
    }

    func updateLocationNameForCenterOfMapView(mapView: MKMapView!) {
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(centerLocation, completionHandler: { (placemarks, error) -> Void in
            var newLocationName = self.locationFormatter.stringFromCoordinate(mapView.centerCoordinate)!
            defer {dispatch_async(dispatch_get_main_queue(), { () -> Void in
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


    @IBAction func changeMap(sender: AnyObject) {
        performSegueWithIdentifier("settingsSegue", sender: sender)
    }

    func reloadOpenSeaMapOverlay () {
        openSeaMapTileRenderer.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.mapViewController = self
        }
    }
}

