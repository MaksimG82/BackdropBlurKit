//
//  EffectSource.swift
//  Undertow
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI
import os

/// A SwiftUI representable that renders background content in an isolated `UIHostingController`,
/// enabling clean snapshots free of floating effect-target views.
public struct EffectSource<Content: View>: UIViewControllerRepresentable {

    /// Whether this capture region can ever overlap a translucent navigation bar.
    let navigationBarOverlap: NavigationBarOverlap

    /// Which region to render when capturing a snapshot — cropped to the union of target
    /// frames, or the full source view.
    let captureMode: CaptureMode

    /// What triggers a capture while scrolling. See `CaptureTrigger`'s doc comment for the
    /// v0.0.1 status of this and `captureExecution` together.
    let captureTrigger: CaptureTrigger

    /// How a triggered capture actually runs. See `CaptureExecution`.
    let captureExecution: CaptureExecution

    /// The background content to render and snapshot.
    let content: () -> Content

    /// Called when processed snapshots keyed by effect configuration are available.
    let onProcessedSnapshot: ([EffectConfiguration: UIImage]) -> Void

    /// Creates an `EffectSource` with the given background content and processed snapshot callback.
    /// - Parameters:
    ///   - navigationBarOverlap: Whether this capture region can ever overlap a translucent
    ///     navigation bar.
    ///   - captureMode: Which region to render when capturing a snapshot. Defaults to
    ///     `.unionFrame`, the production capture mode.
    ///   - captureTrigger: What triggers a capture while scrolling. Defaults to
    ///     `.tickSynchronized`, the original, regression-free behavior.
    ///   - captureExecution: How a triggered capture actually runs. Defaults to `.synchronous`.
    ///   - content: The background content to render in isolation.
    ///   - onProcessedSnapshot: A closure invoked with processed snapshots keyed by configuration.
    public init(
        navigationBarOverlap: NavigationBarOverlap,
        captureMode: CaptureMode = .unionFrame,
        captureTrigger: CaptureTrigger = .tickSynchronized,
        captureExecution: CaptureExecution = .synchronous,
        @ViewBuilder content: @escaping () -> Content,
        onProcessedSnapshot: @escaping ([EffectConfiguration: UIImage]) -> Void
    ) {
        self.navigationBarOverlap = navigationBarOverlap
        self.captureMode = captureMode
        self.captureTrigger = captureTrigger
        self.captureExecution = captureExecution
        self.content = content
        self.onProcessedSnapshot = onProcessedSnapshot
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIViewController(context: Context) -> EffectHostingController<Content> {
        let controller = EffectHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        controller.onAppear = {
            logEvent("EffectSource.onAppear (viewDidAppear)")
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
            logEvent("EffectSource.onDisappear (viewDidDisappear)")
            context.coordinator.stop()
        }
        controller.onTraitChange = { [weak coordinator = context.coordinator] in
            logEvent("EffectSource.onTraitChange (interface style / content size category)")
            coordinator?.requestSnapshot()
        }
        controller.onLayout = { [weak coordinator = context.coordinator] in
            guard let view = coordinator?.hostingController?.view else { return }
            logEvent("EffectSource.onLayout (viewDidLayoutSubviews)")
            // Core, plain-screen-relevant: starts the display link on first layout rather than
            // waiting for viewDidAppear. Layout can complete well before viewDidAppear fires
            // for reasons that have nothing to do with navigation transitions, so starting here
            // minimizes the gap before the first capture. Idempotent — safe to call on every
            // layout pass and again from onAppear.
            coordinator?.start()
            coordinator?.bindScrollTracking(to: view)
            coordinator?.requestSnapshot()
        }
        context.coordinator.store = context.environment.effectSnapshotStore
        context.coordinator.hostingController = controller
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
        context.coordinator.navigationBarOverlap = navigationBarOverlap
        context.coordinator.captureMode = captureMode
        context.coordinator.captureTrigger = captureTrigger
        context.coordinator.captureExecution = captureExecution
        context.coordinator.store?.onCaptureRectChanged = { [weak coordinator = context.coordinator] in
            coordinator?.requestSnapshot()
        }
        return controller
    }

    public func updateUIViewController(_ uiViewController: EffectHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
        context.coordinator.navigationBarOverlap = navigationBarOverlap
        context.coordinator.captureMode = captureMode
        context.coordinator.captureTrigger = captureTrigger
        context.coordinator.captureExecution = captureExecution
    }
}
