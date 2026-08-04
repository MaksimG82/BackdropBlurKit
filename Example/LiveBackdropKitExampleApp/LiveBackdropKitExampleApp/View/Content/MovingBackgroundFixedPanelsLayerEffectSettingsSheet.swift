//
//  MovingBackgroundFixedPanelsLayerEffectSettingsSheet.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI
import LiveBackdropKit

/// The settings sheet for `MovingBackgroundFixedPanelsLayerEffectView` — an effect picker plus
/// that effect's tunable parameters, reading and writing the scenario's own view model directly
/// (no separate settings state to keep in sync).
///
/// A `Background` tab is reserved above the effect controls for scenario background selection
/// (checkerboard/photo/gradient/video), not yet implemented — this sheet currently only shows
/// the `Effect` tab's content.
struct MovingBackgroundFixedPanelsLayerEffectSettingsSheet: View {

    /// Which top-level settings tab is active.
    private enum Tab: String, CaseIterable {
        case effect = "Effect"
        case background = "Background"
    }

    // MARK: - Properties

    let viewModel: MovingBackgroundFixedPanelsLayerEffectViewModel

    // MARK: - Property Wrappers

    @State private var tab: Tab = .effect

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabPicker

                switch tab {
                case .effect:
                    effectSettings
                case .background:
                    backgroundSettingsPlaceholder
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Tab Picker

private extension MovingBackgroundFixedPanelsLayerEffectSettingsSheet {

    var tabPicker: some View {
        Picker("Settings tab", selection: $tab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

// MARK: - Effect Settings

private extension MovingBackgroundFixedPanelsLayerEffectSettingsSheet {

    var effectSettings: some View {
        Form {
            Section {
                Picker("Effect", selection: kindBinding) {
                    ForEach(LayerEffectKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
            }

            effectParameters
        }
    }

    /// Binds the effect picker to the configuration's kind, resetting to that kind's default
    /// parameters on change via `selectKind(_:)`.
    var kindBinding: Binding<LayerEffectKind> {
        Binding(
            get: { LayerEffectKind(viewModel.configuration) },
            set: { viewModel.selectKind($0) }
        )
    }

    /// The tunable parameters for the currently selected effect. Only `.gaussianBlur` has
    /// sliders wired up so far — every other kind shows its description with no controls,
    /// applying its default parameters until its own sliders are added.
    @ViewBuilder
    var effectParameters: some View {
        switch viewModel.configuration {
        case .gaussianBlur:
            gaussianBlurSection
        case .invert, .colorPlanes, .emboss, .water, .wave, .shimmer, .whiteNoise, .rainbowNoise:
            EmptyView()
        }
    }

    /// Gaussian Blur's parameters: blur radius and the per-axis sample count that trades
    /// visual smoothness for scroll performance.
    var gaussianBlurSection: some View {
        Section {
            // Blur radius, in points — how far the effect samples in each direction. Larger
            // values blur more but cost more per-pixel work.
            SettingSlider(
                title: "Radius",
                value: gaussianBlurRadiusBinding,
                range: 1...40,
                step: 1,
                format: .integer
            )

            // Max samples per axis pass — the sampling budget spent approximating the blur.
            // Lower is cheaper; per `LayerEffectConfiguration`'s doc comment, 5 already reads
            // as visually indistinguishable from 15 on typical content.
            SettingSlider(
                title: "Max Samples",
                value: gaussianBlurMaxSamplesBinding,
                range: 1...20,
                step: 1,
                format: .integer
            )
        } header: {
            Text("Gaussian Blur")
        } footer: {
            Text("A two-pass separable blur applied uniformly across the backdrop. Radius controls how far it blurs; Max Samples trades quality for performance.")
        }
    }

    var gaussianBlurRadiusBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .gaussianBlur(radius, _) = viewModel.configuration else { return 10 }
                return radius
            },
            set: { newRadius in
                guard case let .gaussianBlur(_, maxSamples) = viewModel.configuration else { return }
                viewModel.configuration = .gaussianBlur(radius: newRadius, maxSamples: maxSamples)
            }
        )
    }

    var gaussianBlurMaxSamplesBinding: Binding<Float> {
        Binding(
            get: {
                guard case let .gaussianBlur(_, maxSamples) = viewModel.configuration else { return 5 }
                return maxSamples
            },
            set: { newMaxSamples in
                guard case let .gaussianBlur(radius, _) = viewModel.configuration else { return }
                viewModel.configuration = .gaussianBlur(radius: radius, maxSamples: newMaxSamples)
            }
        )
    }
}

// MARK: - Background Settings (Placeholder)

private extension MovingBackgroundFixedPanelsLayerEffectSettingsSheet {

    var backgroundSettingsPlaceholder: some View {
        ContentUnavailableView(
            "Background settings coming soon",
            systemImage: "photo.on.rectangle"
        )
    }
}

#Preview {
    MovingBackgroundFixedPanelsLayerEffectSettingsSheet(
        viewModel: MovingBackgroundFixedPanelsLayerEffectViewModel()
    )
}
