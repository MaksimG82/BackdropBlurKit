//
//  ColorInversionTest.metal
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Color-inversion shader for the `.layerEffect` GPU pipeline (`Effect.invert`).
///
/// Originally written to confirm that a `[[stitchable]]` layer-effect shader can be authored,
/// compiled into this package's `.metallib` resource, loaded via `ShaderLibrary`, and applied
/// through `.layerEffect(...)` end to end — a trivially visible, trivially correct effect for
/// exactly that purpose. Kept on as a real, permanent effect alongside `GaussianBlur.metal`,
/// not just a smoke test.
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
