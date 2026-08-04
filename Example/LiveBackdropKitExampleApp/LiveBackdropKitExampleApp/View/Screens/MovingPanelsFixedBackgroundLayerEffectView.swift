//
//  MovingPanelsFixedBackgroundLayerEffectView.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI
import LiveBackdropKit

/// A single fixed (non-scrolling) GPU `.layerEffect` source with multiple effect targets
/// scrolling over it in a `ScrollView`/`LazyVStack`, each cell tracking its own frame
/// independently as it scrolls — the `.layerEffect` pipeline's counterpart to
/// `MovingPanelsFixedBackgroundView`'s CPU-snapshot scenario, with source/target mobility roles
/// kept identical (fixed source, moving targets) to test whether that combination carries over
/// unchanged. Unlike `MovingBackgroundFixedPanelsLayerEffectView` (moving source, fixed
/// targets), this is the inverse pairing and has not been previously exercised on this
/// pipeline.
struct MovingPanelsFixedBackgroundLayerEffectView: View {

    // MARK: - Constants

    private let cellCount = 16

    // MARK: - Property Wrappers

    /// The effect applied to the fixed backdrop.
    @State private var configuration: LayerEffectConfiguration = .gaussianBlur(radius: 10, maxSamples: 5)

    /// Incremented on each cell tap, driving `.sensoryFeedback`'s trigger.
    @State private var tapCount = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // `.layerEffectSource()` sits directly on the fixed backdrop content. It does not
            // scroll, so its internal GeometryReader's measured origin is constant — only the
            // targets' global frames change as the list scrolls underneath.
            CheckerboardBackground()
                .layerEffectSource(configuration: configuration, cornerRadius: 16)
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<cellCount, id: \.self) { index in
                        cell(index)
                    }
                }
                .padding()
            }
        }
        .layerEffectCoordinator()
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension MovingPanelsFixedBackgroundLayerEffectView {

    /// A single scrolling effect-target cell. Tapping it confirms it's live and hit-testable.
    func cell(_ index: Int) -> some View {
        Text("Tap me")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { tapCount += 1 }
            .layerEffectTarget()
            .sensoryFeedback(.impact, trigger: tapCount)
    }
}

#Preview {
    MovingPanelsFixedBackgroundLayerEffectView()
}
