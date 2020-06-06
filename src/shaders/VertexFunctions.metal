//
//  VertexShaders.metal
//  Renderer
//
//  Created by Arman Uguray on 5/18/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Shared.h"
#include "Algebra.h"

// Vertex stage function that transforms every vertex by the camera view and projection matrices.
vertex float4 vertex_default(const device float3* positions [[ buffer(BufferIndexVertexPositions) ]],
                           constant Uniforms& uniforms    [[ buffer(BufferIndexUniforms) ]],
                           uint v_id                      [[ vertex_id ]]) {
    float4 position = float4(positions[v_id], 1.0);
    float4x4 view = algebra::viewMatrix(uniforms.view);
    return uniforms.projection.matrix * view * position;
}

// Vertex stage function that can be used to render a seemingly infinite horizontal coordinate
// grid. This works similarly to simpleVert, except for the horizontal translation.
vertex float4 vertex_infinite_grid(const device float3* positions [[ buffer(BufferIndexVertexPositions) ]],
                                   constant Uniforms& uniforms    [[ buffer(BufferIndexUniforms) ]],
                                   uint v_id                      [[ vertex_id ]]) {

    float3 eye = uniforms.view.eye;
    float3 translate = fmod(eye, float3(1));
    translate.y = eye.y;
    float4x4 viewRotate = algebra::viewRotationMatrix(uniforms.view);

    float4 position = float4(positions[v_id] - translate, 1.0);
    return uniforms.projection.matrix * viewRotate * position;
}
