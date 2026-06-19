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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        onViewCaptured?(superview)
        
        // Starts the deep search for all scroll views inside the captured root view
        findAllScrollViews(in: superview)
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

    /// Attaches pan gesture recognizer targets and KVO observers to a specific scroll view.
    /// - Parameter scrollView: The target scroll container to monitor.
    private func bindToScrollView(_ scrollView: UIScrollView) {
        guard !trackedScrollViews.contains(scrollView) else { return }
        trackedScrollViews.append(scrollView)
        
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
        
        let observer = scrollView.observe(\.isDecelerating, options: .new) { [weak self] scroll, _ in
            MainActor.assumeIsolated {
                if !scroll.isDecelerating && !scroll.isDragging {
                    self?.evaluateScrollingState()
                }
            }
        }
        observers.append(observer)
    }

    /// Evaluates the scrolling state across all registered scroll containers to toggle the timer state.
    private func evaluateScrollingState() {
        let anyScrolling = trackedScrollViews.contains { scroll in
            scroll.isDragging || scroll.isDecelerating
        }
        onScrollingChanged?(anyScrolling)
    }

    /// Processes pan gesture state modifications to activate or pause the display link coordinator.
    /// - Parameter gesture: The pan gesture recognizer belonging to a tracked scroll view.
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            onScrollingChanged?(true)
        case .ended, .cancelled, .failed:
            evaluateScrollingState()
        default:
            break
        }
    }
}
