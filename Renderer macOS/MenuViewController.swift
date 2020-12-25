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

enum Event {
    static let debugModeEnabled = NSNotification.Name("debugModeEnabled")
    static let rasterPhongEnabled = NSNotification.Name("phong.enabled")
    static let rasterPhongMaterialChanged = NSNotification.Name("phong.materialChange")
}

enum Pipeline {
    case raster
    case rayTraced
}

struct MenuView: View {
    @State private var _pipeline: Pipeline = Pipeline.raster
    @State private var _debugEnabled = false

    // Phong
    @State private var _phongEnabled = true
    @State private var _phongShininess: Float = 16
    @State private var _phongAmbient: Float = 0.02
    @State private var _phongDiffuse: Float = 0.2
    @State private var _phongSpecular: Float = 1

    func phongParameterChanged() {
        NotificationCenter.default.post(
            name: Event.rasterPhongMaterialChanged,
            object: PhongMaterial(
                ambient: _phongAmbient,
                diffuse: _phongDiffuse,
                specular: _phongSpecular,
                shininess: _phongShininess))
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Debug mode toggles
            Collapsible(
                label: "Debug Settings",
                content: {
                    ToggleRow(label: "Enable Debug View",
                              event: Event.debugModeEnabled,
                              value: $_debugEnabled)
                })
            Divider()

            // Render pipeline selector
            Picker("Pipeline: ", selection: $_pipeline) {
                Text("Raster").tag(Pipeline.raster)
                Text("Ray Tracer").tag(Pipeline.rayTraced)
            }
            .pickerStyle(SegmentedPickerStyle())

            if self._pipeline == Pipeline.raster {
                ToggleRow(label: "Phong Lighting",
                          event: Event.rasterPhongEnabled,
                          value: $_phongEnabled)
                SliderRow(label: "Ambient",
                          bounds: 0 ... 1,
                          enabled: $_phongEnabled,
                          value: $_phongAmbient)
                    .padding(.leading, 30)
                    .onChange(of: _phongAmbient) { _ in phongParameterChanged() }
                SliderRow(label: "Diffuse",
                          bounds: 0 ... 1,
                          enabled: $_phongEnabled,
                          value: $_phongDiffuse)
                    .padding(.leading, 30)
                    .onChange(of: _phongDiffuse) { _ in phongParameterChanged() }
                SliderRow(label: "Specular",
                          bounds: 0 ... 1,
                          enabled: $_phongEnabled,
                          value: $_phongSpecular)
                    .padding(.leading, 30)
                    .onChange(of: _phongSpecular) { _ in phongParameterChanged() }
                SliderRow(label: "Shininess",
                          bounds: 0 ... 20,
                          enabled: $_phongEnabled,
                          value: $_phongShininess)
                    .padding(.leading, 30)
                    .onChange(of: _phongShininess) { _ in phongParameterChanged() }
            } else {
                Text("ray tracer")
            }

        }.padding(30)
    }
}

struct FlexRow<Content: View>: View {
    let content: () -> Content

    var body: some View {
        HStack {
            self.content()
            Spacer()
        }
    }
}

struct ToggleRow: View {
    let label: String
    let event: NSNotification.Name
    @Binding var value: Bool

    var body: some View {
        FlexRow {
            Toggle(isOn: $value) {
                Text(self.label)
                    .padding(EdgeInsets(top: 0, leading: 10,
                                        bottom: 0, trailing: 0))
            }.onChange(of: value) {
                NotificationCenter.default.post(name: self.event, object: $0)
            }
        }
    }
}

struct SliderRow: View {
    let label: String
    let bounds: ClosedRange<Float>
    @Binding var enabled: Bool
    @Binding var value: Float

    var body: some View {
        HStack {
            Text("\(label)")
                .frame(maxWidth: 60, alignment: .leading)
                .foregroundColor(enabled ? .white : .gray)
            Text(String(format: "(%.2f)", value))
                .frame(maxWidth: 50, alignment: .center)
            Slider(value: $value,
                   in: bounds,
                   minimumValueLabel: Text("\(Int(bounds.lowerBound))"),
                   maximumValueLabel: Text("\(Int(bounds.upperBound))"),
                   label: { })
                .disabled(!enabled)
        }
    }
}

struct Collapsible<Content: View>: View {
    @State var label: String
    @State var content: () -> Content

    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            Button(
                action: { self.collapsed.toggle() },
                label: {
                    HStack {
                        Text(self.label)
                        Spacer()
                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                    }
                    .padding(.bottom, 1)
                }
            )
            .buttonStyle(PlainButtonStyle())

            if !collapsed {
                Divider()
                VStack {
                    self.content()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 2))
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
