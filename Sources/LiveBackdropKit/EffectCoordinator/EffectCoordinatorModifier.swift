//
//  EffectCoordinatorModifier.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A view modifier that collects processed snapshots from child `EffectSource` views
/// and distributes them to descendant `.effectTarget()` views via the environment.
struct EffectCoordinatorModifier: ViewModifier {
    /// The shared snapshot store owned by this coordinator and distributed to descendants via the environment.
    @State private var store = EffectSnapshotStore()

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.effectSourceSize, geometry.size)
                .environment(\.effectSnapshotStore, store)
        }
    }
}
