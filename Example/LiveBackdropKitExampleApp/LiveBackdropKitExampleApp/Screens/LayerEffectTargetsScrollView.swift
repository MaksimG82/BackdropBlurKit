//
//  LayerEffectTargetsScrollView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI
import LiveBackdropKit

/// Five real, fixed-position SwiftUI target markers, each using the public
/// `.layerEffectTarget()` API to report its frame — the GPU `.layerEffect` pipeline's
/// counterpart to `SimpleScrollView`'s CPU-snapshot `.effectTarget()` usage. The frame
/// collection this scenario originally prototyped locally (a hand-rolled `PreferenceKey` +
/// `@State`) has been promoted into `LiveBackdropKit` itself — see
/// `LayerEffectCoordinatorModifier`, `LayerEffectTargetViewModifier`, and
/// `LayerEffectSourceViewModifier` — so nothing coordinator-shaped lives in this file anymore.
struct LayerEffectTargetsScrollView: View {

    /// The effect applied to `scrollingBackdrop`.
    @State private var configuration: LayerEffectConfiguration = .shimmer(animationDuration: 2, gradientWidth: 3, maxLightness: 2, angle: 120)
    
    /*.gaussianBlur(radius: 10, maxSamples: 5)*/

    var body: some View {
        ZStack {
            scrollingBackdrop
                .ignoresSafeArea()

            targetMarkers
        }
        .layerEffectCoordinator()
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension LayerEffectTargetsScrollView {

    var scrollingBackdrop: some View {
        ScrollView {
            // `.layerEffectSource()` must sit directly on the scrolled content (not on the
            // `ScrollView` itself) so its internal GeometryReader measures the content's own,
            // continuously-changing scroll origin — and `.frame(height:)` must come after it,
            // since that GeometryReader has no intrinsic size (see the modifier's doc comment).
            CheckerboardBackground()
                .layerEffectSource(configuration: configuration, cornerRadius: 16)
                .frame(height: 2000)
        }
    }

    /// Four small corner markers and one larger centered marker, all pinned to fixed screen
    /// positions expressed as fractions/insets of the viewport size.
    var targetMarkers: some View {
        GeometryReader { viewportGeometry in
            let size = viewportGeometry.size
            let inset: CGFloat = 70

            ZStack {
                marker(label: "A", color: .pink, size: CGSize(width: 90, height: 90))
                    .position(x: inset, y: inset)
                marker(label: "B", color: .green, size: CGSize(width: 90, height: 90))
                    .position(x: size.width - inset, y: inset)
                marker(label: "C", color: .yellow, size: CGSize(width: 90, height: 90))
                    .position(x: inset, y: size.height - inset)
                marker(label: "D", color: .cyan, size: CGSize(width: 90, height: 90))
                    .position(x: size.width - inset, y: size.height - inset)
                marker(label: "E", color: .white, size: CGSize(width: 180, height: 340))
                    .position(x: size.width / 2, y: size.height / 2)
            }
            .allowsHitTesting(false)
        }
    }

    /// A visible marker: a stroked, labeled rect. `.layerEffectTarget()` reports its frame;
    /// the stroke/label are only so it's identifiable on screen against its mask window.
    func marker(label: String, color: Color, size: CGSize) -> some View {
        Text(label)
            .font(.headline)
            .foregroundStyle(color)
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 2)
            )
            .layerEffectTarget()
    }
}

#Preview {
    LayerEffectTargetsScrollView()
}
