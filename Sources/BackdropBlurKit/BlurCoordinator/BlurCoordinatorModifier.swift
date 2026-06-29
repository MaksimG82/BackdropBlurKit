//
//  BlurCoordinatorModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A view modifier that collects processed snapshots from child `BlurSource` views
/// and distributes them to descendant `.blurred()` views via the environment.
struct BlurCoordinatorModifier: ViewModifier {
    /// The shared snapshot store owned by this coordinator and distributed to descendants via the environment.
    @State private var store = BlurSnapshotStore()

    /// The coordinator's origin in the global coordinate space, used to translate target frames to local coordinates.
    @State private var coordinatorOrigin: CGPoint = .zero

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.blurSourceSize, geometry.size)
                .environment(\.blurSnapshotStore, store)
                .onPreferenceChange(BlurTargetFramesPreferenceKey.self) { frames in
                    let origin = geometry.frame(in: .global).origin
                    store.captureRect = union(of: frames, relativeTo: origin)
                }
        }
        .ignoresSafeArea()
    }

    /// Computes the minimal CGRect enclosing all target frames, translated to local coordinates.
    /// - Parameters:
    ///   - frames: Global-space frames from all `.blurred()` targets.
    ///   - origin: The coordinator's origin in global space.
    /// - Returns: A CGRect in local coordinates, or `.zero` if frames is empty.
    private func union(of frames: [CGRect], relativeTo origin: CGPoint) -> CGRect {
        guard let first = frames.first else { return .zero }
        let globalUnion = frames.dropFirst().reduce(first) { $0.union($1) }
        return globalUnion.offsetBy(dx: -origin.x, dy: -origin.y)
    }
}
