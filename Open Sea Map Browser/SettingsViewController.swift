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
        self.preferredContentSize = CGSizeMake(300, 400)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        let switchSetting = self.mapViewController?.useOSM
        self.useOSMSwitch.setOn(switchSetting!, animated: true)

        let mapType = self.mapViewController?.mapView.mapType
        switch (mapType!) {
        case .Standard:
            self.mapTypeSegmentedController.selectedSegmentIndex = 0
        case .Satellite:
            self.mapTypeSegmentedController.selectedSegmentIndex = 2
        case .Hybrid:
            self.mapTypeSegmentedController.selectedSegmentIndex = 1
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
        self.dismissViewControllerAnimated(true) { () -> Void in

        }
    }

    @IBAction func reloadOpenSeaMapTiles(sender: AnyObject) {
        self.mapViewController?.reloadOpenSeaMapOverlay()
    }

    @IBAction func visitOpenSeaMapWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.openseamap.org/index.php?id=openseamap&L=1")!)
    }
    @IBAction func changeMapType(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapViewController?.mapView.mapType = .Standard
        case 1:
            self.mapViewController?.mapView.mapType = .Hybrid
        case 2:
            self.mapViewController?.mapView.mapType = .Satellite
        default:
            self.mapViewController?.mapView.mapType = .Standard
        }
        let mapType = self.mapViewController?.mapView?.mapType
        NSUserDefaults.standardUserDefaults().setInteger( Int(mapType!.rawValue),
            forKey:mapStyleKeystring)
    }
    @IBAction func changeOSMOverlay(sender: UISwitch) {
        self.mapViewController?.toggleUseOSM()
    }
}
