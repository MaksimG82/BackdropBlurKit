//
//  RainbowNoise.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from RainbowNoise.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//

#include <metal_stdlib>

using namespace metal;

/// Generates a pseudorandom value by taking the fractional part of a large, sine-amplified dot
/// product — a small change in input causes a large, uncorrelated jump in output.
/// - Parameters:
///   - offset: A fixed value that controls pseudorandomness.
///   - position: The position of the pixel we're working with.
///   - time: The number of elapsed seconds since the shader was created.
/// - Returns: A pseudorandom value in 0...1.
float rainbowRandom(float offset, float2 position, float time) {
    float2 nonRepeating = float2(12.9898 * time, 78.233 * time);
    float sum = dot(position, nonRepeating);
    float sine = sin(sum);
    float hugeNumber = sine * 43758.5453 * offset;
    return fract(hugeNumber);
}

/// Generates dynamic, multi-colored noise.
///
/// This is a `.colorEffect` shader: it has no access to `SwiftUI::Layer` and simply transforms
/// the color already sampled by SwiftUI for the current pixel.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - color: The current color of the pixel.
///   - time: The number of elapsed seconds since the shader was created.
/// - Returns: The new pixel color.
[[ stitchable ]] half4 rainbowNoise(float2 position, half4 color, float time) {
    if (color.a > 0.0h) {
        // Multiply by alpha to keep edges smooth.
        return half4(
            rainbowRandom(1.23, position, time),
            rainbowRandom(5.67, position, time),
            rainbowRandom(8.90, position, time),
            1.0h
        ) * color.a;
    } else {
        return color;
    }
}
