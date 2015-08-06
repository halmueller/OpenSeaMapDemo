//
//  NSUserDefaultRegionExtension.swift
//  Open Sea Map Browser
//
//  from https://gist.github.com/bluwave/f8049f53a83f1323fcc4#file-nsuserdefaultregionextension
//
//

import UIKit
import MapKit

extension NSUserDefaults {
    func setRegion(region:MKCoordinateRegion? , forKey:String)
    {
        if let r = region {
            var data:[String:AnyObject] = ["lat":r.center.latitude, "lon":r.center.longitude, "latDelta":r.span.latitudeDelta, "lonDelta":r.span.longitudeDelta]
            self.setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: forKey)
        }
    }

    func regionForKey(key:String?) -> MKCoordinateRegion?
    {
        if let k = key
        {
            var possibleData = NSUserDefaults.standardUserDefaults().objectForKey(k) as! NSData?
            if let data = possibleData {

                var object:[String:AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: AnyObject]

                var lat = object["lat"] as! CLLocationDegrees
                var lon = object["lon"] as! CLLocationDegrees
                var latDelta = object["latDelta"] as! CLLocationDegrees
                var lonDelta = object["lonDelta"] as! CLLocationDegrees

                var region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat , lon),  MKCoordinateSpanMake(latDelta, lonDelta))
                return region
            }
        }
        return nil
    }
}