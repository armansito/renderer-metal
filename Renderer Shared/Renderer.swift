//
//  Renderer.swift
//  Renderer
//
//  Created by Arman Uguray on 4/17/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal
import MetalKit

struct RendererConstants {
    // We use a Triple Buffering approach to synchronize access to shared buffers between
    // the CPU and the GPU.
    static let maxBuffersInFlight = 3;
}

class Renderer: NSObject, MTKViewDelegate {
    // Handles to the view we are drawing to and the GPU that it has been assigned.
    private let _device: MTLDevice

    // The default shader libary of this app.
    private let _library: MTLLibrary

    // The frame in the triple-buffering sequence used to index shared buffer regions.
    private var _currentBufferStep = 0

    init?(view: MTKView) {
        view.colorPixelFormat = MTLPixelFormat.rgba16Float
        view.sampleCount = 1

        self._device = view.device!
        self._library = self._device.makeDefaultLibrary()!

        super.init()
    }

    private func advanceBufferStep() {
        _currentBufferStep = (_currentBufferStep + 1) % RendererConstants.maxBuffersInFlight
    }
    
    // MTKViewDelegate override:
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO
    }
    
    // MTKViewDelegate override:
    func draw(in view: MTKView) {
        // TODO
    }
}
