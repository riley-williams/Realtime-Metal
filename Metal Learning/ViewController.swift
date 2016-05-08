//
//  ViewController.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate, VideoProcessorDelegate {
	var session = AVCaptureSession()
	var processor:VideoProcessor?
	
	@IBOutlet weak var previewView: NSView!
	@IBOutlet weak var processedView: ProcessedView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//configure the session
		session.sessionPreset = AVCaptureSessionPresetHigh
		
		//add the input device (camera)
		if let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) {
			let deviceInput = try! AVCaptureDeviceInput.init(device: device)
			session.addInput(deviceInput)
			
			
			//add the output device
			let output = AVCaptureVideoDataOutput()
			output.alwaysDiscardsLateVideoFrames = true
			output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
			
			let queue = dispatch_queue_create("camera video capture", DISPATCH_QUEUE_SERIAL)
			output.setSampleBufferDelegate(self, queue: queue)
			
			session.addOutput(output)
			
			
			//create a preview layer and set it as the preview's layer
			let previewLayer = AVCaptureVideoPreviewLayer(session: session)
			previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
			previewLayer.frame = previewView.bounds
			previewView.layer = previewLayer
			
			let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
			let width  = Int(dimensions.width)
			let height = Int(dimensions.height)
			
			let info = FrameInfo(width: width, height: height, bytesPerPixel: 4)
			processor = VideoProcessor(frameInfo: info)
			
			processor?.delegate = self
			
			//start capturing camera data
			session.startRunning()
			
		} else {
			NSLog("Error loading camera")
		}
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		NSLog("dropped frame")
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
			CVPixelBufferLockBaseAddress(imageBuffer, 0)
			let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
			let data = NSMutableData(bytes: baseAddress, length: CVPixelBufferGetDataSize(imageBuffer))
			CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
			//give frame to video processor
			processor?.recievedNewFrame(data: data)
		}
	}
	
	
	func didFinishProcessingFrame(frame: Frame) {
		if self.processedView.processedFrame == nil {
			self.processedView.processedFrame = frame
			self.processedView.display()
		}
	}
	
}

