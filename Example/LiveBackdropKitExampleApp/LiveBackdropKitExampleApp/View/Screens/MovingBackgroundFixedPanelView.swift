//
//  MovingBackgroundFixedPanelView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI
import LiveBackdropKit

/// A vertically scrolling checkerboard background with a fixed blurred panel,
/// demonstrating the basic capture-and-blur pipeline.
struct MovingBackgroundFixedPanelView: View {

    /// Incremented on each panel tap, driving `.sensoryFeedback`'s trigger.
    @State private var tapCount = 0

    var body: some View {
        ZStack() {
            scrollingBackdrop
                .ignoresSafeArea()
                .effectSource(
                    navigationBarOverlap: .none,
                    captureMode: .fullScreen,
                    captureTrigger: .tickSynchronized,
                    captureExecution: .synchronous
                )

            targetView
                .effectTarget()
        }
        .effectCoordinator()
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension MovingBackgroundFixedPanelView {

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
    MovingBackgroundFixedPanelView()
}
