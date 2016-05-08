//
//  VideoProcessor.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa
import AVFoundation
import Accelerate
import MetalKit

class VideoProcessor: NSObject {
	private let queue = dispatch_queue_create("video processor", DISPATCH_QUEUE_CONCURRENT)
	var isInProgress:Bool = false
	
	var delegate:VideoProcessorDelegate?
	let computeProcessor:MTCProcessor
	
	var frameInfo:FrameInfo //contains the size of frames provided by the camera
	var latestCameraData:NSMutableData?
	
	
	init(frameInfo:FrameInfo) {
		self.frameInfo = frameInfo
		
		//initialize with a Metal compute kernel function
		computeProcessor = MTCProcessor(metalSourceFile: "edge", numResources: 3)
	}
	
	func process() {
		if !isInProgress {
			isInProgress = true
			dispatch_async(queue) {
				self.processKernel()
			}
		}
	}
	
	func processKernel() {
		//remove old resources. optimally, I should reuse space in GPU memory
		computeProcessor.clearResources()
		
		//provide MTC with the camera data. optimally, these should be passed as textures
		let image = MTCResource(data: latestCameraData!, index: 0)
		image.syncOnComputeCompletion = false
		computeProcessor.addResource(buffer: image)
		
		var convMatrix:[Int32] = [-2, -1, 0, 1, 2];
		let matData = NSMutableData(bytes: &convMatrix, length: convMatrix.count*sizeof(Int32))
		let matrixResource = MTCResource(data: matData, index: 1)
		computeProcessor.addResource(buffer: matrixResource)
		
		//this is a terrible solution...
		let output = MTCResource(data: latestCameraData!, index: 2)
		computeProcessor.addResource(buffer: output)
		
		//calculate integer divisors of the video dimensions under 128
		let groupWidth  = gcd(frameInfo.width,  max: 128)
		let groupHeight = gcd(frameInfo.height, max: 128)
		//set the threadgroup/grid sizes
		let tpg	= MTLSize(width: groupWidth, height: groupHeight, depth: 1)
		let tpt = MTLSize(width: frameInfo.width/tpg.width, height: frameInfo.height/tpg.height, depth: 1)
		computeProcessor.setGridParameters(threadsPerThreadgroup: tpt, threadgroupsPerGrid: tpg)
		
		//begin computation
		computeProcessor.compute()
		
		
		let processedFrame = Frame(data: output.data, info: frameInfo)
		
		
		isInProgress = false
		dispatch_async(dispatch_get_main_queue()) {
			self.delegate?.didFinishProcessingFrame(processedFrame)
		}
	}
	
	func recievedNewFrame(data d:NSMutableData) {
		latestCameraData = d
		process()
	}
	
	
	func gcd(x:Int, max:Int) -> Int {
		var gcd = 1
		var end = Int(x/2)
		if max < end {
			end = max
		}
		for i in 2...end {
			if x%i == 0 {
				gcd = i
			}
		}
		
		return gcd
	}
}

protocol VideoProcessorDelegate {
	func didFinishProcessingFrame(frame:Frame)
}

class Frame {
	var data:NSMutableData
	var info:FrameInfo
	
	init(data:NSMutableData, info:FrameInfo) {
		self.data = data
		self.info = info
	}
}

struct FrameInfo {
	var width:Int
	var height:Int
	var bytesPerPixel:Int
	
	func byteWidth() -> Int {
		return width*bytesPerPixel
	}
	func byteSize() -> Int {
		return byteWidth()*height
	}
}