//
//  SettingsViewController.swift
//  Open Sea Map Browser
//
//  Created by Hal Mueller on 8/5/15.
//  Copyright (c) 2015 Hal Mueller. All rights reserved.
//

import UIKit
import MapKit

class SettingsViewController: UIViewController {

    var mapViewController: ViewController?
    
    @IBOutlet weak var mapTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var useOSMSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSizeMake(300, 400)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        let switchSetting = mapViewController?.useOSM
        useOSMSwitch.setOn(switchSetting!, animated: true)

        let mapType = mapViewController?.mapView.mapType
        switch (mapType!) {
        case .Standard:
            mapTypeSegmentedController.selectedSegmentIndex = 0
        case .Satellite:
            mapTypeSegmentedController.selectedSegmentIndex = 2
        case .Hybrid:
            mapTypeSegmentedController.selectedSegmentIndex = 1
        case .SatelliteFlyover:
            print("not handled yet")
            mapTypeSegmentedController.selectedSegmentIndex = 0
        case .HybridFlyover:
            print("not handled yet")
            mapTypeSegmentedController.selectedSegmentIndex = 0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in

        }
    }

    @IBAction func reloadOpenSeaMapTiles(sender: AnyObject) {
        mapViewController?.reloadOpenSeaMapOverlay()
    }

    @IBAction func visitOpenSeaMapWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.openseamap.org/index.php?id=openseamap&L=1")!)
    }
    @IBAction func changeMapType(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapViewController?.mapView.mapType = .Standard
        case 1:
            mapViewController?.mapView.mapType = .Hybrid
        case 2:
            mapViewController?.mapView.mapType = .Satellite
        default:
            mapViewController?.mapView.mapType = .Standard
        }
        let mapType = mapViewController?.mapView?.mapType
        NSUserDefaults.standardUserDefaults().setInteger( Int(mapType!.rawValue),
            forKey:mapStyleKeystring)
    }
    @IBAction func changeOSMOverlay(sender: UISwitch) {
        mapViewController?.toggleUseOSM()
    }
}
