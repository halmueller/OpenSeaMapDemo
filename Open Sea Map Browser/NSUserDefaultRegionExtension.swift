//
//  NSUserDefaultRegionExtension.swift
//  Open Sea Map Browser
//
//  from https://gist.github.com/bluwave/f8049f53a83f1323fcc4#file-nsuserdefaultregionextension
//  Author: G Richards (bluwave)
//

import UIKit
import MapKit

extension UserDefaults {
    func setRegion(_ region:MKCoordinateRegion? , forKey:String)
    {
        if let r = region {
            let data:[String:AnyObject] = ["lat":r.center.latitude as AnyObject, "lon":r.center.longitude as AnyObject, "latDelta":r.span.latitudeDelta as AnyObject, "lonDelta":r.span.longitudeDelta as AnyObject]
            self.set(NSKeyedArchiver.archivedData(withRootObject: data), forKey: forKey)
        }
    }

    func regionForKey(_ key:String?) -> MKCoordinateRegion?
    {
        if let k = key
        {
            let possibleData = UserDefaults.standard.object(forKey: k) as! Data?
            if let data = possibleData {

                var object:[String:AnyObject] = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: AnyObject]

                let lat = object["lat"] as! CLLocationDegrees
                let lon = object["lon"] as! CLLocationDegrees
                let latDelta = object["latDelta"] as! CLLocationDegrees
                let lonDelta = object["lonDelta"] as! CLLocationDegrees

                let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat , lon),  MKCoordinateSpanMake(latDelta, lonDelta))
                return region
            }
        }
        return nil
    }
}
