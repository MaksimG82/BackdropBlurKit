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

    func body(content: Content) -> some View {
        // TEMP: captureRect wiring investigation — remove after verification
        let _ = print("TEMP captureRect wiring: t=\(CACurrentMediaTime()) BlurCoordinatorModifier.body evaluated")
        return GeometryReader { geometry in
            // TEMP: captureRect wiring investigation — remove after verification
            let _ = print("TEMP captureRect wiring: t=\(CACurrentMediaTime()) " +
                          "coordinator GeometryReader closure evaluated, size=\(geometry.size)")
            content
                .environment(\.blurSourceSize, geometry.size)
                .environment(\.blurSnapshotStore, store)
                .onPreferenceChange(BlurTargetFramesPreferenceKey.self) { frames in
                    let resolved = union(of: frames)
                    // TEMP: captureRect wiring investigation — remove after verification
                    print("TEMP captureRect wiring: t=\(CACurrentMediaTime()) onPreferenceChange " +
                          "frames=\(frames) union=\(resolved)")
                    store.captureRect = resolved
                }
        }
    }

    /// Computes the minimal CGRect enclosing all target frames, in the shared global/window space.
    /// - Parameter frames: Global-space frames from all `.blurred()` targets.
    /// - Returns: A CGRect in global space, or `.zero` if frames is empty.
    ///
    /// This is left in global space rather than made relative to the coordinator's own origin —
    /// `BlurSource` reconciles it against its own window origin, since that's the only origin
    /// that matters for cropping its rendered layer (see `BlurSource.Coordinator.captureSnapshot()`).
    private func union(of frames: [CGRect]) -> CGRect {
        guard let first = frames.first else { return .zero }
        return frames.dropFirst().reduce(first) { $0.union($1) }
    }
}
