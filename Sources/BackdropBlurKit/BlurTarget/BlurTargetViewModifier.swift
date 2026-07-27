//
//  BlurTargetViewModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A view modifier that measures the view's geometry in the global coordinate space,
/// retrieves the corresponding blurred snapshot from the environment,
/// and renders the cropped backdrop behind the modified view.
struct BlurTargetViewModifier: ViewModifier {

    /// The custom corner radius to be applied to the blurred area.
    let cornerRadius: CGFloat

    /// An explicit blur configuration override. If `nil`, the Environment value is used.
    let configurationOverride: BlurConfiguration?

    /// The shared snapshot store from which the blurred backdrop image is retrieved.
    @Environment(\.blurSnapshotStore) private var store

    /// The blur configuration inherited from the environment.
    @Environment(\.blurConfiguration) private var environmentConfiguration

    /// The size of the blur coordinator's coordinate space, used to scale global frames
    /// to match the snapshot's coordinate space.
    @Environment(\.blurSourceSize) private var sourceSize

    /// A stable identity for this target, used to key its frame in
    /// `BlurSnapshotStore.targetFrames`. Generated once and held for the view's lifetime.
    @State private var targetID = UUID()

    private var snapshots: [BlurConfiguration: UIImage] {
        store?.snapshots ?? [:]
    }

    /// The effective blur configuration — explicit override takes priority over Environment.
    private var effectiveConfiguration: BlurConfiguration {
        configurationOverride ?? environmentConfiguration
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    // The frame-reporting hooks below (.onAppear/.onChange/.onDisappear) are
                    // attached to this ZStack rather than directly to `backdropView(frame:)`.
                    // `backdropView` is conditionally empty (it renders nothing until a
                    // snapshot exists), and modifiers attached to a conditionally-empty
                    // `@ViewBuilder` result don't reliably fire on a single render pass — a
                    // pushed NavigationStack destination gets away with it because its
                    // transition drives several render passes, but a screen mounted directly
                    // as the app's root gets exactly one, and the hooks never fire, so
                    // `targetFrames` never gets populated and nothing ever bootstraps
                    // (confirmed via the [LOGGING] traces below). `Color.clear` guarantees the
                    // ZStack always has real, unconditional content, so it — and the hooks
                    // attached to it — reliably appear regardless of `backdropView`'s state.
                    ZStack {
                        Color.clear
                        backdropView(frame: frame)
                    }
                        .allowsHitTesting(false)
                        .onAppear {
                            print("[LOGGING] target reports frame (onAppear) \(frame), \(CACurrentMediaTime())")
                            store?.targetFrames[targetID] = frame
                        }
                        .onChange(of: frame) { _, newFrame in
                            print("[LOGGING] target reports frame (onChange) \(newFrame), \(CACurrentMediaTime())")
                            store?.targetFrames[targetID] = newFrame
                        }
                        .onDisappear {
                            print("[LOGGING] target removes frame (onDisappear), \(CACurrentMediaTime())")
                            store?.targetFrames.removeValue(forKey: targetID)
                        }
                }
            )
    }

    /// Builds the blurred backdrop view cropped to the target's frame in global coordinates.
    /// - Parameter frame: The target view's frame in the global coordinate space.
    @ViewBuilder
    private func backdropView(frame: CGRect) -> some View {
        if let snapshot = snapshots[effectiveConfiguration],
           let captureRect = store?.captureRect {
            let _ = print("[LOGGING] target receives ready snapshot, \(CACurrentMediaTime())")
            Image(uiImage: snapshot)
                .resizable()
                .frame(width: snapshot.size.width, height: snapshot.size.height)
                .offset(
                    x: -(frame.minX - captureRect.minX),
                    y: -(frame.minY - captureRect.minY)
                )
                .frame(width: frame.width, height: frame.height, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                // TEMP: lag investigation — remove after verification
                .onChange(of: ObjectIdentifier(snapshot)) {
                    blurSignpostEvent("targetSnapshotUpdated", time: CACurrentMediaTime())
                }
        }
    }
}
