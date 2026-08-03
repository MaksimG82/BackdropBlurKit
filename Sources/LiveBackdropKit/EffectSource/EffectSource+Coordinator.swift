//
//  EffectSource+Coordinator.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

extension EffectSource {

    /// Manages snapshot capture, effect processing, scroll tracking,
    /// and display link lifecycle for an `EffectSource`.
    @MainActor
    public final class Coordinator: NSObject {

        /// The hosted view controller providing the isolated render surface.
        weak var hostingController: EffectHostingController<Content>?

        /// The shared snapshot store providing the current capture rect.
        weak var store: EffectSnapshotStore?

        /// The display link coordinator managing frame-throttled snapshot capture.
        let displayLink = DisplayLinkCoordinator()

        /// Tracks scroll views within the hosted hierarchy and controls display link pause state.
        let scrollTracker = ScrollTracker()

        /// The processor responsible for applying visual effects to raw snapshots.
        private let processor = EffectSnapshotProcessor()

        /// The set of effect configurations to apply to each captured snapshot.
        var configurations: Set<EffectConfiguration> = [.default]

        /// Called when processed snapshots are ready for delivery.
        var onProcessedSnapshot: (([EffectConfiguration: UIImage]) -> Void)?

        /// Whether the hosted view is actively scrolling, per `scrollTracker`.
        private var isScrolling = false

        /// Whether a snapshot capture has been requested and is awaiting the next display-link tick.
        private var needsSnapshot = false

        /// Guards against scheduling more than one pending asynchronous capture per run-loop
        /// turn (see `scheduleAsynchronousCapture()`). `onOffsetChanged` can fire faster than
        /// the display refresh rate during interactive, touch-driven dragging (contentOffset
        /// updates directly per touch delta, not paced by any display link), so without this a
        /// fast drag could queue up many redundant `DispatchQueue.main.async` captures.
        private var isCaptureScheduled = false

        /// Whether this capture region can ever overlap a translucent navigation bar. Defaults to
        /// `.possible` (the safe/correct path) until `makeUIViewController` sets the real value.
        var navigationBarOverlap: NavigationBarOverlap = .possible

        /// Which region to render when capturing a snapshot — cropped to the union of target
        /// frames, or the full source view. Set by `EffectSource` from its own `captureMode`.
        var captureMode: CaptureMode = .unionFrame

        /// What triggers a capture while scrolling. Defaults to `.tickSynchronized`, the
        /// original, regression-free behavior. See `CaptureTrigger`'s doc comment for the
        /// v0.0.1 status of this and `captureExecution` together — the other three
        /// combinations are implemented but not yet validated against real content.
        var captureTrigger: CaptureTrigger = .tickSynchronized

        /// How a triggered capture actually runs. Defaults to `.synchronous`. See
        /// `CaptureExecution`.
        var captureExecution: CaptureExecution = .synchronous

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
            // Only acts when captureTrigger == .onDemand — see CaptureTrigger's doc comment.
            scrollTracker.onOffsetChanged = { [weak self] in
                guard let self else { return }
                // TEMP: lag investigation — remove after verification
                self.store?.lastScrollOffsetChangeFrame = self.displayLink.frameIndex
                guard self.captureTrigger == .onDemand else { return }
                self.performCapture()
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

        /// Services a display-link tick.
        ///
        /// Always captures when `needsSnapshot` is set — triggers unrelated to scrolling
        /// (`onCaptureRectChanged`, app-foreground return via `requestSnapshot()`). Also
        /// captures on every tick while scrolling is active, but only when
        /// `captureTrigger == .tickSynchronized`; under `.onDemand`, scroll-driven captures
        /// are triggered directly from `scrollTracker.onOffsetChanged` instead (see `init`),
        /// and this tick is a no-op for them — capturing here too would race that trigger and
        /// could clobber it with a more-stale render.
        ///
        /// The display link still runs throughout scrolling regardless of `captureTrigger`
        /// (`isScrolling` keeps it unpaused) purely so `currentDisplayLinkFrame` keeps
        /// advancing for the TEMP lag diagnostics below.
        private func consumePendingSnapshot() {
            // TEMP: lag investigation — remove after verification
            store?.currentDisplayLinkFrame = displayLink.frameIndex
            let tickShouldCapture = needsSnapshot || (captureTrigger == .tickSynchronized && isScrolling)
            guard tickShouldCapture else { return }
            needsSnapshot = false
            performCapture()
            refreshDisplayLinkPauseState()
        }

        /// Runs a triggered capture per `captureExecution`.
        private func performCapture() {
            switch captureExecution {
            case .synchronous:
                captureSnapshot()
            case .asynchronous:
                scheduleAsynchronousCapture()
            }
        }

        /// Defers a capture via `DispatchQueue.main.async`, coalesced to at most one pending
        /// capture at a time.
        ///
        /// Matters most when paired with `captureTrigger == .onDemand`: `onOffsetChanged`
        /// fires synchronously, inline, inside whatever UIKit call actually mutated
        /// `contentOffset` — during interactive dragging, that's the pan gesture's own
        /// touch-handling code; during deceleration, UIScrollView's internal per-frame
        /// stepping. Capturing directly from there measurably blocked that call (several
        /// milliseconds of render + Core Image work inline), which delayed UIKit's own
        /// contentOffset commit for that frame and visibly degraded scroll smoothness.
        /// Dispatching here instead returns control to UIKit immediately, at the cost of the
        /// capture landing one run-loop turn later than the trigger.
        ///
        /// The `isCaptureScheduled` guard also caps capture frequency to roughly once per
        /// run-loop turn even though `contentOffset` can change faster than the display
        /// refresh rate during interactive dragging.
        private func scheduleAsynchronousCapture() {
            guard !isCaptureScheduled else { return }
            isCaptureScheduled = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isCaptureScheduled = false
                self.captureSnapshot()
            }
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
        /// Skips capturing entirely while no `.effectTarget()` target has registered a capture rect
        /// yet (nothing to crop against). Safe to skip outright — unlike the `PreferenceKey`-
        /// based path this replaced, `EffectSnapshotStore.targetFrames` is written directly by
        /// `EffectTargetViewModifier` and resolves reliably without needing a render to unstick
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
                effectSignpostEvent("captureStart", offset: offset)
            }
            effectSignpostBegin("wholeCapture")

            effectSignpostBegin("render")
            let bounds: CGRect
            switch captureMode {
            case .unionFrame:
                bounds = captureBounds(for: view, captureRect: captureRect)
            case .fullScreen:
                bounds = view.bounds
            }
            let snapshot = renderSnapshot(view: view, bounds: bounds)
            effectSignpostEnd("render")

            effectSignpostBegin("process")
            let result = processor.process(snapshot: snapshot, configurations: configurations)
            effectSignpostEnd("process")

            effectSignpostBegin("deliver")
            // Written right before delivery so `.effectTarget()` can offset against where this
            // snapshot's pixel (0, 0) actually landed, rather than assuming it's always
            // `captureRect.origin` — true under `.unionFrame` by construction, but not under
            // `.fullScreen`, where `bounds` is the source view's own local bounds instead.
            store?.capturedOrigin = view.window != nil ? view.convert(bounds.origin, to: nil) : bounds.origin
            // TEMP: lag investigation — remove after verification
            store?.capturedFrameIndex = displayLink.frameIndex
            onProcessedSnapshot?(result)
            effectSignpostEnd("deliver")
            effectSignpostEnd("wholeCapture")
            logEvent("captureSnapshot() exit — delivered snapshot")
        }

        /// Computes the crop rect to render, in the hosted view's own coordinate space.
        ///
        /// While the view has no window yet (nothing to convert its origin against), falls
        /// back to the view's full bounds.
        /// - Parameters:
        ///   - view: The hosted view being captured.
        ///   - captureRect: The union of all registered `.effectTarget()` target frames, in window
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
        /// - Returns: The rendered, unprocessed snapshot.
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
