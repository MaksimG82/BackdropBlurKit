//
//  ScrollTracker.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// Recursively tracks all `UIScrollView` instances in a view hierarchy
/// and reports scrolling state changes via KVO on `contentOffset`.
@MainActor
final class ScrollTracker {

    /// Called when the aggregated scrolling state across all tracked scroll views changes.
    var onScrollingChanged: ((Bool) -> Void)?

    // TEMP: lag investigation — remove after verification
    /// Called on every real `contentOffset` KVO firing — the "source content actually moved"
    /// signal, used to anchor frame-lag measurement in scenarios where the target itself is
    /// fixed (e.g. `SimpleScrollView`) and its own frame never changes.
    var onOffsetChanged: (() -> Void)?

    /// The collection of scroll views currently being monitored.
    private var trackedScrollViews: [UIScrollView] = []

    /// KVO observers for each tracked scroll view.
    private var observers: [NSKeyValueObservation] = []

    /// Pending work items used to detect scroll stop per scroll view.
    private var stopWorkItems: [UIScrollView: DispatchWorkItem] = [:]

    /// Whether a `bind(to:)` walk ran within the current throttle window.
    private var isBindThrottled = false

    /// The most recent view passed to `bind(to:)` while throttled, awaiting a trailing walk.
    private var pendingBindView: UIView?

    /// The minimum interval between consecutive hierarchy walks triggered by `bind(to:)`.
    private let bindThrottleInterval: TimeInterval = 0.25

    // TEMP: lag investigation — remove after verification
    /// The content offset of the first tracked scroll view, for signpost diagnostics only.
    var debugPrimaryContentOffset: CGPoint? {
        trackedScrollViews.first?.contentOffset
    }

    /// Recursively searches `rootView` for all `UIScrollView` instances and attaches KVO.
    ///
    /// Leading + trailing throttled: the first call in a window walks immediately, and at
    /// most one trailing walk runs after `bindThrottleInterval` if further calls arrive while
    /// throttled — bounding both the walk frequency and the staleness of newly discovered
    /// scroll views.
    /// - Parameter rootView: The root of the view hierarchy to scan.
    func bind(to rootView: UIView) {
        guard !isBindThrottled else {
            pendingBindView = rootView
            return
        }
        isBindThrottled = true
        findScrollViews(in: rootView)
        DispatchQueue.main.asyncAfter(deadline: .now() + bindThrottleInterval) { [weak self] in
            guard let self else { return }
            self.isBindThrottled = false
            if let pending = self.pendingBindView {
                self.pendingBindView = nil
                self.bind(to: pending)
            }
        }
    }

    /// Removes all KVO observers, clears internal state, and resets the bind throttle.
    func unbind() {
        stopWorkItems.values.forEach { $0.cancel() }
        stopWorkItems.removeAll()
        observers.removeAll()
        trackedScrollViews.removeAll()
        isBindThrottled = false
        pendingBindView = nil
    }

    /// Recursively traverses the hierarchy and binds each discovered `UIScrollView`.
    /// - Parameter view: The current node in the traversal.
    private func findScrollViews(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            bindScrollView(scrollView)
        }
        view.subviews.forEach { findScrollViews(in: $0) }
    }

    /// Attaches a `contentOffset` KVO observer to a single scroll view.
    /// - Parameter scrollView: The scroll view to monitor.
    private func bindScrollView(_ scrollView: UIScrollView) {
        guard !trackedScrollViews.contains(scrollView) else { return }
        trackedScrollViews.append(scrollView)

        let observer = scrollView.observe(\.contentOffset, options: .new) { [weak self] scroll, _ in
            MainActor.assumeIsolated {
                self?.handleOffsetChange(in: scroll)
            }
        }
        observers.append(observer)
    }

    /// Responds to a `contentOffset` change by resetting the stop timer for that scroll view.
    /// - Parameter scrollView: The scroll view that reported an offset change.
    private func handleOffsetChange(in scrollView: UIScrollView) {
        // TEMP: lag investigation — remove after verification
        effectSignpostEvent("scrollOffset", offset: scrollView.contentOffset)
        onOffsetChanged?()
        let wasScrolling = !stopWorkItems.isEmpty
        stopWorkItems[scrollView]?.cancel()

        let workItem = DispatchWorkItem { [weak self, weak scrollView] in
            guard let self, let scrollView else { return }
            self.stopWorkItems.removeValue(forKey: scrollView)
            self.onScrollingChanged(self.stopWorkItems.isEmpty ? false : true)
        }

        stopWorkItems[scrollView] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)

        if !wasScrolling {
            onScrollingChanged(true)
        }
    }

    /// Forwards the current scrolling state to the subscriber.
    private func onScrollingChanged(_ isScrolling: Bool) {
        onScrollingChanged?(isScrolling)
    }
}
