//
//  MovingBackgroundFixedPanelsView.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI
import Undertow

/// Five real, fixed-position SwiftUI target markers, each using the public
/// `.effectTarget()` API to report its frame. The frame collection this scenario
/// originally prototyped locally (a hand-rolled `PreferenceKey` + `@State`) has been promoted
/// into `Undertow` itself — see `EffectCoordinatorModifier`, `EffectTargetViewModifier`,
/// and `EffectSourceViewModifier` — so nothing coordinator-shaped lives in this file anymore.
struct MovingBackgroundFixedPanelsView: View {

    /// Owns the applied `Effect`, shared between this view's rendering and
    /// its settings sheet.
    @State private var viewModel = EffectScenarioViewModel(isBackgroundMoving: true)

    /// Incremented on each marker tap, driving `.sensoryFeedback`'s trigger.
    @State private var tapCount = 0

    /// Whether the settings sheet is currently presented.
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack {
            scrollingBackdrop
                .ignoresSafeArea()

            targetMarkers
        }
        .effectCoordinator()
        .ignoresSafeArea()
        .toolbar { settingsButton }
        .sheet(isPresented: $isSettingsPresented) {
            EffectSettingsSheet(
                configuration: $viewModel.configuration,
                background: $viewModel.background,
                availableBackgroundKinds: viewModel.availableBackgroundKinds
            )
        }
    }
}

// MARK: - Toolbar

private extension MovingBackgroundFixedPanelsView {

    var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
        }
    }
}

// MARK: - Subviews

private extension MovingBackgroundFixedPanelsView {

    var scrollingBackdrop: some View {
        ScrollView {
            // `.effectSource()` must sit directly on the scrolled content (not on the
            // `ScrollView` itself) so its internal GeometryReader measures the content's own,
            // continuously-changing scroll origin — and `.frame(height:)` must come after it,
            // since that GeometryReader has no intrinsic size (see the modifier's doc comment).
            ScenarioBackgroundView(background: viewModel.background)
                .effectSource(configuration: viewModel.configuration)
                .frame(height: 2000)
        }
    }

    /// Four small corner markers and one larger centered marker, all pinned to fixed screen
    /// positions expressed as fractions/insets of the viewport size.
    var targetMarkers: some View {
        GeometryReader { viewportGeometry in
            let size = viewportGeometry.size
            let inset: CGFloat = 70
            let topInset: CGFloat = 140

            ZStack {
                marker(size: CGSize(width: 90, height: 90), cornerRadius: 16)
                    .position(x: inset, y: topInset)
                marker(size: CGSize(width: 90, height: 90), cornerRadius: 16)
                    .position(x: size.width - inset, y: topInset)
                marker(size: CGSize(width: 90, height: 90), cornerRadius: 16)
                    .position(x: inset, y: size.height - inset)
                marker(size: CGSize(width: 90, height: 90), cornerRadius: 16)
                    .position(x: size.width - inset, y: size.height - inset)
                marker(size: CGSize(width: 180, height: 340), cornerRadius: 32)
                    .position(x: size.width / 2, y: size.height / 2)
            }
        }
    }

    /// A visible marker: a stroked, labeled rect. `.effectTarget()` reports its frame;
    /// tapping it confirms the marker is live and hit-testable.
    func marker(size: CGSize, cornerRadius: CGFloat = 0) -> some View {
        Text("Tap me")
            .font(.headline)
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { tapCount += 1 }
            .effectTarget(cornerRadius: cornerRadius)
            .sensoryFeedback(.impact, trigger: tapCount)
    }
}

#Preview {
    MovingBackgroundFixedPanelsView()
}
