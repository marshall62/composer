//
//  ContentView.swift
//  composer
//
//  Created by David Marshall on 9/14/26.
//

import SwiftUI

enum GridSelection: String, CaseIterable, Identifiable {
    case fourByFour = "4x4"
    case eightByEight = "8x8"
    case custom = "Custom"
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var width: Double?
    @State private var height: Double?
    @State private var gridSelection: GridSelection = .fourByFour
    @State private var squareSize: Double?
    @State private var showWarningAlert = false
    @State private var pendingWarnings: [String] = []
    @State private var didProceed = false

    private var gridType: GridType {
        switch gridSelection {
        case .fourByFour: return .fourByFour
        case .eightByEight: return .eightByEight
        case .custom: return .customSquare(size: squareSize ?? 0)
        }
    }

    private var settings: CanvasSettings {
        CanvasSettings(width: width ?? 0, height: height ?? 0, gridType: gridType)
    }

    private var errors: [String] {
        blockingErrors(for: settings)
    }

    var body: some View {
        if didProceed {
            PhotoPickerView(canvasSettings: settings)
        } else {
            Form {
                TextField("Width", value: $width, format: .number)
                    .keyboardType(.decimalPad)

                TextField("Height", value: $height, format: .number)
                    .keyboardType(.decimalPad)

                Picker("Grid", selection: $gridSelection) {
                    ForEach(GridSelection.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.menu)

                if gridSelection == .custom {
                    TextField("Square Size", value: $squareSize, format: .number)
                        .keyboardType(.decimalPad)
                }

                if !errors.isEmpty {
                    Text(errors.joined(separator: "\n"))
                        .foregroundStyle(.red)
                }

                Button("Continue") {
                    let currentWarnings = warnings(for: settings)
                    if currentWarnings.isEmpty {
                        didProceed = true
                    } else {
                        pendingWarnings = currentWarnings
                        showWarningAlert = true
                    }
                }
                .disabled(!errors.isEmpty)
                .alert("Check Your Settings", isPresented: $showWarningAlert) {
                    Button("Change Size", role: .cancel) { }
                    Button("Proceed Anyway") { didProceed = true }
                } message: {
                    Text(pendingWarnings.joined(separator: "\n"))
                }
            }
        }
    }
}
