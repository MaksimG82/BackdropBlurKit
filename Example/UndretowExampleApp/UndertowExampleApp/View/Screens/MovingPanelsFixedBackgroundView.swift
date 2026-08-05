//
//  MovingPanelsFixedBackgroundView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 28.07.26.
//

import SwiftUI
import Undertow

/// A single fixed (non-scrolling) effect source with multiple effect targets scrolling over it
/// inside a `ScrollView`/`LazyVStack`, each cell tracking its own frame independently as it
/// scrolls — the demo app's primary test of concurrent multi-target support (2+ targets against
/// one source).
struct MovingPanelsFixedBackgroundView: View {

    // MARK: - Constants

    private let cellCount = 16

    // MARK: - Property Wrappers

    /// Incremented on each cell tap, driving `.sensoryFeedback`'s trigger.
    @State private var tapCount = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            CheckerboardBackground()
                .ignoresSafeArea()
                .effectSource(navigationBarOverlap: .none, captureMode: .unionFrame)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<cellCount, id: \.self) { index in
                        cell(index)
                    }
                }
                .padding()
            }
        }
        .effectCoordinator()
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension MovingPanelsFixedBackgroundView {

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
            .effectTarget(cornerRadius: 16)
            .sensoryFeedback(.impact, trigger: tapCount)
    }
}

#Preview {
    MovingPanelsFixedBackgroundView()
}
