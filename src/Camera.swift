//
//  Camera.swift
//  Renderer
//
//  Created by Arman Uguray on 5/15/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import simd

// The minimum distance required between the eye and the center of rotation (which the camera is
// directly facing).
let ZOOM_MIN_THRESHOLD: Float = 0.5
let ZOOM_MAX_THRESHOLD: Float = 20.0

class Camera {
    private var _center: vector_float3
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
        _center = _view.eye + _view.look

        _projection = CameraProjection()
        _projection.fovy = 35 * .pi / 180
        _projection.far = 100
        _projection.near = 0.1
        _projection.width = 2
        _projection.height = 2

        updateProjectionMatrix()
    }

    func lookAt(eye: vector_float3, center: vector_float3, up: vector_float3) {
        _center = center
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

    func zoom(delta: Float) {
        // Make sure that the eye can't go past the center.
        var new = _view.eye + delta * _view.look
        let gap = _center - new
        let gapSize = length(gap)

        // Snap the new eye position to a fixed distance from the camera center if it zoomed in or
        // out too much.
        if (gapSize <= ZOOM_MIN_THRESHOLD || dot(gap, _view.look) < 0) {
            new = _center - ZOOM_MIN_THRESHOLD * _view.look
        } else if (gapSize >= ZOOM_MAX_THRESHOLD) {
            new = _center - ZOOM_MAX_THRESHOLD * _view.look
        }
        _view.eye = new
    }

    func rotate(horizontal: Float, vertical: Float) {
        let horizontal = simd_quatf(angle: -horizontal, axis: vector_float3(0, 1, 0))
        let vertical = simd_quatf(angle: -vertical, axis: _view.right)
        let rotation = horizontal * vertical
        let d = rotation.act(_view.eye - _center)
        _view.eye = _center + d
        lookAt(eye: _center + d, center: _center, up: rotation.act(_view.up))
    }

    // Moves the camera parallel to the view plane.
    func pan(horizontal: Float, vertical: Float) {
        let d = vertical * _view.up - horizontal * _view.right
        _view.eye += d
        _center += d
    }

    // Moves the camera parallel to the ground.
    func move(horizontal: Float, vertical: Float) {
        // Project the camera axes onto the ground plane. The projection of the up and look vectors
        // will be our "forward" direction while the right vector determines horizontal movement.
        let h = -_view.right * horizontal
        let v = vertical * normalize(
            vector_float3(_view.up.x, 0, _view.up.z) + vector_float3(_view.look.x, 0, _view.look.z))
        let d = h + v
        _view.eye += d
        _center += d
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
