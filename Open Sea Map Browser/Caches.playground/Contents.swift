
import UIKit
import MapKit

let tilepath = MKTileOverlayPath(x: 3, y: 5, z: 20, contentScaleFactor: 2.0)
println("\(tilepath)")

let cacheURL : NSURL? = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
	inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)

let tileYURL : NSURL? = cacheURL?.URLByAppendingPathComponent("OpenSeaMap/2.0/20/5")

println("\(tileYURL)")

NSFileManager.defaultManager().createDirectoryAtURL(tileYURL!, withIntermediateDirectories: true, attributes: nil, error: nil)


