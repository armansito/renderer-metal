//
//  GameViewController.swift
//  Renderer macOS
//
//  Created by Arman Uguray on 3/31/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Cocoa
import MetalKit

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
            .map({ gpu in (gpu.name, gpu.hasUnifiedMemory) })
            .reduce("", { (result, next) -> String in
                let (name, hasUnifiedMemory) = next
                let detail = hasUnifiedMemory ? "shared CPU memory" : "no shared memory"
                return String(format: "%@\n %@; %@", result, name, detail)
            })
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(debugViewEnabled),
                                               name: Event.debugModeEnabled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rasterPhongEnabled),
                                               name: Event.rasterPhongEnabled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rasterPhongMaterialChanged),
                                               name: Event.rasterPhongMaterialChanged,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Event.debugModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: Event.rasterPhongEnabled,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: Event.rasterPhongMaterialChanged,
                                                  object: nil)
    }

    override func mouseDragged(with event: NSEvent) {
        let h = Float(event.deltaX) / 100
        let v = Float(event.deltaY) / 100
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue > 0 {
            self.renderer.moveCamera(horizontal: h, vertical: v)
        } else {
            self.renderer.rotateCamera(horizontal: h, vertical: v)
        }
    }

    override func rightMouseDragged(with event: NSEvent) {
        let h = Float(event.deltaX) / 100
        let v = Float(event.deltaY) / 100
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue > 0 {
            self.renderer.moveCamera(horizontal: h, vertical: v)
        } else {
            self.renderer.panCamera(horizontal: h, vertical: v)
        }
    }

    override func scrollWheel(with event: NSEvent) {
        self.renderer.zoomCamera(delta: Float(event.deltaY) / 100)
    }

    @objc private func debugViewEnabled(_ notification: Notification) {
        if let value = notification.object as? Bool {
            self.renderer.toggleDebugMode(enabled: value)
        }
    }

    @objc private func rasterPhongEnabled(_ notification: NSNotification) {
        if let value = notification.object as? Bool {
            self.renderer.togglePhong(enable: value)
        }
    }

    @objc private func rasterPhongMaterialChanged(_ notification: NSNotification) {
        if let value = notification.object as? PhongMaterial {
            self.renderer.setPhongMaterial(value)
        }
    }
}
