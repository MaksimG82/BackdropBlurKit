//
//  Water.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from Water.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//

#include <metal_stdlib>

using namespace metal;

/// Generates a rippling water-distortion effect by pushing pixels around based on sine and
/// cosine wave offsets.
///
/// Unlike the `.layerEffect` shaders in this package, this is a `.distortionEffect` shader: it
/// has no access to `SwiftUI::Layer` and returns a new position for SwiftUI to sample from,
/// rather than a sampled color.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - size: The size of the whole image, in user space.
///   - time: The number of elapsed seconds since the shader was created.
///   - speed: How fast to make the water ripple. Ranges from 0.5 to 10 work best; try starting
///     with 3.
///   - strength: How pronounced the rippling effect should be. Ranges from 1 to 5 work best; try
///     starting with 3.
///   - frequency: How often ripples should be created. Ranges from 5 to 25 work best; try
///     starting with 10.
/// - Returns: The new position to sample from.
[[ stitchable ]] float2 water(float2 position, float2 size, float time, float speed, float strength, float frequency) {
    // 0..1 UV in float (avoid half precision for time-driven math)
    float2 uv = position / size;

    // Use float, not half, and avoid the `h` suffixes
    float adjustedSpeed    = time * speed * 0.05f;
    float adjustedStrength = strength / 100.0f;

    // Wrap the phase so sin/cos never see huge arguments
    const float TWO_PI = 6.28318530718f;
    float phase = fmod(adjustedSpeed * frequency, TWO_PI);

    // Use the wrapped phase; fast:: trig is fine for this effect
    float argX = frequency * uv.x + phase;
    float argY = frequency * uv.y + phase;
    uv.x += fast::sin(argX) * adjustedStrength;
    uv.y += fast::cos(argY) * adjustedStrength;

    return uv * size;
}
