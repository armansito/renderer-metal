//
//  Buffer.swift
//  Renderer
//
//  Created by Arman Uguray on 5/11/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Metal

// Buffer wraps around a GPU buffer and manages access to its contents.
struct Buffer<T> {
    // The underlying GPU buffer.
    let buffer: MTLBuffer

    // True if the memory storage mode is "managed". A managed memory buffer maintains separate
    // copies of its contents in GPU and CPU memory which need to be synchronized explicitly. If
    // false, this is a shared buffer and the GPU and the CPU access the same memory.
    private let _isManaged: Bool

    // A raw pointer into the GPU buffer in terms N elements of type T.
    private let _contents: UnsafeMutableBufferPointer<T>

    // Allocates a new buffer of `count` elements in `device`.
    init?(_ device: MTLDevice, count: UInt) {
        self._isManaged = !device.hasUnifiedMemory
        let storageMode = self._isManaged ?
            MTLResourceOptions.storageModeManaged :
            MTLResourceOptions.storageModeShared

        // TODO: Account for triple buffering.
        let count = Int(count)
        let bufferSize = MemoryLayout<T>.stride * count

        guard let buffer = device.makeBuffer(length: bufferSize, options: storageMode) else {
            print("failed to allocate GPU buffer of size ", bufferSize)
            return nil
        }
        self.buffer = buffer

        // Stora a raw pointer to the underlying buffer.
        let contents = buffer.contents().bindMemory(to: T.self, capacity: count)
        self._contents = UnsafeMutableBufferPointer(start: contents, count: count)
    }

    func write(pos: Int, data: [T]) throws {
        let writeSize = data.count * MemoryLayout<T>.stride
        let lastIndex = pos + data.count
        if (pos < 0 || lastIndex > self._contents.count) {
            throw RendererError.runtimeError("invalid access to buffer!")
        }

        for (index, item) in data.enumerated() {
            self._contents[index + pos] = item
        }

        // Synchronize the CPU and GPU buffers if memory is not shared.
        if self._isManaged {
            self.buffer.didModifyRange(pos ..< pos + writeSize)
        }
    }
}
