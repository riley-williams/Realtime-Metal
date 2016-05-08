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


typedef struct  {
	short	size;
	float	multiplier;
	bool	shouldOverlay;
} Props;

//wow this is a terrible unoptimized function...
kernel void
edge(constant	uchar4	*image		[[ buffer(0) ]],
	 constant	int		*kern		[[ buffer(1) ]],
	 device		uchar4	*im_out		[[ buffer(2) ]],
	 constant	Props	*properties	[[ buffer(3) ]],
				uint2	pos			[[ thread_position_in_grid ]],
				uint2	dim			[[ threads_per_grid ]]) {
	
	uint x = pos[0];
	uint y = pos[1];
	int idx = x + y*dim[0];
	
	int filterSize = properties->size;
	
	//horizontal convolution
	float convX = 0;
	for (int ix = -filterSize; ix <= filterSize; ix++) {
		int i = idx+ix;
		int tmp = image[i][0];
		tmp += image[i][1];
		tmp += image[i][2];
		convX += tmp/3 * ix;
	}
	//convX /= fast::sqrt((float)filterSize);
	
	//vertical convolution
	float convY = 0;
	for (int iy = -filterSize; iy <= filterSize; iy++) {
		int i = idx + iy*dim[0];
		int tmp = image[i][0];
		tmp += image[i][1];
		tmp += image[i][2];
		convY += tmp/3 * iy;
	}
	//convY /= fast::sqrt((float)filterSize);
	
	//horizontally flipped index
	int idxF = dim[0]-x + y*dim[0];
	
	float h = fast::atan2(convY, convX) * 6/(6.2831853072);;
	float v = fast::clamp(properties->multiplier*fast::sqrt(convX*convX + convY*convY), 0, 255);
	float s = 1.0;

	
	float p, q, t, ff;
	
	ff = h - (int)h;
	p = v * (1.0 - s);
	q = v * (1.0 - (s * ff));
	t = v * (1.0 - (s * (1.0 - ff)));
	
	switch((int)h) {
		case 0:
			im_out[idxF][0] = v;
			im_out[idxF][1] = t;
			im_out[idxF][2] = p;
			break;
		case 1:
			im_out[idxF][0] = q;
			im_out[idxF][1] = v;
			im_out[idxF][2] = p;
			break;
		case 2:
			im_out[idxF][0] = p;
			im_out[idxF][1] = v;
			im_out[idxF][2] = t;
			break;
		case 3:
			im_out[idxF][0] = p;
			im_out[idxF][1] = q;
			im_out[idxF][2] = v;
			break;
		case 4:
			im_out[idxF][0] = t;
			im_out[idxF][1] = p;
			im_out[idxF][2] = v;
			break;
		case 5:
		default:
			im_out[idxF][0] = v;
			im_out[idxF][1] = p;
			im_out[idxF][2] = q;
			break;
	}
	
	float mixE = v/255;
	float mixO = (properties->shouldOverlay ? 1 - mixE : 0);
	im_out[idxF][0] = im_out[idxF][0]*mixE + image[idx][0]*mixO;
	im_out[idxF][1] = im_out[idxF][1]*mixE + image[idx][1]*mixO;
	im_out[idxF][2] = im_out[idxF][2]*mixE + image[idx][2]*mixO;
	im_out[idxF][3] = 255; //aplha channel
}