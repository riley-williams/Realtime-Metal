//
//  MetalComputeEngine.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//


import MetalKit

class MTCProcessor: NSObject {
	private let device:MTLDevice
	private let library:MTLLibrary
	private let commandQ:MTLCommandQueue
	private let kernelState:MTLComputePipelineState
	private var resources:[MTCResource!]
	
	var threadsPerThreadgroup:MTLSize!
	var	threadgroupsPerGrid:MTLSize!
	
	
	init(metalSourceFile file:String, numResources:UInt) {
		//setup metal
		device = MTLCreateSystemDefaultDevice()!
		library = device.newDefaultLibrary()!
		commandQ = device.newCommandQueue()
		
		//metal function must exist somewhere in the project
		let kernel = library.newFunctionWithName(file)!
		kernelState = try! device.newComputePipelineStateWithFunction(kernel)
		
		
		resources = [MTCResource!](count: Int(numResources), repeatedValue: nil)
		
	}
	
	func setGridParameters(threadsPerThreadgroup tpt:MTLSize, threadgroupsPerGrid tpg:MTLSize) {
		self.threadsPerThreadgroup	= tpt
		self.threadgroupsPerGrid	= tpg
	}
	
	func addResource(buffer resource:MTCResource) {
		self.resources.append(resource)
	}
	
	
	func addResource(texture resource:MTCResource) {
		assertionFailure("Textures have not been implemented yet")
	}
	
	func updateResource(buffer resource:MTCResource, index:Int) {
		resources[index] = resource
	}
	
	func updateResource(texture resource:MTCResource, index:Int) {
		assertionFailure("Textures have not been implemented yet")
	}
	
	func clearResources() {
		resources.removeAll()
	}
	
	
	func compute() {
		//more Metal setup
		let commandBuf = commandQ.commandBuffer()
		let encoder = commandBuf.computeCommandEncoder()
		encoder.setComputePipelineState(kernelState)
		
		
		//copy resources
		var buffers = [MTLBuffer]()
		for i in 0..<resources.count {
			let buf = device.newBufferWithBytes(resources[i].data.bytes, length: resources[i].data.length, options: .CPUCacheModeDefaultCache)
			encoder.setBuffer(buf, offset: 0, atIndex: Int(resources[i].index))
			buffers.append(buf)
		}
		
		//further compute encoder setup
		encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
		encoder.endEncoding()
		
		commandBuf.commit()
		commandBuf.waitUntilCompleted()
		
		
		//sync resources
		for i in 0..<resources.count {
			if resources[i].syncOnComputeCompletion {
				memcpy(resources[i].data.mutableBytes, buffers[i].contents(), resources[i].data.length)
			}
		}
		
	}
	
	func computeAsync(completion: (MTCProcessor)->Void) {
		//more Metal setup
		let commandBuf = commandQ.commandBuffer()
		let encoder = commandBuf.computeCommandEncoder()
		encoder.setComputePipelineState(kernelState)
		
		
		//copy resources
		var buffers = [MTLBuffer]()
		for i in 0..<resources.count {
			let buf = device.newBufferWithBytes(resources[i].data.bytes, length: resources[i].data.length, options: .CPUCacheModeDefaultCache)
			encoder.setBuffer(buffers[i], offset: 0, atIndex: Int(resources[i].index))
			buffers.append(buf)
		}
		
		
		//further compute encoder setup
		encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
		encoder.endEncoding()
		commandBuf.addCompletedHandler() { _ in
			//sync resources
			for i in 0..<self.resources.count {
				if self.resources[i].syncOnComputeCompletion {
					memcpy(self.resources[i].data.mutableBytes, buffers[i].contents(), self.resources[i].data.length)
				}
			}
			completion(self)
		}
		
		
		commandBuf.commit()
	}
	
}
