//
//  GaussianBlur.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from VariableGaussianBlur.metal in Inferno (https://github.com/twostraws/Inferno),
//  Copyright (c) Dale Price. Modified by Maksim Gaisin: dropped the mask-driven variable radius
//  (`mask`, `maskAlpha`, `pixelRadius = maskAlpha * radius`) — this variant applies `radius`
//  uniformly to every pixel instead of varying it per-pixel from a mask texture.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Gaussian function for a single axis, as described by
/// https://en.wikipedia.org/wiki/Gaussian_blur . Produces the "bell curve" weight for a sample
/// at `distance` from the origin.
/// - Parameters:
///   - distance: The distance from the origin along the current axis.
///   - sigma: The desired standard deviation of the bell curve.
inline half gaussian(half distance, half sigma) {
    const half gaussianExponent = -(distance * distance) / (2.0h * sigma * sigma);
    return (1.0h / (2.0h * M_PI_H * sigma * sigma)) * exp(gaussianExponent);
}

/// Weighted average of samples along one axis, centered on `position`.
/// - Parameters:
///   - position: The coordinates of the current pixel.
///   - boundingRect: The bounding rect of the view, in the same space as `position`.
///   - layer: The SwiftUI layer being sampled.
///   - normalizeEdges: If true, rejects samples that fall outside `boundingRect` instead of
///     letting the blur pick up content beyond the view's edge.
///   - radius: The blur radius, in points.
///   - axisMultiplier: `(1, 0)` to sample along X, or `(0, 1)` to sample along Y.
///   - maxSamples: The maximum number of samples to take in each direction from `position`.
///     Texture sampling is expensive, so instead of sampling every pixel, a lower count is
///     spread out across the radius.
half4 gaussianBlur1D(float2 position, float4 boundingRect, SwiftUI::Layer layer, bool normalizeEdges, half radius, half2 axisMultiplier, half maxSamples) {
    // Calculate how far apart the samples should be: either 1 pixel or the desired radius divided by the maximum number of samples, whichever is farther.
    const half interval = max(1.0h, radius / maxSamples);

    // Take the first sample, at the center, and start the weighted-average accumulators with it.
    const half weight = gaussian(0.0h, radius / 3.0h);
    half4 weightedColorSum = layer.sample(position) * weight;
    half totalWeight = weight;

    // If the radius is high enough to take more samples, take them.
    if (interval <= radius) {
        // Bounding box that all samples must be within when normalizing edges; otherwise unbounded.
        const float2 minSamplePos = normalizeEdges ? float2(boundingRect[0], boundingRect[1]) : float2(-HUGE_VALF);
        const float2 maxSamplePos = normalizeEdges ? float2(boundingRect[0] + boundingRect[2], boundingRect[1] + boundingRect[3]) : float2(HUGE_VALF);

        // Take a sample every `interval` up to and including the desired blur radius.
        for (half distance = interval; distance <= radius; distance += interval) {
            const half2 offsetDistance = axisMultiplier * distance;
            const half weight = gaussian(distance, radius / 3.0h);

            // Take two samples along the axis, one in each direction, and accumulate any that fall within the bounding box.
            const half2 positiveOffsetSamplePos = half2(position) + offsetDistance;
            const half2 negativeOffsetSamplePos = half2(position) - offsetDistance;
            if (!any(float2(positiveOffsetSamplePos) > maxSamplePos)) {
                weightedColorSum += layer.sample(float2(positiveOffsetSamplePos)) * weight;
                totalWeight += weight;
            }
            if (!any(float2(negativeOffsetSamplePos) < minSamplePos)) {
                weightedColorSum += layer.sample(float2(negativeOffsetSamplePos)) * weight;
                totalWeight += weight;
            }
        }
    }

    return weightedColorSum / totalWeight;
}

/// Single-axis pass of a two-pass separable Gaussian blur for the `.layerEffect` GPU pipeline.
///
/// Must be applied twice — once with `vertical == 0.0` (X axis) and once with `vertical != 0.0`
/// (Y axis) — see `gaussianBlurEffect(radius:boundingRect:normalizeEdges:)`, which
/// dispatches both passes since `.layerEffect` doesn't support multi-pass shaders in a single
/// call.
/// - Parameters:
///   - position: The user-space position of the fragment being shaded.
///   - layer: The layer being sampled.
///   - boundingRect: The bounding rectangle of the view in user space.
///   - radius: The blur radius, in points, applied uniformly to every pixel.
///   - maxSamples: The maximum number of samples to take in each direction from `position`.
///   - vertical: `0.0` blurs along X; any other value blurs along Y (SwiftUI shaders can't pass
///     booleans).
///   - normalizeEdges: `1.0` avoids sampling outside `boundingRect`; `0.0` allows it.
[[ stitchable ]] half4 gaussianBlur(float2 position, SwiftUI::Layer layer, float4 boundingRect, float radius, float maxSamples, float vertical, float normalizeEdges) {
    // Calculate the position in UV space within the bounding rect (0 to 1).
    const float2 uv = float2(position.x / boundingRect[2], position.y / boundingRect[3]);

    // If we are normalizing edges, return clear for any pixel outside of the bounding box.
    if (normalizeEdges == 1.0 && (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)) {
        return half4(0.0h);
    }

    // If the radius is less than 1 pixel, there's nothing to blur.
    if (radius < 1.0) {
        return layer.sample(position);
    }

    const half2 axisMultiplier = vertical == 0.0 ? half2(1, 0) : half2(0, 1);
    return gaussianBlur1D(position, boundingRect, layer, normalizeEdges == 1.0, half(radius), axisMultiplier, half(maxSamples));
}
