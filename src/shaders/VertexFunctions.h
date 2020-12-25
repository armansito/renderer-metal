//
//  VertexFunctions.h
//  Renderer
//
//  Created by Arman Uguray on 12/8/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#ifndef SHADERS_VERTEX_FUNCTIONS_H_
#define SHADERS_VERTEX_FUNCTIONS_H_

struct VertexOutput {
    // Screen space position of the vertex
    float4 fragmentPos [[position]];

    // World-space position and normal of the vertex
    float3 pos;
    float3 normal;
    float3 color;
};

#endif // SHADERS_VERTEX_FUNCTIONS_H_
