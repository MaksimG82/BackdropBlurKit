//
//  BlurSource.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI
import os

/// A SwiftUI representable that renders background content in an isolated `UIHostingController`,
/// enabling clean snapshots free of floating blur-target views.
public struct BlurSource<Content: View>: UIViewControllerRepresentable {

    /// Whether this capture region can ever overlap a translucent navigation bar.
    let navigationBarOverlap: NavigationBarOverlap

    /// The background content to render and snapshot.
    let content: () -> Content

    /// Called when processed snapshots keyed by blur configuration are available.
    let onProcessedSnapshot: ([BlurConfiguration: UIImage]) -> Void

    /// Creates a `BlurSource` with the given background content and processed snapshot callback.
    /// - Parameters:
    ///   - navigationBarOverlap: Whether this capture region can ever overlap a translucent
    ///     navigation bar.
    ///   - content: The background content to render in isolation.
    ///   - onProcessedSnapshot: A closure invoked with processed snapshots keyed by configuration.
    public init(
        navigationBarOverlap: NavigationBarOverlap,
        @ViewBuilder content: @escaping () -> Content,
        onProcessedSnapshot: @escaping ([BlurConfiguration: UIImage]) -> Void
    ) {
        self.navigationBarOverlap = navigationBarOverlap
        self.content = content
        self.onProcessedSnapshot = onProcessedSnapshot
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIViewController(context: Context) -> BlurHostingController<Content> {
        let controller = BlurHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        controller.onAppear = {
            logEvent("BlurSource.onAppear (viewDidAppear)")
            context.coordinator.start()
            // Mirrors `onLayout`'s bind call rather than relying on the implicit assumption
            // that `onLayout` already ran by the time `viewDidAppear` fires — that ordering
            // isn't a dependency this should lean on.
            if let view = context.coordinator.hostingController?.view {
                context.coordinator.bindScrollTracking(to: view)
            }
            // A final safety-net capture once the view is confirmed on screen: `viewDidAppear`
            // is a distinct lifecycle event from `onLayout`'s cadence and worth capturing
            // against in its own right.
            context.coordinator.requestSnapshot()
        }
        controller.onDisappear = {
            logEvent("BlurSource.onDisappear (viewDidDisappear)")
            context.coordinator.stop()
        }
        controller.onTraitChange = { [weak coordinator = context.coordinator] in
            logEvent("BlurSource.onTraitChange (interface style / content size category)")
            coordinator?.requestSnapshot()
        }
        controller.onLayout = { [weak coordinator = context.coordinator] in
            guard let view = coordinator?.hostingController?.view else { return }
            logEvent("BlurSource.onLayout (viewDidLayoutSubviews)")
            // Core, plain-screen-relevant: starts the display link on first layout rather than
            // waiting for viewDidAppear. Layout can complete well before viewDidAppear fires
            // for reasons that have nothing to do with navigation transitions, so starting here
            // minimizes the gap before the first capture. Idempotent — safe to call on every
            // layout pass and again from onAppear.
            coordinator?.start()
            coordinator?.bindScrollTracking(to: view)
            coordinator?.requestSnapshot()
        }
        context.coordinator.store = context.environment.blurSnapshotStore
        context.coordinator.hostingController = controller
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
        context.coordinator.navigationBarOverlap = navigationBarOverlap
        context.coordinator.store?.onCaptureRectChanged = { [weak coordinator = context.coordinator] in
            coordinator?.requestSnapshot()
        }
        return controller
    }

    public func updateUIViewController(_ uiViewController: BlurHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
        context.coordinator.navigationBarOverlap = navigationBarOverlap
    }
}
