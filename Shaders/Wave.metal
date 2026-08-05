//
//  Wave.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from Wave.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//

#include <metal_stdlib>

using namespace metal;

/// Generates a uniform wave-distortion effect by offsetting the Y position of each pixel by
/// some amount of its X position.
///
/// Like `water` in `Water.metal`, this is a `.distortionEffect` shader: it returns a new
/// position for SwiftUI to sample from, rather than a sampled color.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - time: The number of elapsed seconds since the shader was created.
///   - speed: How fast to make the waves ripple. Try starting with a value of 5.
///   - smoothing: How much to smooth out the ripples, where greater values produce a smoother
///     effect. Try starting with a value of 20.
///   - strength: How pronounced to make the ripple effect. Try starting with a value of 5.
/// - Returns: The new position to sample from.
[[ stitchable ]] float2 wave(float2 position, float time, float speed, float smoothing, float strength) {
    position.y += sin(time * speed + position.x / smoothing) * strength;
    return position;
}
