//
//  Emboss.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from Emboss.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Creates an embossing effect by adding brightness from the pixel diagonally up and to the
/// right, and subtracting brightness from the pixel diagonally down and to the left.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - layer: The SwiftUI layer being sampled.
///   - strength: How much of the offset pixels to add/subtract.
/// - Returns: The new pixel color.
[[ stitchable ]] half4 emboss(float2 position, SwiftUI::Layer layer, float strength) {
    half4 currentColor = layer.sample(position);
    half4 newColor = currentColor;

    newColor += layer.sample(position + 1.0) * strength;
    newColor -= layer.sample(position - 1.0) * strength;

    return half4(newColor) * currentColor.a;
}
