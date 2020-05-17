//
//  Camera.swift
//  Renderer
//
//  Created by Arman Uguray on 5/15/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import simd

class Camera {
    private var _view: CameraView
    private var _projection: CameraProjection

    var view: CameraView {
        get { _view }
    }

    var projection: CameraProjection {
        get { _projection }
    }

    init() {
        // Initialize the camera at the origin looking down the -z axis.
        // NOTE: This application uses right-handed coordinates.
        _view = CameraView()
        _view.eye = vector_float3(0.0, 0.0, 0.0)
        _view.look = vector_float3(0.0, 0.0, -0.1)
        _view.up = vector_float3(0.0, 1.0, 0.0)
        _view.right = vector_float3(1.0, 0.0, 0.0)

        _projection = CameraProjection()
        _projection.fovy = 65 * .pi / 180
        _projection.far = 20
        _projection.near = 1
        _projection.width = 2
        _projection.height = 2

        updateProjectionMatrix()
    }

    func lookAt(eye: vector_float3, center: vector_float3, up: vector_float3) {
        _view.eye = eye
        _view.look = normalize(center - eye)
        _view.right = normalize(cross(self._view.look, up))
        _view.up = normalize(cross(self._view.right, self._view.look))
    }

    func perspective(fovY: Float, width: Float, height: Float) {
        _projection.fovy = fovY
        _projection.width = width
        _projection.height = height
        updateProjectionMatrix()
    }

    private func updateProjectionMatrix() {
        let n = _projection.near
        let f = _projection.far

        let Sy = 1 / tanf(_projection.fovy * 0.5)
        let Sx = Sy * _projection.height / _projection.width
        let Sz = f / (n - f)
        _projection.matrix = matrix_float4x4.init(columns: (
            vector_float4(Sx, 0, 0, 0),
            vector_float4(0, Sy, 0, 0),
            vector_float4(0, 0, Sz, -1),
            vector_float4(0, 0, Sz * n, 0)
        ))
    }
}
