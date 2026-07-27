//
//  BlurSource+Coordinator.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

extension BlurSource {

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
        /// Paired with `isInsideActiveTransition` below — see its doc comment.
        private var hasDeliveredAnySnapshot = false

        /// Whether a `UINavigationController` push/pop transition is currently animating this
        /// screen in or out.
        ///
        /// Deferred/NavigationStack-2.0 scaffolding: for a plain screen (not pushed or popped),
        /// `transitionCoordinator` is always `nil`, so this is always `false` and the guard in
        /// `captureSnapshot()` that reads it never triggers. Kept in place — rather than
        /// removed — as the mechanism needed later to avoid repeatedly re-capturing a target
        /// whose frame is changing mid-transition; not currently exercised or maintained.
        /// Note for whoever picks this back up: `transitionCoordinator` was observed still
        /// non-nil at `viewDidAppear` in prior testing — it does not reliably clear exactly
        /// when that lifecycle method fires, so don't assume `viewDidAppear` implies this is
        /// `false`.
        private var isInsideActiveTransition: Bool {
            hostingController?.transitionCoordinator != nil
        }

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
            logEvent("coordinator.start()")
            displayLink.start()
            if let view = hostingController?.view {
                scrollTracker.bind(to: view)
            }
            refreshDisplayLinkPauseState()
        }

        /// Stops the display link and releases all scroll view observers.
        func stop() {
            logEvent("coordinator.stop()")
            displayLink.stop()
            scrollTracker.unbind()
            isScrolling = false
            needsSnapshot = false
            hasDeliveredAnySnapshot = false
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
        /// it.
        ///
        /// Also freezes once `isInsideActiveTransition` is true after an initial snapshot has
        /// been delivered — deferred/NavigationStack-2.0 scaffolding, see that property's doc
        /// comment. Always inert for a plain screen; when it does matter, catch-up happens
        /// naturally via the ordinary `onLayout` tick cadence once the transition ends, with no
        /// extra bookkeeping needed here.
        private func captureSnapshot() {
            logEvent("captureSnapshot() entry")
            guard let view = hostingController?.view, view.bounds != .zero else {
                logEvent("captureSnapshot() exit — view bounds zero")
                return
            }
            guard let captureRect = store?.captureRect, captureRect != .zero else {
                logEvent("captureSnapshot() exit — captureRect is zero")
                return
            }

            if hasDeliveredAnySnapshot, isInsideActiveTransition {
                logEvent("captureSnapshot() exit — frozen during active transition")
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
                // Deferred/NavigationStack-2.0: `navigationBarOverlap` picks between a fast
                // path that can render blank under a translucent nav bar (`.none`) and a
                // slower, always-correct path (`.possible`). Not actively exercised or
                // maintained for now — see `NavigationBarOverlap`'s doc comment.
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
            logEvent("captureSnapshot() exit — delivered snapshot")
        }
    }
}
