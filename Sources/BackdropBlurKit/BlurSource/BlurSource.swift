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
        private func captureSnapshot() {
            guard let view = hostingController?.view, view.bounds != .zero else { return }
            // TEMP: lag investigation — remove after verification
            if let offset = scrollTracker.debugPrimaryContentOffset {
                blurSignpostEvent("captureStart", offset: offset)
            }
            blurSignpostBegin("wholeCapture")
            blurSignpostBegin("render")
            let captureRect = store?.captureRect ?? .zero
            let bounds: CGRect
            if captureRect == .zero || view.window == nil {
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
        }
        controller.onDisappear = {
            context.coordinator.stop()
        }
        controller.onLayout = { [weak coordinator = context.coordinator] in
            guard let view = coordinator?.hostingController?.view else { return }
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







