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

/// Attempts to generate a random number based on various fixed input parameters.
///
/// Works using a simple (but brilliant!) and well-known trick: calculating the dot product of a
/// coordinate with a `float2` containing two numbers unlikely to repeat, then taking the sine of
/// that and multiplying it by a large number, yields what looks more or less like a random
/// number in the fraction digits — everything after the decimal place.
/// - Parameters:
///   - offset: A fixed value that controls pseudorandomness.
///   - position: The position of the pixel we're working with.
///   - time: The number of elapsed seconds since the shader was created.
/// - Returns: A pseudorandom value in 0...1.
float rainbowRandom(float offset, float2 position, float time) {
    // Pick two numbers that are unlikely to repeat.
    float2 nonRepeating = float2(12.9898 * time, 78.233 * time);

    // Multiply our texture coordinates by the
    // non-repeating numbers, then add them together.
    float sum = dot(position, nonRepeating);

    // calculate the sine of our sum to get a range
    // between -1 and 1.
    float sine = sin(sum);

    // Multiply the sine by a big, non-repeating number
    // so that even a small change will result in a big
    // color jump.
    float hugeNumber = sine * 43758.5453 * offset;

    // Send back just the numbers after the decimal point.
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
    // If it's not transparent…
    if (color.a > 0.0h) {
        // Make a color where the RGB values are the same
        // random number and A is 1; multiply by the
        // original alpha to get smooth edges.
        return half4(
            rainbowRandom(1.23, position, time),
            rainbowRandom(5.67, position, time),
            rainbowRandom(8.90, position, time),
            1.0h
        ) * color.a;
    } else {
        // Use the current (transparent) color.
        return color;
    }
}
