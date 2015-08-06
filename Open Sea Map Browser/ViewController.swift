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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationFormatter: TTTGeocoordinateFormatter!
    var geocoder: CLGeocoder!
    var useOSM: Bool = true
    var openSeaMapOverlay = MKTileOverlay(URLTemplate:"http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.openSeaMapOverlay.minimumZ = 9
        self.openSeaMapOverlay.maximumZ = 17
        if useOSM {
            self.mapView.addOverlay(openSeaMapOverlay, level: MKOverlayLevel.AboveRoads)
        }

        let demoCenter = CLLocationCoordinate2D(latitude: 54.19, longitude: 12.09)
        let demoRegion = MKCoordinateRegionMake(demoCenter, MKCoordinateSpanMake(0.015, 0.028))
        self.mapView.setRegion(demoRegion, animated: true)

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self;

        let trackingItem = MKUserTrackingBarButtonItem(mapView:self.mapView)
        let basemapItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "changeMap:")
        self.toolbarItems?.insert(trackingItem, atIndex: 0)

        self.locationFormatter = TTTGeocoordinateFormatter.degreesMinutesGeocoordinateFormatter()

        self.geocoder = CLGeocoder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        NSLog("no renderer found")
        return nil
    }

    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        let status = CLLocationManager.authorizationStatus()

        if status == CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if (self.locationFormatter != nil) {
            self.updateLocationNameForCenterOfMapView(mapView)
        }
    }
    // MARK: custom

    func toggleUseOSM () {
        if self.useOSM {
            self.useOSM = false
            self.mapView.removeOverlay(self.openSeaMapOverlay)
        }
        else {
            self.useOSM = true
            self.mapView.addOverlay(self.openSeaMapOverlay)
        }
    }
    func updateLocationNameForCenterOfMapView(mapView: MKMapView!) {
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        self.geocoder.cancelGeocode()
        self.geocoder.reverseGeocodeLocation(centerLocation, completionHandler: { (placemarks, error) -> Void in
            if error == nil && placemarks.count > 0 {
                let mark = placemarks[0] as! CLPlacemark
                var newLocationName: String = ""
                println("\(mark)")
                if (mark.ocean != nil) {
                    newLocationName += mark.ocean
                    if (mark.inlandWater != nil) && (mark.inlandWater != mark.ocean) {
                        newLocationName += " (\(mark.inlandWater))"
                    }
                }
                else if (mark.inlandWater != nil) {
                    newLocationName += "\(mark.inlandWater)"
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.title = newLocationName
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.title = self.locationFormatter.stringFromCoordinate(self.mapView.centerCoordinate)
                })
            }
        })
    }
    @IBAction func changeMap(sender: AnyObject) {
        self.performSegueWithIdentifier("settingsSegue", sender: sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.mapViewController = self
        }
    }
}

