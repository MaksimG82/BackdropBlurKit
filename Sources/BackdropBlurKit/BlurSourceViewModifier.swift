//
//  BlurSourceViewModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A view modifier that captures the source view, tracks blur regions, and synchronizes snapshots.
struct BlurSourceViewModifier: ViewModifier {
    
    /// The live reference to the underlying UIKit container view.
    @State private var capturedView: UIView? = nil
    
    /// The latest generated pixel snapshot of the source background view hierarchy.
    @State private var currentSnapshot: UIImage? = nil
    
    /// The persistent lifecycle coordinator managing the display link timer.
    @State private var coordinator = DisplayLinkCoordinator()
    
    /// The collected blur regions in global coordinate space.
    @State private var globalRegions: [ViewBlurRegion] = []
    
    /// The calculated blur regions mapped into the container's local coordinate space.
    @State private var localRegions: [ViewBlurRegion] = []
    
    func body(content: Content) -> some View {
        content
            .background(
                BlurSourceTrackerView(
                    onViewCaptured: { uiView in
                        DispatchQueue.main.async {
                            self.capturedView = uiView
                            generateSnapshot()
                            updateLocalCoordinates()
                        }
                    },
                    onScrollingChanged: { isScrolling in
                        coordinator.isPaused = !isScrolling
                    }
                )
            )
            .onAppear {
                warmUp()
                coordinator.onFrameUpdate = {
                    generateSnapshot()
                    updateLocalCoordinates()
                }
                coordinator.start()
            }
            .onPreferenceChange(BlurRegionsPreferenceKey.self) { preferences in
                globalRegions = preferences
                updateLocalCoordinates()
            }
            .overlay(
                ZStack {
                    ForEach(localRegions, id: \.self) { region in
                        RoundedRectangle(cornerRadius: region.cornerRadius)
                            .stroke(Color.green, lineWidth: 3)
                            .background(Color.green.opacity(0.2))
                            .frame(width: region.frame.width, height: region.frame.height)
                            .position(x: region.frame.midX, y: region.frame.midY)
                    }
                }
                    .allowsHitTesting(false)
            )
            .onDisappear {
                coordinator.stop()
            }
    }
    
    private func warmUp() {
            guard let view = capturedView, view.bounds.width > 0 else { return }
            let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
            _ = renderer.image { context in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            }
        }
    
    /// Translates captured global frames into the container's local coordinate space
    private func updateLocalCoordinates() {
        guard let container = capturedView else {
            return
        }
        localRegions = globalRegions.map { region in
            let localFrame = container.convert(region.frame, from: nil)
            return ViewBlurRegion(frame: localFrame, cornerRadius: region.cornerRadius)
        }
    }
    /// Captures the current state of the native view hierarchy using modern image renderer.
    private func generateSnapshot() {
        guard let view = capturedView, view.bounds.width > 0, view.bounds.height > 0 else { return }
        let bounds = view.bounds
        
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }}
