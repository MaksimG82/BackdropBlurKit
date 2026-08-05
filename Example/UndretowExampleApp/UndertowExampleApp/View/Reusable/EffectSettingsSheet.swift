//
//  EffectSettingsSheet.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI
import PhotosUI
import Undertow

/// A reusable settings sheet for any GPU `.layerEffect` scenario — an effect picker/parameters
/// tab and a background picker/parameters tab, reading and writing the caller's
/// `LayerEffectConfiguration` and `ScenarioBackground` directly via `Binding` (no separate
/// settings state to keep in sync, and no dependency on any particular scenario's view model —
/// every `.layerEffectSource()` scenario stores these same two types, so one sheet type covers
/// all of them).
struct EffectSettingsSheet: View {

    /// Which top-level settings tab is active.
    private enum Tab: String, CaseIterable {
        case effect = "Effect"
        case background = "Background"
    }

    // MARK: - Properties

    @Binding var configuration: LayerEffectConfiguration
    @Binding var background: ScenarioBackground

    /// The background kinds offered in the background picker — scenario-dependent (a scrolling
    /// background excludes `.photo`; see `ScenarioBackgroundKind.availableKinds(forMovingBackground:)`).
    var availableBackgroundKinds: [ScenarioBackgroundKind] = ScenarioBackgroundKind.allCases

    // MARK: - Property Wrappers

    @State private var tab: Tab = .effect

    /// The photo item currently picked from the system library, before it's loaded into an `Image`.
    @State private var photoPickerItem: PhotosPickerItem?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabPicker

                switch tab {
                case .effect:
                    effectSettings
                case .background:
                    backgroundSettings
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Tab Picker

private extension EffectSettingsSheet {

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

private extension EffectSettingsSheet {

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
    /// parameters on change.
    var kindBinding: Binding<LayerEffectKind> {
        Binding(
            get: { LayerEffectKind(configuration) },
            set: { configuration = $0.defaultConfiguration }
        )
    }

    /// The tunable parameters for the currently selected effect.
    @ViewBuilder
    var effectParameters: some View {
        switch configuration {
        case .invert:
            invertSection
        case .gaussianBlur:
            gaussianBlurSection
        case .colorPlanes:
            colorPlanesSection
        case .emboss:
            embossSection
        case .water:
            waterSection
        case .wave:
            waveSection
        case .shimmer:
            shimmerSection
        case .whiteNoise:
            whiteNoiseSection
        case .rainbowNoise:
            rainbowNoiseSection
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
            // as visually indistinguishable from 15 (Inferno's own default for its equivalent
            // `variableBlur` parameter) on typical content.
            SettingSlider(
                title: "Max Samples",
                value: gaussianBlurMaxSamplesBinding,
                range: 1...30,
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
                guard case let .gaussianBlur(radius, _) = configuration else { return 10 }
                return radius
            },
            set: { newRadius in
                guard case let .gaussianBlur(_, maxSamples) = configuration else { return }
                configuration = .gaussianBlur(radius: newRadius, maxSamples: maxSamples)
            }
        )
    }

    var gaussianBlurMaxSamplesBinding: Binding<Float> {
        Binding(
            get: {
                guard case let .gaussianBlur(_, maxSamples) = configuration else { return 5 }
                return maxSamples
            },
            set: { newMaxSamples in
                guard case let .gaussianBlur(radius, _) = configuration else { return }
                configuration = .gaussianBlur(radius: radius, maxSamples: newMaxSamples)
            }
        )
    }

    /// Invert has no tunable parameters — just its description.
    var invertSection: some View {
        Section {
        } footer: {
            Text("Inverts the sampled color's RGB channels uniformly across the backdrop.")
        }
    }

    /// Color Planes' parameter: how far the red and blue channels shift apart from green.
    var colorPlanesSection: some View {
        Section {
            // Horizontal offset, in points, applied to the red and blue channels.
            SettingSlider(
                title: "Offset X",
                value: colorPlanesOffsetXBinding,
                range: -20...20,
                step: 1,
                format: .integer
            )

            // Vertical offset, in points, applied to the red and blue channels.
            SettingSlider(
                title: "Offset Y",
                value: colorPlanesOffsetYBinding,
                range: -20...20,
                step: 1,
                format: .integer
            )
        } header: {
            Text("Color Planes")
        } footer: {
            Text("An RGB-shift/glitch effect that offsets the red and blue channels apart from green.")
        }
    }

    var colorPlanesOffsetXBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .colorPlanes(offset) = configuration else { return 6 }
                return offset.width
            },
            set: { newX in
                guard case let .colorPlanes(offset) = configuration else { return }
                configuration = .colorPlanes(offset: CGSize(width: newX, height: offset.height))
            }
        )
    }

    var colorPlanesOffsetYBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .colorPlanes(offset) = configuration else { return 6 }
                return offset.height
            },
            set: { newY in
                guard case let .colorPlanes(offset) = configuration else { return }
                configuration = .colorPlanes(offset: CGSize(width: offset.width, height: newY))
            }
        )
    }

    /// Emboss's parameter: how strongly the offset pixels are added/subtracted.
    var embossSection: some View {
        Section {
            // How pronounced the relief effect looks — higher values dig deeper shadows and
            // highlights.
            SettingSlider(
                title: "Strength",
                value: embossStrengthBinding,
                range: 0...20,
                step: 0.5,
                format: .fractionalOne
            )
        } header: {
            Text("Emboss")
        } footer: {
            Text("An embossing/relief effect that adds or subtracts offset pixels to simulate raised edges.")
        }
    }

    var embossStrengthBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .emboss(strength) = configuration else { return 4 }
                return strength
            },
            set: { newStrength in
                configuration = .emboss(strength: newStrength)
            }
        )
    }

    /// Water's parameters: ripple speed, strength, and frequency. Ranges and defaults match
    /// both `LayerEffectConfiguration`'s doc comment and Inferno's own demo app defaults.
    var waterSection: some View {
        Section {
            // How fast the ripples animate.
            SettingSlider(
                title: "Speed",
                value: waterSpeedBinding,
                range: 0.5...10,
                step: 0.5,
                format: .fractionalOne
            )

            // How pronounced the rippling distortion is.
            SettingSlider(
                title: "Strength",
                value: waterStrengthBinding,
                range: 1...5,
                step: 0.5,
                format: .fractionalOne
            )

            // How often ripples occur across the surface.
            SettingSlider(
                title: "Frequency",
                value: waterFrequencyBinding,
                range: 5...25,
                step: 1,
                format: .integer
            )
        } header: {
            Text("Water")
        } footer: {
            Text("A rippling water-distortion effect, animated continuously over time.")
        }
    }

    var waterSpeedBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .water(speed, _, _) = configuration else { return 3 }
                return speed
            },
            set: { newSpeed in
                guard case let .water(_, strength, frequency) = configuration else { return }
                configuration = .water(speed: newSpeed, strength: strength, frequency: frequency)
            }
        )
    }

    var waterStrengthBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .water(_, strength, _) = configuration else { return 3 }
                return strength
            },
            set: { newStrength in
                guard case let .water(speed, _, frequency) = configuration else { return }
                configuration = .water(speed: speed, strength: newStrength, frequency: frequency)
            }
        )
    }

    var waterFrequencyBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .water(_, _, frequency) = configuration else { return 10 }
                return frequency
            },
            set: { newFrequency in
                guard case let .water(speed, strength, _) = configuration else { return }
                configuration = .water(speed: speed, strength: strength, frequency: newFrequency)
            }
        )
    }

    /// Wave's parameters: ripple speed, smoothing, and strength.
    var waveSection: some View {
        Section {
            // How fast the waves ripple.
            SettingSlider(
                title: "Speed",
                value: waveSpeedBinding,
                range: 0...20,
                step: 1,
                format: .integer
            )

            // How much the ripples are smoothed — higher values produce a gentler effect.
            SettingSlider(
                title: "Smoothing",
                value: waveSmoothingBinding,
                range: 0...50,
                step: 1,
                format: .integer
            )

            // How pronounced the ripple effect is.
            SettingSlider(
                title: "Strength",
                value: waveStrengthBinding,
                range: 0...20,
                step: 1,
                format: .integer
            )
        } header: {
            Text("Wave")
        } footer: {
            Text("A uniform wave-distortion effect that offsets each pixel's Y position by an amount of its X position.")
        }
    }

    var waveSpeedBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .wave(speed, _, _) = configuration else { return 5 }
                return speed
            },
            set: { newSpeed in
                guard case let .wave(_, smoothing, strength) = configuration else { return }
                configuration = .wave(speed: newSpeed, smoothing: smoothing, strength: strength)
            }
        )
    }

    var waveSmoothingBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .wave(_, smoothing, _) = configuration else { return 10 }
                return smoothing
            },
            set: { newSmoothing in
                guard case let .wave(speed, _, strength) = configuration else { return }
                configuration = .wave(speed: speed, smoothing: newSmoothing, strength: strength)
            }
        )
    }

    var waveStrengthBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .wave(_, _, strength) = configuration else { return 5 }
                return strength
            },
            set: { newStrength in
                guard case let .wave(speed, smoothing, _) = configuration else { return }
                configuration = .wave(speed: speed, smoothing: smoothing, strength: newStrength)
            }
        )
    }

    /// Shimmer's parameters: loop duration, gradient width, peak lightness, sweep direction, and
    /// band angle.
    var shimmerSection: some View {
        Section {
            // How long a single shimmer loop takes, in seconds.
            SettingSlider(
                title: "Duration",
                value: shimmerDurationBinding,
                range: 0.5...5,
                step: 0.5,
                format: .fractionalOne
            )

            // The shimmer gradient's width, in UV space (0–1 spans the full backdrop).
            SettingSlider(
                title: "Gradient Width",
                value: shimmerGradientWidthBinding,
                range: 0.05...1,
                step: 0.05,
                format: .fractionalTwo
            )

            // The peak lightness at the center of the gradient sweep.
            SettingSlider(
                title: "Max Lightness",
                value: shimmerMaxLightnessBinding,
                range: 0...1,
                step: 0.05,
                format: .fractionalTwo
            )

            // The direction the gradient sweeps in, in degrees (0 = rightward).
            SettingSlider(
                title: "Direction",
                value: shimmerDirectionBinding,
                range: 0...360,
                step: 5,
                format: .integer
            )

            // The orientation of the band itself, in degrees (0 = vertical).
            SettingSlider(
                title: "Angle",
                value: shimmerAngleBinding,
                range: 0...180,
                step: 5,
                format: .integer
            )
        } header: {
            Text("Shimmer")
        } footer: {
            Text("A shimmering gradient sweep that loops continuously across the backdrop.")
        }
    }

    var shimmerDurationBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .shimmer(duration, _, _, _, _) = configuration else { return 3 }
                return duration
            },
            set: { newDuration in
                guard case let .shimmer(_, gradientWidth, maxLightness, direction, angle) = configuration else { return }
                configuration = .shimmer(animationDuration: newDuration, gradientWidth: gradientWidth, maxLightness: maxLightness, direction: direction, angle: angle)
            }
        )
    }

    var shimmerGradientWidthBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .shimmer(_, gradientWidth, _, _, _) = configuration else { return 0.3 }
                return gradientWidth
            },
            set: { newGradientWidth in
                guard case let .shimmer(duration, _, maxLightness, direction, angle) = configuration else { return }
                configuration = .shimmer(animationDuration: duration, gradientWidth: newGradientWidth, maxLightness: maxLightness, direction: direction, angle: angle)
            }
        )
    }

    var shimmerMaxLightnessBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .shimmer(_, _, maxLightness, _, _) = configuration else { return 0.9 }
                return maxLightness
            },
            set: { newMaxLightness in
                guard case let .shimmer(duration, gradientWidth, _, direction, angle) = configuration else { return }
                configuration = .shimmer(animationDuration: duration, gradientWidth: gradientWidth, maxLightness: newMaxLightness, direction: direction, angle: angle)
            }
        )
    }

    var shimmerDirectionBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .shimmer(_, _, _, direction, _) = configuration else { return 0 }
                return direction
            },
            set: { newDirection in
                guard case let .shimmer(duration, gradientWidth, maxLightness, _, angle) = configuration else { return }
                configuration = .shimmer(animationDuration: duration, gradientWidth: gradientWidth, maxLightness: maxLightness, direction: newDirection, angle: angle)
            }
        )
    }

    var shimmerAngleBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .shimmer(_, _, _, _, angle) = configuration else { return 0 }
                return angle
            },
            set: { newAngle in
                guard case let .shimmer(duration, gradientWidth, maxLightness, direction, _) = configuration else { return }
                configuration = .shimmer(animationDuration: duration, gradientWidth: gradientWidth, maxLightness: maxLightness, direction: direction, angle: newAngle)
            }
        )
    }

    /// White Noise has no tunable parameters — just its description.
    var whiteNoiseSection: some View {
        Section {
        } footer: {
            Text("Dynamic, grayscale noise animated continuously over time.")
        }
    }

    /// Rainbow Noise has no tunable parameters — just its description.
    var rainbowNoiseSection: some View {
        Section {
        } footer: {
            Text("Dynamic, multi-colored noise animated continuously over time.")
        }
    }
}

// MARK: - Background Settings

private extension EffectSettingsSheet {

    var backgroundSettings: some View {
        Form {
            Section {
                Picker("Background", selection: backgroundKindBinding) {
                    ForEach(availableBackgroundKinds) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
            }

            backgroundParameters
        }
    }

    /// Binds the background picker to the background's kind, resetting to that kind's default
    /// parameters on change.
    var backgroundKindBinding: Binding<ScenarioBackgroundKind> {
        Binding(
            get: { ScenarioBackgroundKind(background) },
            set: { background = $0.defaultBackground }
        )
    }

    /// The tunable parameters for the currently selected background.
    @ViewBuilder
    var backgroundParameters: some View {
        switch background {
        case .checkerboard:
            checkerboardSection
        case .photo:
            photoSection
        }
    }

    /// Checkerboard's parameters: square size and the pattern's two alternating colors.
    var checkerboardSection: some View {
        Section {
            // The size of each individual square, in points. Smaller squares make blur/edge
            // artifacts easier to spot; larger squares are easier to see at a glance.
            SettingSlider(
                title: "Square Size",
                value: checkerboardSquareSizeBinding,
                range: 8...64,
                step: 1,
                format: .integer
            )

            ColorPicker("Primary Color", selection: checkerboardPrimaryColorBinding)
            ColorPicker("Secondary Color", selection: checkerboardSecondaryColorBinding)
        } header: {
            Text("Checkerboard")
        } footer: {
            Text("A high-contrast checkerboard pattern that makes blur quality and edge artifacts clearly visible.")
        }
    }

    var checkerboardSquareSizeBinding: Binding<CGFloat> {
        Binding(
            get: {
                guard case let .checkerboard(squareSize, _, _) = background else { return 64 }
                return squareSize
            },
            set: { newSquareSize in
                guard case let .checkerboard(_, primaryColor, secondaryColor) = background else { return }
                background = .checkerboard(squareSize: newSquareSize, primaryColor: primaryColor, secondaryColor: secondaryColor)
            }
        )
    }

    var checkerboardPrimaryColorBinding: Binding<Color> {
        Binding(
            get: {
                guard case let .checkerboard(_, primaryColor, _) = background else { return .orange }
                return primaryColor
            },
            set: { newPrimaryColor in
                guard case let .checkerboard(squareSize, _, secondaryColor) = background else { return }
                background = .checkerboard(squareSize: squareSize, primaryColor: newPrimaryColor, secondaryColor: secondaryColor)
            }
        )
    }

    var checkerboardSecondaryColorBinding: Binding<Color> {
        Binding(
            get: {
                guard case let .checkerboard(_, _, secondaryColor) = background else { return .indigo }
                return secondaryColor
            },
            set: { newSecondaryColor in
                guard case let .checkerboard(squareSize, primaryColor, _) = background else { return }
                background = .checkerboard(squareSize: squareSize, primaryColor: primaryColor, secondaryColor: newSecondaryColor)
            }
        )
    }

    /// Photo's only parameter: the picked image itself, via the system photo library.
    var photoSection: some View {
        Section {
            PhotosPicker("Choose Photo", selection: $photoPickerItem, matching: .images)
        } header: {
            Text("Photo")
        } footer: {
            Text("A photo from your library, filling the backdrop.")
        }
        .task(id: photoPickerItem) {
            guard let photoPickerItem,
                  let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            background = .photo(image: Image(uiImage: uiImage))
        }
    }
}

#Preview {
    @Previewable @State var configuration: LayerEffectConfiguration = .gaussianBlur(radius: 10, maxSamples: 5)
    @Previewable @State var background: ScenarioBackground = .defaultCheckerboard
    EffectSettingsSheet(configuration: $configuration, background: $background)
}
