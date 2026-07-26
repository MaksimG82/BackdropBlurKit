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

    /// Manages snapshot capture, blur processing, scroll tracking,
    /// and display link lifecycle for a `BlurSource`.
    @MainActor
    public final class Coordinator: NSObject {
        
        /// The hosted view controller providing the isolated render surface.
        weak var hostingController: BlurHostingController<Content>?
        
        /// The shared snapshot store providing the current capture rect.
        weak var store: BlurSnapshotStore?
        
        /// The display link coordinator managing frame-throttled snapshot capture.
        let displayLink = DisplayLinkCoordinator()
        
        /// Tracks scroll views within the hosted hierarchy and controls display link pause state.
        let scrollTracker = ScrollTracker()
        
        /// The processor responsible for applying blur effects to raw snapshots.
        private let processor = BlurSnapshotProcessor()
        
        /// The set of blur configurations to apply to each captured snapshot.
        var configurations: Set<BlurConfiguration> = [.default]
        
        /// Called when processed snapshots are ready for delivery.
        var onProcessedSnapshot: (([BlurConfiguration: UIImage]) -> Void)?

        /// Whether the hosted view is actively scrolling, per `scrollTracker`.
        private var isScrolling = false

        /// Whether a snapshot capture has been requested and is awaiting the next display-link tick.
        private var needsSnapshot = false

        /// Whether this capture region can ever overlap a translucent navigation bar. Defaults to
        /// `.possible` (the safe/correct path) until `makeUIViewController` sets the real value.
        var navigationBarOverlap: NavigationBarOverlap = .possible

        /// Whether at least one snapshot has been delivered for the current appearance.
        /// Reset in `stop()` so a reused instance's next fresh appearance starts over.
        private var hasDeliveredAnySnapshot = false

        /// Whether a capture was skipped while frozen during an active transition, owed once
        /// `transitionCoordinator` goes nil. Reset in `stop()`.
        private var hasPendingCatchUpCapture = false

        override init() {
            super.init()
            displayLink.onFrameUpdate = { [weak self] in
                self?.consumePendingSnapshot()
            }
            scrollTracker.onScrollingChanged = { [weak self] isScrolling in
                guard let self else { return }
                self.isScrolling = isScrolling
                self.refreshDisplayLinkPauseState()
            }
        }

        /// Starts the display link and binds scroll tracking to the hosted view hierarchy.
        func start() {
            displayLink.start()
            if let view = hostingController?.view {
                scrollTracker.bind(to: view)
            }
            refreshDisplayLinkPauseState()
        }

        /// Stops the display link and releases all scroll view observers.
        func stop() {
            displayLink.stop()
            scrollTracker.unbind()
            isScrolling = false
            needsSnapshot = false
            hasDeliveredAnySnapshot = false
            hasPendingCatchUpCapture = false
        }

        /// Marks that a fresh snapshot is needed and ensures the display link will tick to service it.
        func requestSnapshot() {
            needsSnapshot = true
            refreshDisplayLinkPauseState()
        }

        /// Un-pauses the display link while scrolling is active or a snapshot is pending;
        /// pauses it otherwise so nothing renders when there's no work to do.
        private func refreshDisplayLinkPauseState() {
            displayLink.isPaused = !(isScrolling || needsSnapshot)
        }

        /// Clears the pending snapshot flag, performs the capture, then re-evaluates pause state.
        private func consumePendingSnapshot() {
            needsSnapshot = false
            captureSnapshot()
            refreshDisplayLinkPauseState()
        }

        /// Captures the current visual state of the hosted view hierarchy, processes it, and
        /// delivers results — all synchronously on the main actor.
        ///
        /// Processing used to hop to a `Task.detached` background task and back via
        /// `MainActor.run`; that round-trip added at least one extra main-thread run-loop turn
        /// between capture and delivery, which was measurably contributing to visible lag behind
        /// fast scrolling. Kept synchronous and on the main actor until processing is either
        /// cheap enough to stay inline or a lower-latency handoff is found.
        ///
        /// Skips capturing entirely while no `.blurred()` target has registered a capture rect
        /// yet (nothing to crop against). Safe to skip outright — unlike the `PreferenceKey`-
        /// based path this replaced, `BlurSnapshotStore.targetFrames` is written directly by
        /// `BlurTargetViewModifier` and resolves reliably without needing a render to unstick
        /// it. Once something has been delivered, also freezes during any active transition —
        /// push or pop, detected via `hostingController?.transitionCoordinator` — rather than
        /// repeatedly re-capturing a target whose frame is changing as the screen slides in or
        /// out; a catch-up capture happens automatically once the transition ends and a
        /// subsequent tick arrives.
        private func captureSnapshot() {
            guard let view = hostingController?.view, view.bounds != .zero else { return }
            guard let captureRect = store?.captureRect, captureRect != .zero else { return }

            let isTransitioning = hostingController?.transitionCoordinator != nil
            if hasDeliveredAnySnapshot, isTransitioning {
                hasPendingCatchUpCapture = true
                return
            }

            if let offset = scrollTracker.debugPrimaryContentOffset {
                blurSignpostEvent("captureStart", offset: offset)
            }
            blurSignpostBegin("wholeCapture")
            blurSignpostBegin("render")
            let bounds: CGRect
            if view.window == nil {
                bounds = view.bounds
            } else {
                let sourceWindowOrigin = view.convert(CGPoint.zero, to: nil)
                bounds = captureRect.offsetBy(dx: -sourceWindowOrigin.x, dy: -sourceWindowOrigin.y)
            }
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: bounds.size))
            let snapshot = renderer.image { context in
                context.cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
                switch navigationBarOverlap {
                case .none:
                    view.layer.render(in: context.cgContext)
                case .possible:
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                }
            }
            blurSignpostEnd("render")

            blurSignpostBegin("process")
            let result = processor.process(snapshot: snapshot, configurations: configurations)
            blurSignpostEnd("process")

            blurSignpostBegin("deliver")
            onProcessedSnapshot?(result)
            blurSignpostEnd("deliver")
            blurSignpostEnd("wholeCapture")
            hasDeliveredAnySnapshot = true
            hasPendingCatchUpCapture = false
        }
    }

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
            context.coordinator.start()
            // Guarantees a tick right at (or just after) the point `transitionCoordinator` is
            // expected to clear, so a catch-up capture owed from freezing during the transition
            // isn't left stranded if onLayout's own cadence has already tapered off by then.
            context.coordinator.requestSnapshot()
        }
        controller.onDisappear = {
            context.coordinator.stop()
        }
        controller.onLayout = { [weak coordinator = context.coordinator] in
            guard let view = coordinator?.hostingController?.view else { return }
            // Starts the display link on first layout rather than waiting for viewDidAppear,
            // which is gated behind the entire NavigationStack push transition completing.
            // Idempotent — safe to call on every layout pass and again from onAppear.
            coordinator?.start()
            coordinator?.scrollTracker.bind(to: view)
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







