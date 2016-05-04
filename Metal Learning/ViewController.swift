//
//  ViewController.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
	var session = AVCaptureSession()
	var processor = VideoProcessor()
	
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
			output.setSampleBufferDelegate(processedView, queue: queue)
			
			session.addOutput(output)

			
			
			//create a preview layer and set it as the preview's layer
			let previewLayer = AVCaptureVideoPreviewLayer(session: session)
			previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
			previewLayer.frame = previewLayer.frame
			previewView.layer = previewLayer
			
			
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
	
	func update() {
		self.view.setNeedsDisplayInRect(self.view.frame)
	}
	
}

