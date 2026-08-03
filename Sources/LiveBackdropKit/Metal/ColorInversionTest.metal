//
//  ColorInversionTest.metal
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Temporary validation shader for the `.layerEffect` GPU pipeline — NOT production API.
///
/// This exists only to confirm that a `[[stitchable]]` layer-effect shader can be authored,
/// compiled into this package's `.metallib` resource, loaded via `ShaderLibrary`, and applied
/// through `.layerEffect(...)` end to end. It inverts the sampled color as a trivially
/// visible, trivially correct effect. Remove once a real effect exercises the same plumbing.
///
/// - Parameters:
///   - position: The user-space position of the fragment being shaded.
///   - layer: The layer being sampled, providing access to the rendered content this shader
///     is attached to.
/// - Returns: The color at `position` with its RGB channels inverted; alpha is unchanged.
[[ stitchable ]] half4 invertColors(float2 position, SwiftUI::Layer layer) {
    half4 color = layer.sample(position);
    return half4(1.0h - color.rgb, color.a);
}
