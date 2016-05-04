//
//  CameraView.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation

class ProcessedView: NSView, AVCaptureVideoDataOutputSampleBufferDelegate {
	
	var currentBuffer:CVImageBuffer?
	
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	let info = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue


	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect)
		
		let context = NSGraphicsContext.currentContext()?.CGContext
		
		
		//layer?.backgroundColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0)
		
		if let imageBuffer = currentBuffer {
			let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
			let width = CVPixelBufferGetWidth(imageBuffer)
			let height = CVPixelBufferGetHeight(imageBuffer)
			
			CVPixelBufferLockBaseAddress(imageBuffer, 0)
			let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
			let pixels = NSMutableData(bytes: baseAddress, length: CVPixelBufferGetDataSize(imageBuffer))
			CVPixelBufferUnlockBaseAddress(imageBuffer, 0)

			
			//perform operations on pixels.
			//TODO: change to async Metal kernel
			
			
			for y in 0..<height {
				for x in 0..<width {
					let offset = 1+x*4+y*bytesPerRow
					pixels.resetBytesInRange(NSRange(location: offset, length: 1))
				}
			}
			
			
			
			//render the image to the context
			let bitmapContext = CGBitmapContextCreate(pixels.mutableBytes, width, height, 8, bytesPerRow, colorSpace, info)!
			
			let image = CGBitmapContextCreateImage(bitmapContext)
			CGContextDrawImage(context, CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: bounds.width, height: bounds.height))
				, image)
			
			
			currentBuffer = nil
		}
		
		
	}
	
	
	func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		NSLog("dropped frame")
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		currentBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
		//display on main thread
		dispatch_async(dispatch_get_main_queue()) {
			self.display()
		}
	}
	
}
