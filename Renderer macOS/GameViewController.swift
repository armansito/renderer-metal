//
//  GameViewController.swift
//  Renderer macOS
//
//  Created by Arman Uguray on 3/31/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        let gpus = MTLCopyAllDevices()
        var device: MTLDevice!;
        if gpus.isEmpty {
            print("Metal is not supported on this device")
            return
        }
        
        let gpuNames = gpus
            .map({ gpu in gpu.name })
            .reduce("", { result, next in return result + "\n  " + next })
        print("System has", gpus.count, "GPUs: ", gpuNames)

        // Select a high power GPU if the system has a discrete GPU
        device = gpus[0]
        for gpu in gpus {
            if !gpu.isLowPower {
                print("Selected:", gpu.name)
                device = gpu;
                break
            }
        }

        mtkView.device = device
        guard let renderer = Renderer(view: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        self.renderer = renderer
        self.renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
    }
}
