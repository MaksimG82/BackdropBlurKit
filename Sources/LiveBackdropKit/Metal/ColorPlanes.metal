//
//  ColorPlanes.metal
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from ColorPlanes.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Separates the RGB values for a pixel and offsets them to create a glitch-style effect.
///
/// Reads the red and blue channels from different pixels than the original, offset by `offset`
/// and a fixed multiplier: red is read from `position - offset * 2`, blue from
/// `position - offset`, and green/alpha from `position` itself.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - layer: The SwiftUI layer being sampled.
///   - offset: How much to offset the red and blue channels by.
/// - Returns: The new pixel color.
[[ stitchable ]] half4 colorPlanes(float2 position, SwiftUI::Layer layer, float2 offset) {
    float2 red = position - (offset * 2.0);
    float2 blue = position - offset;

    half4 color = layer.sample(position);
    color.r = layer.sample(red).r;
    color.b = layer.sample(blue).b;

    return color * color.a;
}
