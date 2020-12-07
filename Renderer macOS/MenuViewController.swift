//
//  MenuViewController.swift
//  Renderer macOS
//
//  Created by Arman Uguray on 12/7/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Cocoa
import SwiftUI

class MenuViewController: NSHostingController<MenuView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: MenuView())
    }
}

enum Events {
    static let debugModeEnabled = NSNotification.Name("debugModeEnabled")
}

struct MenuView: View {
    @State private var showDebug = false

    var body: some View {
        Toggle("Enable Debug View", isOn: $showDebug.didSet { value in
            NotificationCenter.default.post(name: Events.debugModeEnabled, object: value)
        }).padding(50)
    }
}

// Protocol extension allows a custom handler for to be added for all SwiftUI
// elements that use a binding.
extension Binding {
    func didSet(_ execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
