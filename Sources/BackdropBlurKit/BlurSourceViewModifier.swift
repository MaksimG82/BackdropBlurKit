//
//  BlurSourceViewModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A view modifier that captures the source view and synchronizes snapshot generation with layout and screen refresh updates.
struct BlurSourceViewModifier: ViewModifier {
    /// The live reference to the underlying UIKit container view.
    @State private var capturedView: UIView? = nil
    
    /// The latest generated pixel snapshot of the source background view hierarchy.
    @State private var currentSnapshot: UIImage? = nil
    
    /// The persistent lifecycle coordinator managing the display link timer.
    @State private var coordinator = DisplayLinkCoordinator()
    
    func body(content: Content) -> some View {
        content
            .background(
                BlurSourceTrackerView(
                    onViewCaptured: { uiView in
                        self.capturedView = uiView
                        generateSnapshot()
                    },
                    onScrollingChanged: { isScrolling in
                        coordinator.isPaused = !isScrolling
                    }
                )
            )
            .onAppear {
                coordinator.onFrameUpdate = {
                    generateSnapshot()
                }
                coordinator.start()
            }
            .onDisappear {
                coordinator.stop()
            }
    }
    
    /// Captures the current state of the native view hierarchy using modern image renderer.
    private func generateSnapshot() {
        guard let view = capturedView, view.bounds.width > 0, view.bounds.height > 0 else { return }
        
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
        
        self.currentSnapshot = image
        print("📸 snapShot: \(image.size.width)x\(image.size.height)")
    }
}

