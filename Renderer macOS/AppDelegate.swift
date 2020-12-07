//
//  AppDelegate.swift
//  Renderer macOS
//
//  Created by Arman Uguray on 3/31/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = storyboard.instantiateController(withIdentifier: "Settings Menu") as? NSWindowController {
            windowController.showWindow(self)
        }
        if let windowController = storyboard.instantiateController(withIdentifier: "Renderer Window") as? NSWindowController {
            windowController.showWindow(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
