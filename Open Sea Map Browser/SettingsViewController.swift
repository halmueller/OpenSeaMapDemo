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
        preferredContentSize = CGSize(width: 300, height: 400)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        let switchSetting = mapViewController?.useOSM
        useOSMSwitch.setOn(switchSetting!, animated: true)

        let mapType = mapViewController?.mapView.mapType
        switch (mapType!) {
        case .standard:
            mapTypeSegmentedController.selectedSegmentIndex = 0
        case .satellite:
            mapTypeSegmentedController.selectedSegmentIndex = 2
        case .hybrid:
            mapTypeSegmentedController.selectedSegmentIndex = 1
        case .satelliteFlyover:
            print("not handled yet")
            mapTypeSegmentedController.selectedSegmentIndex = 0
        case .hybridFlyover:
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

    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true) { () -> Void in

        }
    }

    @IBAction func reloadOpenSeaMapTiles(_ sender: AnyObject) {
        mapViewController?.reloadOpenSeaMapOverlay()
    }

    @IBAction func visitOpenSeaMapWebsite(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.openseamap.org/index.php?id=openseamap&L=1")!)
    }
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapViewController?.mapView.mapType = .standard
        case 1:
            mapViewController?.mapView.mapType = .hybrid
        case 2:
            mapViewController?.mapView.mapType = .satellite
        default:
            mapViewController?.mapView.mapType = .standard
        }
        let mapType = mapViewController?.mapView?.mapType
        UserDefaults.standard.set( Int(mapType!.rawValue),
            forKey:mapStyleKeystring)
    }
    @IBAction func changeOSMOverlay(_ sender: UISwitch) {
        mapViewController?.toggleUseOSM()
    }
}
