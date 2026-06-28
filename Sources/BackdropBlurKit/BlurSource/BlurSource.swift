//
//  BlurSource.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A SwiftUI representable that renders background content in an isolated `UIHostingController`,
/// enabling clean snapshots free of floating blur-target views.
public struct BlurSource<Content: View>: UIViewControllerRepresentable {

    /// Manages snapshot capture, blur processing, scroll tracking,
    /// and display link lifecycle for a `BlurSource`.
    @MainActor
    public final class Coordinator: NSObject {

        /// The hosted view controller providing the isolated render surface.
        weak var hostingController: BlurHostingController<Content>?

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

        override init() {
            super.init()
            displayLink.onFrameUpdate = { [weak self] in
                self?.captureSnapshot()
            }
            scrollTracker.onScrollingChanged = { [weak self] isScrolling in
                self?.displayLink.isPaused = !isScrolling
            }
        }

        /// Starts the display link and binds scroll tracking to the hosted view hierarchy.
        func start() {
            displayLink.start()
            if let view = hostingController?.view {
                scrollTracker.bind(to: view)
            }
        }

        /// Stops the display link and releases all scroll view observers.
        func stop() {
            displayLink.stop()
            scrollTracker.unbind()
        }

        /// Captures the current visual state of the hosted view hierarchy,
        /// processes it on a background thread, and delivers results on the main actor.
        func captureSnapshot() {
            guard
                let view = hostingController?.view,
                view.bounds != .zero
            else { return }
            let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
            let snapshot = renderer.image { context in
                view.layer.render(in: context.cgContext)
            }
            let configurations = self.configurations
            let result = processor.process(snapshot: snapshot, configurations: configurations)
            self.onProcessedSnapshot?(result)
        }
    }

    /// The background content to render and snapshot.
    let content: () -> Content

    /// Called when processed snapshots keyed by blur configuration are available.
    let onProcessedSnapshot: ([BlurConfiguration: UIImage]) -> Void

    /// Creates a `BlurSource` with the given background content and processed snapshot callback.
    /// - Parameters:
    ///   - content: The background content to render in isolation.
    ///   - onProcessedSnapshot: A closure invoked with processed snapshots keyed by configuration.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        onProcessedSnapshot: @escaping ([BlurConfiguration: UIImage]) -> Void
    ) {
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
            context.coordinator.captureSnapshot()
        }
        controller.onDisappear = {
            context.coordinator.stop()
        }
        controller.onLayout = { [weak coordinator = context.coordinator] in
            guard let view = coordinator?.hostingController?.view else { return }
            coordinator?.scrollTracker.bind(to: view)
        }
        context.coordinator.hostingController = controller
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
        return controller
    }

    public func updateUIViewController(_ uiViewController: BlurHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        context.coordinator.onProcessedSnapshot = onProcessedSnapshot
    }
}







