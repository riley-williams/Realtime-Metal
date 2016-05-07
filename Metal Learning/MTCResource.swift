//
//  MTCBufferResource.swift
//  Metal Learning
//
//  Created by Riley Williams on 5/6/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

import Cocoa

class MTCResource: NSObject {
	var data:NSMutableData
	var index:UInt
	var syncOnComputeCompletion:Bool = true
	
	var isDataInUse:Bool = false
	
	init(data:NSMutableData, index:UInt) {
		self.data = data.mutableCopy() as! NSMutableData
		self.index = index
	}
	
	init(dataNoCopy data:NSMutableData, index:UInt) {
		self.data = data
		self.index = index
	}
	
}
