//
//  RasterPipelines.metal
//  Renderer
//
//  Created by Arman Uguray on 5/15/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Shared.h"

// Fragment stage function that returns a solid red color
fragment float4 frag_solid_red_color(float4 in[[ stage_in ]]) {
	return float4(1.0, 0.1, 0.1, 1.0);
}

// Fragment stage function that returns a solid red color
fragment float4 frag_solid_blue_color(float4 in[[ stage_in ]]) {
	return float4(0.1, 0.1, 1.0, 1.0);
}
