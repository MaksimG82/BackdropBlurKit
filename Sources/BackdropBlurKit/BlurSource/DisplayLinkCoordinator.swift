//
//  DisplayLinkCoordinator.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A coordinator that manages a `CADisplayLink` with pause/resume capabilities.
@Observable
final class DisplayLinkCoordinator {
    
    /// A lightweight proxy that breaks the retain cycle between `CADisplayLink` and the coordinator.
    private final class TargetProxy: NSObject {
        /// A weak reference to the parent coordinator.
        private weak var coordinator: DisplayLinkCoordinator?
        /// Counter to track frames for throttling.
        private var frameCounter = 0
        /// Determines the update frequency; 3 means every 3rd frame.
        private let throttleRate = 1
        
        /// Initializes the proxy with a reference to the coordinator.
        /// - Parameter coordinator: The coordinator to forward updates to.
        init(coordinator: DisplayLinkCoordinator) {
            self.coordinator = coordinator
        }

        /// The Objective-C compatible target method triggered by the display link.
        @objc func update() {
            frameCounter += 1
            if frameCounter % throttleRate == 0 {
                coordinator?.onFrameUpdate?()
            }
        }
    }
    
    /// The active display link instance.
    private var displayLink: CADisplayLink?
    
    /// The closure to execute on every screen refresh cycle.
    var onFrameUpdate: (() -> Void)?
    
    /// Toggles the operational state of the display link to save processor cycles.
    var isPaused: Bool {
        get { displayLink?.isPaused ?? true }
        set { displayLink?.isPaused = newValue }
    }
    
    /// Starts the display link and attaches it to the main run loop in a paused state.
    func start() {
        guard displayLink == nil else { return }
        
        let link = CADisplayLink(target: TargetProxy(coordinator: self), selector: #selector(TargetProxy.update))
        link.add(to: .main, forMode: .common)
        link.isPaused = true
        displayLink = link
    }
    
    /// Invalidates and releases the display link instance.
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
