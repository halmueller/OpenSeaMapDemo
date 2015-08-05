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

    override func viewDidLoad() {
        super.viewDidLoad()

        let openSeaMapOverlay = MKTileOverlay(URLTemplate:"http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
        openSeaMapOverlay.minimumZ = 8
        openSeaMapOverlay.maximumZ = 16
        self.mapView.addOverlay(openSeaMapOverlay, level: MKOverlayLevel.AboveRoads)

        let demoCenter = CLLocationCoordinate2D(latitude: 54.19, longitude: 12.09)
        let demoRegion = MKCoordinateRegionMake(demoCenter, MKCoordinateSpanMake(0.015, 0.028))
        self.mapView.setRegion(demoRegion, animated: true)

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self;
        let trackingItem = MKUserTrackingBarButtonItem(mapView:self.mapView)
        self.toolbarItems = [trackingItem]

        self.locationFormatter = TTTGeocoordinateFormatter.degreesMinutesGeocoordinateFormatter()
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
            self.navigationItem.title = self.locationFormatter.stringFromCoordinate(self.mapView.centerCoordinate)
            self.updateLocationNameForCenterOfMapView(mapView)
        }
    }

    func updateLocationNameForCenterOfMapView(mapView: MKMapView!) {

    }
}

