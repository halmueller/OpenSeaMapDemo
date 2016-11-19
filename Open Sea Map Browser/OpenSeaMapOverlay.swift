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
	let maximumCacheAge: TimeInterval = 30.0 * 24.0 * 60.0 * 60.0
	var urlSession: URLSession?
	
	init() {
		super.init(urlTemplate: "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
		self.minimumZ = 9
		self.maximumZ = 17
		self.canReplaceMapContent = false
		
		// The Open Sea Map tile server returns 404 for blank tiles, and also when it's
		// too heavily loaded to return a tile. We'll do our own cacheing and not use
		// NSURLSession's.
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.urlCache = nil
		sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
		self.urlSession = URLSession(configuration: sessionConfiguration)
		
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
			let cachesDirectory = paths[0]
			print("Caches Directory:")
			print(cachesDirectory)
		#endif
	}
	
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {

			let parentXFolderURL = URLForTilecacheFolder().appendingPathComponent(self.cacheXFolderNameForPath(path))
			let tileFilePathURL = parentXFolderURL.appendingPathComponent(fileNameForTile(path))
			let tileFilePath = tileFilePathURL.path
			var useCachedVersion = false
			if FileManager.default.fileExists(atPath: tileFilePath) {
				if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: tileFilePath),
					let fileModificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
						if fileModificationDate.timeIntervalSinceNow > -1.0 * maximumCacheAge {
							useCachedVersion = true
						}
				}
			}
			if (useCachedVersion) {
				let cachedData = try? Data(contentsOf: URL(fileURLWithPath: tileFilePath))
				result(cachedData, nil)
			}
			else {
				let request = URLRequest(url: self.url(forTilePath: path))
				//				print("fetching", request)
				let task = urlSession!.dataTask(with: request, completionHandler: { (data, response, error)  in
					if response != nil {
						if let httpResponse = response as? HTTPURLResponse {
							if httpResponse.statusCode == 200 {
								do {
									try FileManager.default.createDirectory(at: parentXFolderURL,
										withIntermediateDirectories: true, attributes: nil)
								} catch {
								}
								if !((try? data!.write(to: URL(fileURLWithPath: tileFilePath), options: [.atomic])) != nil) {
								}
								result(data, error as NSError?)
							}
						}
					}
				})
				task.resume()
			}
	}
	
	// filename for y.png, used within the cacheXFolderNameForPath
	fileprivate func fileNameForTile(_ path: MKTileOverlayPath) -> String {
		return "\(path.y).png"
	}
	
	// path to X folder, starting from URLForTilecacheFolder
	fileprivate func cacheXFolderNameForPath(_ path: MKTileOverlayPath) -> String {
		return "\(path.contentScaleFactor)/\(path.z)/\(path.x)"
	}
	
	// folder within app's Library/Caches to use for this particular overlay
	fileprivate func URLForTilecacheFolder() -> URL {
		let URLForAppCacheFolder : URL = try! FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory,
			in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
		return URLForAppCacheFolder.appendingPathComponent(parentDirectory, isDirectory: true)
	}
	
	fileprivate func URLForXFolder(_ path: MKTileOverlayPath) -> URL {
		return URLForTilecacheFolder().appendingPathComponent(cacheXFolderNameForPath(path), isDirectory: true)
	}
}
