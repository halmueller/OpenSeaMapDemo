//
//  OpenSeaMapOverlay.swift
//  Open Sea Map Browser
//
//  Created by Hal Mueller on 8/17/15.
//  Copyright (c) 2015 Hal Mueller. All rights reserved.
//
//  After https://github.com/viggiosoft/MapTileOverlayTutorial

import MapKit

class OpenSeaMapOverlay: MKTileOverlay {
	init() {
		super.init(URLTemplate: "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
		self.minimumZ = 9
		self.maximumZ = 17
		self.canReplaceMapContent = false
		print("initialized")
	}
	
	override func loadTileAtPath(path: MKTileOverlayPath,
		result: ((NSData!, NSError!) -> Void)!) {
			
			super.loadTileAtPath(path, result: result)
			
			//Set breakpoint or write out path for debug
			NSLog("Inside load of \(path.x) \(path.y) \(path.z) \(path.contentScaleFactor)")
	}
}
