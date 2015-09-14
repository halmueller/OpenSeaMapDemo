//
//  NSUserDefaultRegionExtension.swift
//  Open Sea Map Browser
//
//  from https://gist.github.com/bluwave/f8049f53a83f1323fcc4#file-nsuserdefaultregionextension
//  Author: G Richards (bluwave)
//

import UIKit
import MapKit

extension NSUserDefaults {
    func setRegion(region:MKCoordinateRegion? , forKey:String)
    {
        if let r = region {
            let data:[String:AnyObject] = ["lat":r.center.latitude, "lon":r.center.longitude, "latDelta":r.span.latitudeDelta, "lonDelta":r.span.longitudeDelta]
            self.setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: forKey)
        }
    }

    func regionForKey(key:String?) -> MKCoordinateRegion?
    {
        if let k = key
        {
            let possibleData = NSUserDefaults.standardUserDefaults().objectForKey(k) as! NSData?
            if let data = possibleData {

                var object:[String:AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: AnyObject]

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