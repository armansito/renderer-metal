//
//  Algebra.metal
//  Renderer
//
//  Created by Arman Uguray on 5/17/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Algebra.h"

namespace algebra {

// Computes a view matrix from the provided camera data.
float4x4 viewMatrix(constant CameraView& view) {
    // Combined rotation and translation matrices.
    return float4x4(
        view.right.x,               view.up.x,               -view.look.x,              0,
        view.right.y,               view.up.y,               -view.look.y,              0,
        view.right.z,               view.up.z,               -view.look.z,              0,
        -dot(view.right, view.eye), -dot(view.up, view.eye), dot(view.look, view.eye),  1);
}

float4x4 viewRotationMatrix(constant CameraView& view) {
    return float4x4(view.right.x, view.up.x, -view.look.x, 0,
                    view.right.y, view.up.y, -view.look.y, 0,
                    view.right.z, view.up.z, -view.look.z, 0,
                    0,            0,         0,            1);
}

} // namespace algebra
