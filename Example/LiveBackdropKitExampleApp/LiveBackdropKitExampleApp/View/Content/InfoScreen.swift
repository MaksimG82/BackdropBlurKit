//
//  InfoScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI

/// Explains LiveBackdropKit's two effect pipelines and how to use the example app, shown as the
/// app's first tab.
struct InfoScreen: View {

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    simulatorWarning
                    overview
                    cpuSnapshotSection
                    layerEffectSection
                    usageSection
                }
                .padding()
            }
            .navigationTitle("Info")
        }
    }
}

// MARK: - Sections

private extension InfoScreen {

    /// Warns that the simulator renders on the CPU, so effect performance there is not
    /// representative of a real device.
    var simulatorWarning: some View {
        Label {
            Text("The simulator renders on the CPU, not the GPU — performance and visuals here won't match a real device. Test on a physical device.")
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
        .font(.callout)
        .padding()
        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }

    /// A short introduction to the library and its two pipelines.
    var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LiveBackdropKit")
                .font(.title2.bold())
            Text("A library of live backdrop effects for SwiftUI. Two independent pipelines are included, each with its own tradeoffs.")
                .font(.body)
        }
    }

    var cpuSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CPU Snapshot")
                .font(.headline)
            Text("Captures the background as a bitmap on the CPU, then applies a Core Image filter on the GPU. Slower, and can't render behind views backed by special layers (e.g. system backdrops). Works well for fixed backgrounds with moving targets.")
                .font(.body)
        }
    }

    var layerEffectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Layer Effect")
                .font(.headline)
            Text("Runs entirely on the GPU via SwiftUI's .layerEffect shaders, with no snapshot step. Faster and more reliable than the CPU pipeline.")
                .font(.body)
        }
    }

    var usageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Using This App")
                .font(.headline)
            Text("Switch between scenarios on the GPU and CPU tabs, then use the settings panel to adjust the applied effect and background (checkerboard or your own photo).")
                .font(.body)
        }
    }
}

#Preview {
    InfoScreen()
}
