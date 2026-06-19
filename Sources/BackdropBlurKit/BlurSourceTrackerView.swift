//
//  BlurSourceTrackerView.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// An invisible `UIViewRepresentable` component used to locate and capture the parent view within the SwiftUI hierarchy.
struct BlurSourceTrackerView: UIViewRepresentable {
    /// A closure executed when the parent `UIView` is successfully located.
    let onViewCaptured: (UIView) -> Void
    
    /// Callback notifying about scrolling state updates.
    var onScrollingChanged: (Bool) -> Void

    /// Creates a transparent, non-interactive `UIView` instance to be injected into the view hierarchy.
    /// - Parameter context: The system context for the view representable.
    /// - Returns: A clear, non-interactive `UIView` instance.
    func makeUIView(context: Context) -> UIView {
            let view = UIScrollViewTrackerNativeView()
            view.onViewCaptured = onViewCaptured
            view.onScrollingChanged = onScrollingChanged
            return view
        }

    /// A required system lifecycle method that delegates the search task to a helper function.
    /// - Parameters:
    ///   - uiView: The current embedded UIKit view instance.
    ///   - context: The system context for the view representable.
    func updateUIView(_ uiView: UIView, context: Context) {
        findAndCaptureParentView(for: uiView)
    }

    /// Searches for the parent view on the next RunLoop cycle and passes its reference to the capture closure.
    /// - Parameter uiView: The embedded UIKit view instance from which the upward hierarchy search begins.
    private func findAndCaptureParentView(for uiView: UIView) {
        DispatchQueue.main.async {
            if let superview = uiView.superview {
                onViewCaptured(superview)
            }
        }
    }
}
