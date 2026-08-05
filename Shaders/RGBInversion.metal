//
//  RGBInversion.metal
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// RGB color-inversion shader for the `.layerEffect` pipeline (`Effect.invert`).
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
