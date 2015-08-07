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

        openSeaMapOverlay = MKTileOverlay(URLTemplate:"http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
        openSeaMapOverlay.minimumZ = 9
        openSeaMapOverlay.maximumZ = 17
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
        locationManager = CLLocationManager()
        locationManager.delegate = self;

        let trackingItem = MKUserTrackingBarButtonItem(mapView:mapView)
        let basemapItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "changeMap:")
        toolbarItems?.insert(trackingItem, atIndex: 0)

        locationFormatter = TTTGeocoordinateFormatter.degreesMinutesGeocoordinateFormatter()

        geocoder = CLGeocoder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKTileOverlay {
            return openSeaMapTileRenderer
        }
        NSLog("no renderer found")
        return nil
    }

    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        let status = CLLocationManager.authorizationStatus()

        if status == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
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
            var foundAName = false;
            var newLocationName: String = ""
            if error == nil && placemarks.count > 0 {
                let mark = placemarks[0] as! CLPlacemark
                if (mark.ocean != nil) {
                    foundAName = true
                    newLocationName += mark.ocean
                    if (mark.inlandWater != nil) && (mark.inlandWater != mark.ocean) {
                        newLocationName += " (\(mark.inlandWater))"
                    }
                }
                else if (mark.inlandWater != nil) {
                    foundAName = true
                    newLocationName += "\(mark.inlandWater)"
                }
            }

            if foundAName {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.title = newLocationName
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.title = self.locationFormatter.stringFromCoordinate(mapView.centerCoordinate)
                })
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

