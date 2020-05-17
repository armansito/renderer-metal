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
#include "Algebra.h"

// Vertex stage function that passes each vertex through directly. Outputs the screen space vertex
// coordinate
vertex float4 simpleVert(const device float3* positions [[ buffer(BufferIndexVertexPositions) ]],
                         constant Uniforms& uniforms    [[ buffer(BufferIndexUniforms) ]],
                         uint v_id                      [[ vertex_id ]]) {
    float4 position = float4(positions[v_id], 1.0);
    float4x4 view = algebra::viewMatrix(uniforms.view);
    return uniforms.projection.matrix * view * position;
}

// Fragment stage function that returns a solid color
fragment float4 solidColorFrag(float4 in [[ stage_in ]]) {
    return float4(1.0, 0.0, 0.0, 1.0);
}
