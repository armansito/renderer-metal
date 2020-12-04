//
//  Shared.h
//  Renderer
//
//  Created by Arman Uguray on 5/15/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.

// This header defines data types shared between the Metal shaders and Swift code.

#ifndef SHADERS_SHARED_H_
#define SHADERS_SHARED_H_

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

// The indices assigned to GPU buffers.
typedef NS_ENUM (NSInteger, BufferIndex) {
	BufferIndexUniforms = 0,
	BufferIndexVertexPositions = 1,
};

// Defines the components of the camera used to construct a view matrix.
struct CameraView {
	simd_float3 eye;
	simd_float3 look;
	simd_float3 up;
	simd_float3 right;
};

// Defines the components of the camera used to construct a 3D projection matrix.
struct CameraProjection {
	// The vertical field of view in radians.
	float fovy;

	// The width and height of the viewport in terms of logical pixels.
	float width, height;

	// The distance of the clipping planes along the look vector in relation to the eye.
	float near, far;

	// The CPU calculated column-major perspective projection matrix. Vertex stage functions in
	// rasterized pipelines use this value to avoid this matrix computation for every frame.
	// Ray-traced pipelines use the fields above directly to construct rays since ray/scene
	// intersections are calculated in world-space coordinates.
	matrix_float4x4 matrix;
};

// Uniform data that does not change across threads.
struct Uniforms {
	struct CameraView view;
	struct CameraProjection projection;
};

#endif // SHADERS_SHARED_H_
