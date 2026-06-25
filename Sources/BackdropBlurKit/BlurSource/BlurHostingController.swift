//
//  BlurHostingController.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A `UIHostingController` subclass that exposes key lifecycle events
/// as closures for use by `BlurSource`.
public final class BlurHostingController<Content: View>: UIHostingController<Content> {

    /// Called when the controller's view has appeared on screen.
    var onAppear: (() -> Void)?

    /// Called when the controller's view has left the screen.
    var onDisappear: (() -> Void)?

    /// Called when the controller's view has completed a layout pass.
    var onLayout: (() -> Void)?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onAppear?()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onLayout?()
    }
}
