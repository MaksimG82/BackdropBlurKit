//
//  ScrollTracker.swift
//  BackdropBlurKit
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

    /// The collection of scroll views currently being monitored.
    private var trackedScrollViews: [UIScrollView] = []

    /// KVO observers for each tracked scroll view.
    private var observers: [NSKeyValueObservation] = []

    /// Pending work items used to detect scroll stop per scroll view.
    private var stopWorkItems: [UIScrollView: DispatchWorkItem] = [:]

    /// Recursively searches `rootView` for all `UIScrollView` instances and attaches KVO.
    /// - Parameter rootView: The root of the view hierarchy to scan.
    func bind(to rootView: UIView) {
        findScrollViews(in: rootView)
    }

    /// Removes all KVO observers and clears internal state.
    func unbind() {
        stopWorkItems.values.forEach { $0.cancel() }
        stopWorkItems.removeAll()
        observers.removeAll()
        trackedScrollViews.removeAll()
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
