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
#include "VertexFunctions.h"

// Vertex stage function that transforms every vertex by the camera view and projection matrices.
vertex VertexOutput vertex_default(const device Vertex* vertices [[ buffer(BufferIndexVertexPositions) ]],
                                   constant Uniforms& uniforms   [[ buffer(BufferIndexUniforms) ]],
                                   uint v_id                     [[ vertex_id ]]) {
    const device Vertex& v_in = vertices[v_id];
    float4x4 matrix = uniforms.projection.matrix * algebra::viewMatrix(uniforms.view);
    return VertexOutput {
        .pos = matrix * float4(v_in.pos, 1.0),
        .color = v_in.color,
    };
}

// Vertex stage function that can be used to render a coordinate grid moves with the camera.
// This works similarly to simpleVert, except for the horizontal translation.
vertex VertexOutput vertex_infinite_grid(const device Vertex* vertices [[ buffer(BufferIndexVertexPositions) ]],
                                         constant Uniforms& uniforms   [[ buffer(BufferIndexUniforms) ]],
                                         uint v_id                     [[ vertex_id ]]) {
    constant CameraView& view = uniforms.view;
    float3 vertical(0, view.eye.y > 0 ? -1 : 1, 0);
    float d = abs(view.eye.y/max(dot(vertical, uniforms.view.look), 0.1));
    float3 ground = view.eye + view.look * d;
    ground.y = 0;

    float4x4 matrix = uniforms.projection.matrix * algebra::viewMatrix(view);
    const device Vertex& v_in = vertices[v_id];
    return VertexOutput {
        .pos = matrix * float4(v_in.pos + round(ground), 1.0),
        .color = v_in.color,
    };
}
