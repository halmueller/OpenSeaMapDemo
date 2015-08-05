//
//  ViewController.swift
//  Open Sea Map Browser
//
//  Created by Hal Mueller on 8/5/15.
//  Copyright (c) 2015 Hal Mueller. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let openSeaMapOverlay = MKTileOverlay(URLTemplate:"http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
        openSeaMapOverlay.minimumZ = 8
        openSeaMapOverlay.maximumZ = 16
        self.mapView.addOverlay(openSeaMapOverlay, level: MKOverlayLevel.AboveRoads)

        let demoCenter = CLLocationCoordinate2D(latitude: 54.19, longitude: 12.09)
        let demoRegion = MKCoordinateRegionMake(demoCenter, MKCoordinateSpanMake(0.015, 0.028))
        self.mapView.setRegion(demoRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        NSLog("no renderer found")
        return nil
    }
}

