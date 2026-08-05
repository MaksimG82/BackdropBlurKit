//
//  EffectHostingController.swift
//  Undertow
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A `UIHostingController` subclass that exposes key lifecycle events
/// as closures for use by `EffectSource`.
public final class EffectHostingController<Content: View>: UIHostingController<Content> {

    /// Called when the controller's view has appeared on screen.
    var onAppear: (() -> Void)?

    /// Called when the controller's view has left the screen.
    var onDisappear: (() -> Void)?

    /// Called when the controller's view has completed a layout pass.
    var onLayout: (() -> Void)?

    /// Called when the interface style or preferred content size category changes (e.g. dark
    /// mode toggled, or Dynamic Type adjusted) — appearance changes that can make an existing
    /// snapshot stale without triggering a layout pass or scroll event.
    var onTraitChange: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Scoped precisely to the two traits that can make a snapshot visually stale, rather
        // than the legacy `traitCollectionDidChange` override, which fires for every trait
        // change (including ones irrelevant here, like size class).
        registerForTraitChanges(
            [UITraitUserInterfaceStyle.self, UITraitPreferredContentSizeCategory.self]
        ) { (controller: EffectHostingController<Content>, _: UITraitCollection) in
            controller.onTraitChange?()
        }
    }

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
