//
//  Algebra.h
//  Renderer
//
//  Created by Arman Uguray on 5/17/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

#ifndef SHADERS_ALGEBRA_H_
#define SHADERS_ALGEBRA_H_

#include "Shared.h"

namespace algebra {

// Computes a view matrix from the provided camera data.
float4x4 viewMatrix(constant CameraView& view);

} // namespace algebra

#endif // SHADERS_ALGEBRA_H_
