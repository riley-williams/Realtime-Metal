//
//  Kernels.metal
//  Metal Learning
//
//  Created by Riley Williams on 5/4/16.
//  Copyright © 2016 Riley Williams. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void
test(const	device	uchar	*im_a		[[ buffer(0) ]],
	 device	uchar	*im_out		[[ buffer(2) ]],
	 uint2	pos			[[ thread_position_in_grid ]],
	 uint2  dim			[[ threads_per_grid ]]) {
	
	uint x = pos[0];
	uint y = pos[1];
	uint idx = x*4 + y*dim[0]*4;
	
	
	im_out[idx+0] = im_a[idx+0];
	im_out[idx+1] = float(x)/dim[0]*im_a[idx+1];
	im_out[idx+2] = float(y)/dim[1]*im_a[idx+2];
	im_out[idx+3] = 255; //aplha channel
}

//wow this is a terrible unoptimized function...
kernel void
edge(const	device	uchar4	*image		[[ buffer(0) ]],
	 const	device	int		*kern		[[ buffer(1) ]],
	 const	device	int
			device	uchar4	*im_out		[[ buffer(2) ]],
					uint2	pos			[[ thread_position_in_grid ]],
					uint2	dim			[[ threads_per_grid ]]) {
	
	uint x = pos[0];
	uint y = pos[1];
	int idx = x + y*dim[0];
	
	int conv = 0;
	
	for (int ix = -2; ix <= 2; ix++) {
		int i = idx+ix;
		int tmp = image[i][0];
		tmp += image[i][1];
		tmp += image[i][2];
		conv += tmp/3 * kern[ix+2];
	}
	
	conv /= 3;
	
	if (conv > 0) {
		im_out[idx][0] = uchar(abs(conv));
		im_out[idx][1] = 0;
	} else {
		im_out[idx][0] = 0;
		im_out[idx][1] = uchar(abs(conv));
	}
	im_out[idx][2] = uchar(abs(conv));
	im_out[idx][3] = 255; //aplha channel
}