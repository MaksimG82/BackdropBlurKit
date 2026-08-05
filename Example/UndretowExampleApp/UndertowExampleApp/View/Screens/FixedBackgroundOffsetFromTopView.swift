//
//  FixedBackgroundOffsetFromTopView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 28.07.26.
//

import SwiftUI
import Undertow

/// A fixed, non-scrolling block at the top of the screen with the scrolling backdrop
/// starting exactly at its bottom edge, demonstrating that the capture pipeline correctly
/// computes its source rect when the effect source doesn't span the full screen from the top.
///
/// The block's height is runtime-adjustable so the boundary between the fixed block and the
/// scrolling area can be moved to exercise edge cases.
struct FixedBackgroundOffsetFromTopView: View {

    // MARK: - Property Wrappers

    @State private var blockHeight: CGFloat = 170

    /// Incremented on each panel tap, driving `.sensoryFeedback`'s trigger.
    @State private var tapCount = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            fixedBlock

            ZStack {
                scrollingBackdrop
                    .effectSource(navigationBarOverlap: .none)

                targetView
                    .effectTarget()
            }
            .frame(maxHeight: .infinity)
        }
        .effectCoordinator()
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension FixedBackgroundOffsetFromTopView {

    /// The fixed, non-scrolling block whose height defines the effect source's top offset.
    var fixedBlock: some View {
        VStack(spacing: 12) {
            Text("Fixed block")
                .font(.headline)

            Text("\(Int(blockHeight)) pt")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            Slider(value: $blockHeight, in: 150...500)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(height: blockHeight)
        .background(Color(.systemGray5))
    }

    var scrollingBackdrop: some View {
        ScrollView {
            CheckerboardBackground()
                .frame(height: 2000)
        }
    }

    /// A fixed panel rendered above the scrolling content. Tapping it confirms it's live and
    /// hit-testable.
    var targetView: some View {
        Text("Tap me")
            .font(.headline)
            .frame(width: 260, height: 260)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { tapCount += 1 }
            .effectTarget()
            .sensoryFeedback(.impact, trigger: tapCount)
    }
}

#Preview {
    FixedBackgroundOffsetFromTopView()
}
