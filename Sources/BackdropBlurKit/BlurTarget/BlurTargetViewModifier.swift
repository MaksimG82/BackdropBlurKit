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

    /// The dictionary of blurred snapshots provided by the nearest ancestor `blurCoordinator`.
    @Environment(\.blurSourceSnapshot) private var snapshots

    /// The blur configuration inherited from the environment.
    @Environment(\.blurConfiguration) private var environmentConfiguration
    
    /// The size of the blur coordinator's coordinate space, used to scale global frames
    /// to match the snapshot's coordinate space.
    @Environment(\.blurSourceSize) private var sourceSize

    /// The effective blur configuration — explicit override takes priority over Environment.
    private var effectiveConfiguration: BlurConfiguration {
        configurationOverride ?? environmentConfiguration
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    backdropView(frame: frame)
                }
            )
    }

    /// Builds the blurred backdrop view cropped to the target's frame in global coordinates.
    /// - Parameter frame: The target view's frame in the global coordinate space.
    @ViewBuilder
    private func backdropView(frame: CGRect) -> some View {
        if let snapshot = snapshots[effectiveConfiguration] {
            let _ = print("frame: \(frame), snapshot: \(snapshot.size), sourceSize: \(sourceSize)")
            
            let scaleX = snapshot.size.width / sourceSize.width
            let scaleY = snapshot.size.height / sourceSize.height
            Image(uiImage: snapshot)
                .resizable()
                .frame(
                    width: snapshot.size.width,
                    height: snapshot.size.height
                )
                .offset(x: -frame.minX * scaleX, y: -frame.minY * scaleY)
                .frame(width: frame.width * scaleX, height: frame.height * scaleY, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
