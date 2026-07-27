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

        /// Observer for `UIApplication.didBecomeActiveNotification`, removed in `deinit`.
        /// Forces a fresh capture on foreground return in case the underlying content changed
        /// while backgrounded (e.g. a push notification updated data driving the captured
        /// content) — a case with no scroll or layout event to naturally trigger a re-capture.
        /// No corresponding background-pause handling is needed: `CADisplayLink` already stops
        /// firing automatically while the app isn't in the foreground.
        ///
        /// `nonisolated(unsafe)`: only ever written in `init` and read in `deinit`, which is
        /// always non-isolated even for an `@MainActor` class — these two accesses can't
        /// overlap for a given instance, so the actor-isolation check here is overly
        /// conservative rather than protecting against a real race.
        nonisolated(unsafe) private var didBecomeActiveObserver: NSObjectProtocol?

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
            didBecomeActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    logEvent("coordinator: app didBecomeActive")
                    self?.requestSnapshot()
                }
            }
        }

        deinit {
            if let didBecomeActiveObserver {
                NotificationCenter.default.removeObserver(didBecomeActiveObserver)
            }
        }

        /// Starts the display link.
        ///
        /// One-time engine startup, paired with `stop()` — but safe to call repeatedly (e.g.
        /// from every `onLayout` pass): `DisplayLinkCoordinator.start()` guards internally and
        /// no-ops after the first call. Does **not** refresh the display link's pause state —
        /// callers must follow this with `requestSnapshot()` (which does) or call
        /// `refreshDisplayLinkPauseState()` themselves, otherwise the display link stays paused
        /// with no snapshot ever captured.
        func start() {
            logEvent("coordinator.start()")
            displayLink.start()
        }

        /// Re-scans the hosted view hierarchy for scroll views and (re)attaches tracking to any
        /// newly discovered ones.
        ///
        /// Unlike `start()`, this isn't one-time setup: the scrollable hierarchy can change as
        /// content is added or removed, so this needs to re-run on every layout pass.
        /// `ScrollTracker` throttles the actual hierarchy walk internally, so calling this often
        /// is cheap.
        /// - Parameter view: The root of the view hierarchy to scan.
        func bindScrollTracking(to view: UIView) {
            scrollTracker.bind(to: view)
        }

        /// Stops the display link and releases all scroll view observers.
        func stop() {
            logEvent("coordinator.stop()")
            displayLink.stop()
            scrollTracker.unbind()
            isScrolling = false
            needsSnapshot = false
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

            if let offset = scrollTracker.debugPrimaryContentOffset {
                blurSignpostEvent("captureStart", offset: offset)
            }
            blurSignpostBegin("wholeCapture")

            blurSignpostBegin("render")
            let bounds = captureBounds(for: view, captureRect: captureRect)
            let snapshot = renderSnapshot(view: view, bounds: bounds)
            blurSignpostEnd("render")

            blurSignpostBegin("process")
            let result = processor.process(snapshot: snapshot, configurations: configurations)
            blurSignpostEnd("process")

            blurSignpostBegin("deliver")
            onProcessedSnapshot?(result)
            blurSignpostEnd("deliver")
            blurSignpostEnd("wholeCapture")
            logEvent("captureSnapshot() exit — delivered snapshot")
        }

        /// Computes the crop rect to render, in the hosted view's own coordinate space.
        ///
        /// While the view has no window yet (nothing to convert its origin against), falls
        /// back to the view's full bounds.
        /// - Parameters:
        ///   - view: The hosted view being captured.
        ///   - captureRect: The union of all registered `.blurred()` target frames, in window
        ///     coordinates.
        /// - Returns: The crop rect to render, in `view`'s own coordinate space.
        private func captureBounds(for view: UIView, captureRect: CGRect) -> CGRect {
            guard view.window != nil else {
                return view.bounds
            }
            let sourceWindowOrigin = view.convert(CGPoint.zero, to: nil)
            return captureRect.offsetBy(dx: -sourceWindowOrigin.x, dy: -sourceWindowOrigin.y)
        }

        /// Renders `view`'s current visual state into a bitmap cropped to `bounds`, using
        /// whichever render path `navigationBarOverlap` selects.
        /// - Parameters:
        ///   - view: The hosted view to render.
        ///   - bounds: The crop rect to render, in `view`'s own coordinate space.
        /// - Returns: The rendered, unblurred snapshot.
        private func renderSnapshot(view: UIView, bounds: CGRect) -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: bounds.size))
            return renderer.image { context in
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
        }
    }
}
