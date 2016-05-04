//
//  VideoProcessor.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation


class VideoProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
	var recievedFrameCount:Int	= 0
	var droppedFrameCount:Int	= 0
	
	var imageView:NSImageView?
	
	func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		droppedFrameCount += 1
		NSLog("dropped frame")
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		recievedFrameCount += 1
		imageView?.image = imageFromSampleBuffer(sampleBuffer)
		//imageView?.superview?.
	}
	
	
	func imageFromSampleBuffer(sampleBuffer:CMSampleBuffer) -> NSImage {
		
		// Get a CMSampleBuffer's Core Video image buffer for the media data
		let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		// Lock the base address of the pixel buffer
		CVPixelBufferLockBaseAddress(imageBuffer, 0)
		
		// Get the number of bytes per row for the pixel buffer
		let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
		
		// Get the number of bytes per row for the pixel buffer
		let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
		// Get the pixel buffer width and height
		let width = CVPixelBufferGetWidth(imageBuffer)
		let height = CVPixelBufferGetHeight(imageBuffer)
		
		// Create a device-dependent RGB color space
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		//let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, )
		
		let info = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
		
		// Create a bitmap graphics context with the sample buffer data
		let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, info)
		
		// Create a Quartz image from the pixel data in the bitmap graphics context
		let quartzImage = CGBitmapContextCreateImage(context)
		// Unlock the pixel buffer
		
		CVPixelBufferUnlockBaseAddress(imageBuffer,0)

	
		// Create an image object from the Quartz image
		let image = NSImage(CGImage: quartzImage!, size: NSSize(width: width, height: height))
		return image
	}
}
