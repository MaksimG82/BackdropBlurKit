//
//  GaussianBlur.metal
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// A single-pass, 9-tap (3x3 grid) weighted approximation of a Gaussian blur, for the
/// `.layerEffect` GPU pipeline.
///
/// This is NOT a true separable Gaussian blur like the CPU pipeline's
/// `EffectConfiguration.gaussian` (which runs Core Image's `CIGaussianBlur`, a proper
/// large-kernel convolution across many samples over multiple internal passes). A
/// `[[stitchable]]` layer-effect shader has no access to CIFilter or an intermediate render
/// target chain — only `layer.sample(...)` at arbitrary offsets from the current fragment
/// within `maxSampleOffset` — so a real, wide Gaussian kernel isn't practical here. Instead,
/// this adapts the well-known 3x3 binomial/Gaussian approximation used throughout real-time
/// blur shaders (weights `1 2 1 / 2 4 2 / 1 2 1`, normalized by 16 — the discretized 2D
/// Gaussian for a 3-tap-per-axis kernel), and fakes a larger visual radius by scaling the
/// *spacing* between those 9 fixed taps by `radius`, rather than adding more taps.
///
/// The tradeoff: sample count stays fixed at 9 regardless of `radius`, so larger radii
/// increasingly under-sample the true Gaussian curve — visible as banding/ringing and a
/// blockier, less smooth falloff than `CIGaussianBlur` produces, especially past moderate
/// radii (roughly >12-16pt). It's cheap (9 texture samples, one pass, no intermediate render
/// targets), which is exactly what makes it viable as a real-time per-frame layer effect at
/// all — a proper multi-tap or separable two-pass Gaussian would need far more samples than
/// is practical for this shader model.
///
/// - Parameters:
///   - position: The user-space position of the fragment being shaded.
///   - layer: The layer being sampled, providing access to the rendered content this shader
///     is attached to.
///   - radius: The blur radius, in points. Adjacent taps sit `radius` points apart on each
///     axis, so the corner taps land at exactly `(±radius, ±radius)` — matching
///     `maxSampleOffset` (see `gaussianBlurLayerEffect(radius:)`), so no sample ever exceeds
///     the declared bound.
/// - Returns: The weighted 9-tap average color centered on `position`.
[[ stitchable ]] half4 gaussianBlur(float2 position, SwiftUI::Layer layer, float radius) {
    float step = radius;

    half4 sum = half4(0.0h);

    // 3x3 binomial/Gaussian weights, normalized by 16: corners 1, edges 2, center 4.
    sum += layer.sample(position + float2(-step, -step)) * 0.0625h;
    sum += layer.sample(position + float2( 0.0,  -step)) * 0.125h;
    sum += layer.sample(position + float2( step, -step)) * 0.0625h;

    sum += layer.sample(position + float2(-step, 0.0)) * 0.125h;
    sum += layer.sample(position + float2( 0.0,  0.0)) * 0.25h;
    sum += layer.sample(position + float2( step, 0.0)) * 0.125h;

    sum += layer.sample(position + float2(-step, step)) * 0.0625h;
    sum += layer.sample(position + float2( 0.0,  step)) * 0.125h;
    sum += layer.sample(position + float2( step, step)) * 0.0625h;

    return sum;
}
