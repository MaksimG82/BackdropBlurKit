//
//  InfoScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI

/// Explains Undertow's effect pipeline and how to use the example app, shown as the
/// app's first tab.
struct InfoScreen: View {

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    simulatorWarning
                    overview
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

    /// A short introduction to the library.
    var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Undertow")
                .font(.title2.bold())
            Text("A library of live backdrop effects for SwiftUI. Effects run entirely on the GPU via SwiftUI's shader modifiers.")
                .font(.body)
        }
    }

    var usageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Using This App")
                .font(.headline)
            Text("Switch between scenarios on the Effects tab, then use the settings panel to adjust the applied effect and background.")
                .font(.body)
        }
    }
}

#Preview {
    InfoScreen()
}
