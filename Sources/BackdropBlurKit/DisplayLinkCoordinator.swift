//
//  DisplayLinkCoordinator.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A coordinator that manages a `CADisplayLink` with pause/resume capabilities.
final class DisplayLinkCoordinator: NSObject {
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
        let link = CADisplayLink(target: self, selector: #selector(handleFrame))
        link.add(to: .main, forMode: .common)
        link.isPaused = true
        displayLink = link
    }
    
    /// Invalidates and releases the display link instance.
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Objective-C selector triggered by the system display link refresh.
    @objc private func handleFrame() {
        onFrameUpdate?()
    }
}
