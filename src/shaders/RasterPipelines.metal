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
#include "VertexFunctions.h"

// Fragment stage function that returns a solid red color
fragment float4 frag_solid_red_color(VertexOutput in [[ stage_in ]]) {
	return float4(1.0, 0.1, 0.1, 1);
}

// Fragment stage function that returns the solid color from the vertex pipeline without any
// calculations.
fragment float4 frag_solid_color(VertexOutput in [[ stage_in ]]) {
    return float4(in.color, 1);
}

// Fragment stage function that applies the Phong lighting model. All calculations are done in world
// space.
fragment float4 frag_phong(VertexOutput in                  [[ stage_in ]],
                           constant SceneUniforms& uniforms [[ buffer(BufferIndexSceneUniforms) ]],
                           constant Light* lights           [[ buffer(BufferIndexSceneLights) ]]) {
    constant PhongMaterial& phong = uniforms.phongMaterial;

    // Ambient
    float ambient = phong.ambient;
    float3 color(0);

    for (uint i = 0; i < uniforms.lightCount; i++) {
        // Diffuse
        float3 L = normalize(lights[i].pos - in.pos);
        float diffuse = phong.diffuse * max(0.0, dot(L, in.normal));

        // Specular
        float3 V = normalize(uniforms.view.eye - in.pos);
        float3 R = reflect(-L, in.normal);
        float specular = phong.specular * pow(max(0.0, dot(R, V)), phong.shininess);
        color += (ambient + diffuse + specular) * lights[i].color;
    }

    // Final color value
    color *= in.color;

    // TODO: gamma correction and tone mapping configurable

    // Apply the simple Reinhard tone mapping algorithm to RGB channels.
    color = color / (1.0 + color);

    return float4(color, 1);
}
