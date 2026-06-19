//
//  UIScrollViewTrackerNativeView.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A native UIKit view that recursively detects all `UIScrollView` instances within a hierarchy and tracks their scrolling states.
final class UIScrollViewTrackerNativeView: UIView {
    /// A closure invoked when the view's target capture hierarchy is established.
    var onViewCaptured: ((UIView) -> Void)?
    
    /// A closure invoked when any tracked scroll view starts or stops scrolling activity.
    var onScrollingChanged: ((Bool) -> Void)?
    
    /// The collection of discovered scroll containers currently being monitored.
    private var trackedScrollViews: [UIScrollView] = []
    
    /// Storage for KVO observers to properly unbind when the view is deallocated.
    private var observers: [NSKeyValueObservation] = []
    
    /// Storage for debounced closure executions to detect when a specific scroll view stops moving.
    private var scrollStopWorkItems: [UIScrollView: DispatchWorkItem] = [:]

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        onViewCaptured?(superview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupScrollViewTracking()
    }

    /// Recursively traverses the view hierarchy downwards to find all `UIScrollView` instances.
    /// - Parameter view: The root view to begin the search from.
    private func findAllScrollViews(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            bindToScrollView(scrollView)
        }
        
        for subview in view.subviews {
            findAllScrollViews(in: subview)
        }
    }

    /// Attaches pan gesture recognizer targets and coordinate KVO observers to a specific scroll view.
    /// - Parameter scrollView: The target scroll container to monitor.
    private func bindToScrollView(_ scrollView: UIScrollView) {
        guard !trackedScrollViews.contains(scrollView) else { return }
        trackedScrollViews.append(scrollView)
        
        // Tracking contentOffset changes directly instead of unreliable deceleration flags
        let observer = scrollView.observe(\.contentOffset, options: .new) { [weak self] scroll, _ in
            MainActor.assumeIsolated {
                self?.trackOffsetChange(in: scroll)
            }
        }
        observers.append(observer)
    }

    /// Tracks real-time coordinate modifications and schedules a delayed check to confirm scrolling termination.
    /// - Parameter scrollView: The scroll view generating coordinate updates.
    private func trackOffsetChange(in scrollView: UIScrollView) {
        let wasScrolling = !scrollStopWorkItems.isEmpty
        
        scrollStopWorkItems[scrollView]?.cancel()
        
        let workItem = DispatchWorkItem { [weak self, weak scrollView] in
            guard let self = self, let scrollView = scrollView else { return }
            self.scrollStopWorkItems.removeValue(forKey: scrollView)
            self.evaluateScrollingState()
        }
        
        scrollStopWorkItems[scrollView] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        
        if !wasScrolling {
            onScrollingChanged?(true)
        }
    }

    /// Evaluates the active scrolling state based on gesture usage and pending deceleration work items.
    private func evaluateScrollingState() {
        let anyScrolling = !scrollStopWorkItems.isEmpty
        onScrollingChanged?(anyScrolling)
    }
    
    /// Traverses up to the highest available ancestor and searches downward for all `UIScrollView` instances.
    private func setupScrollViewTracking() {
        var topView: UIView = self
        while let nextSuperview = topView.superview {
            topView = nextSuperview
        }
        findAllScrollViews(in: topView)
    }
}
