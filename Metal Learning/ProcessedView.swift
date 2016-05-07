//
//  CameraView.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation

class ProcessedView: NSView {
	private let colorSpace = CGColorSpaceCreateDeviceRGB()
	private let byteOrdering = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
	
	var processedFrame:Frame?
	
	var q:NSTimeInterval = 0
	
	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect)
		
		let context = NSGraphicsContext.currentContext()?.CGContext
		
		//layer?.backgroundColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0)
		
		if processedFrame != nil {
			let info = processedFrame!.info
			//render the image to the context
			let bytes = processedFrame!.data.mutableCopy()
			let bitmapContext = CGBitmapContextCreate(bytes.mutableBytes, info.width, info.height, 8, info.byteWidth(), colorSpace, byteOrdering)!
			let image = CGBitmapContextCreateImage(bitmapContext)
			CGContextDrawImage(context, NSRectToCGRect(bounds), image)
			
			let t = NSDate.timeIntervalSinceReferenceDate()
			
			NSLog("\(Int(1/(t-q)))")
			
			q = t
			processedFrame = nil
		}
		
	}
	
	
}
