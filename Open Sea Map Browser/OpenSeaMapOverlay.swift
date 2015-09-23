//
//  OpenSeaMapOverlay.swift
//  Open Sea Map Browser
//
//  Created by Hal Mueller on 8/17/15.
//  Copyright (c) 2015 Hal Mueller. All rights reserved.
//
//  After https://github.com/viggiosoft/MapTileOverlayTutorial

import Foundation
import MapKit

class OpenSeaMapOverlay: MKTileOverlay {
	let parentDirectory = "tilecache"
	let maximumCacheAge: NSTimeInterval = 30.0 * 24.0 * 60.0 * 60.0
	var urlSession: NSURLSession?
	
	init() {
		super.init(URLTemplate: "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
		self.minimumZ = 9
		self.maximumZ = 17
		self.canReplaceMapContent = false
		
		// The Open Sea Map tile server returns 404 for blank tiles, and also when it's
		// too heavily loaded to return a tile. We'll do our own cacheing and not use
		// NSURLSession's.
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		sessionConfiguration.URLCache = nil
		sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalCacheData
		self.urlSession = NSURLSession(configuration: sessionConfiguration)
		
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
			let cachesDirectory = paths[0]
			print("Caches Directory:")
			print(cachesDirectory)
		#endif
	}
	
	override func loadTileAtPath(path: MKTileOverlayPath,
		result: ((NSData?, NSError?) -> Void)) {
			
			let parentXFolderURL = URLForTilecacheFolder().URLByAppendingPathComponent(self.cacheXFolderNameForPath(path))
			let tileFilePathURL = parentXFolderURL.URLByAppendingPathComponent(fileNameForTile(path))
			let tileFilePath = tileFilePathURL.path!
			var useCachedVersion = false
			if NSFileManager.defaultManager().fileExistsAtPath(tileFilePath) {
				if let fileAttributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(tileFilePath),
					fileModificationDate = fileAttributes[NSFileModificationDate] as? NSDate {
						if fileModificationDate.timeIntervalSinceNow > -1.0 * maximumCacheAge {
							useCachedVersion = true
						}
				}
			}
			if (useCachedVersion) {
				let cachedData = NSData(contentsOfFile: tileFilePath)
				result(cachedData, nil)
			}
			else {
				let request = NSURLRequest(URL: self.URLForTilePath(path))
				//				print("fetching", request)
				let task = urlSession!.dataTaskWithRequest(request, completionHandler: { (data, response, error)  in
					if response != nil {
						if let httpResponse = response as? NSHTTPURLResponse {
							if httpResponse.statusCode == 200 {
								do {
									try NSFileManager.defaultManager().createDirectoryAtURL(parentXFolderURL,
										withIntermediateDirectories: true, attributes: nil)
								} catch {
								}
								if !data!.writeToFile(tileFilePath, atomically: true) {
								}
								result(data, error)
							}
						}
					}
				})
				task.resume()
			}
	}
	
	// filename for y.png, used within the cacheXFolderNameForPath
	private func fileNameForTile(path: MKTileOverlayPath) -> String {
		return "\(path.y).png"
	}
	
	// path to X folder, starting from URLForTilecacheFolder
	private func cacheXFolderNameForPath(path: MKTileOverlayPath) -> String {
		return "\(path.contentScaleFactor)/\(path.z)/\(path.x)"
	}
	
	// folder within app's Library/Caches to use for this particular overlay
	private func URLForTilecacheFolder() -> NSURL {
		let URLForAppCacheFolder : NSURL = try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
			inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
		return URLForAppCacheFolder.URLByAppendingPathComponent(parentDirectory, isDirectory: true)
	}
	
	private func URLForXFolder(path: MKTileOverlayPath) -> NSURL {
		return URLForTilecacheFolder().URLByAppendingPathComponent(cacheXFolderNameForPath(path), isDirectory: true)
	}
}
