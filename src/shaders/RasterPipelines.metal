//
//  RasterPipelines.metal
//  Renderer
//
//  Created by Arman Uguray on 5/15/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

// Vertex stage function that passes each vertex through directly. Outputs the screen space vertex
// coordinate
vertex float4 nopVert(const device float3* positions [[buffer(0)]],
                              uint v_id [[vertex_id]]) {
    return float4(positions[v_id], 1.0);
}

// Fragment stage function that returns a solid color
fragment float4 solidColorFrag(float4 in [[stage_in]]) {
    return float4(1.0, 0.0, 0.0, 1.0);
}
