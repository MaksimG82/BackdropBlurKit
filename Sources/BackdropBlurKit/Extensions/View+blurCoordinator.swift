//
//  View+blurCoordinator.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

public extension View {
    /// Collects blur snapshots from child `BlurSource` views and distributes them
    /// to descendant `.blurred()` views via the environment.
    func blurCoordinator() -> some View {
        modifier(BlurCoordinatorModifier())
    }
}
