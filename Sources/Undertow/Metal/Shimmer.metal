//
//  Shimmer.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from Shimmer.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//
//  Functional change beyond a straight port: the original Inferno shader only sweeps
//  horizontally (built directly on uv.x, with uv.y only tilting the band). This version adds two
//  independent configurable parameters, both angles in the screen's rectangular coordinates:
//  `angle`, the orientation of the band itself (0 = vertical, measured from the y-axis); and
//  `direction`, the direction the gradient sweeps in (0 = rightward, matching the original,
//  measured like a standard math angle from the x-axis).
//
//  Both are computed in centered, aspect-corrected coordinates (the pixel's offset from the
//  view's center, in points) rather than raw uv — projecting onto a rotated axis in raw uv space
//  silently warps the angle on any non-square view, since uv.x and uv.y are scaled differently
//  relative to actual screen distance.
//
//  The band itself — the moving stripe of pixels that gets lightened — is defined purely in terms
//  of `angle`: a pixel is in the band when its position along the band's own normal axis (found
//  by rotating the centered coordinate by `angle`) falls within a window that slides over time.
//  `direction` doesn't define a second, independent axis to test against; it only controls how
//  fast that window slides along the band's normal, via the projection of `direction`'s own
//  normal onto the band's normal (`travelAlongBandNormal` below). When motion is perpendicular to
//  the band (the usual case, e.g. angle = direction = 0 sweeping a vertical band rightward), this
//  projection is 1 and the window advances at full speed. When motion runs along the band's own
//  length instead (angle = 0, direction = 90°, sweeping a vertical band's gradient upward along
//  itself), the projection is 0 and the band doesn't visibly move at all — a stripe sliding along
//  its own length is indistinguishable from a stationary one. This is why `direction` and `angle`
//  can't be treated as two independent thresholds to test against simultaneously: only one axis
//  (the band's normal) determines membership in the band; `direction` just reshapes how time maps
//  onto that one axis.
//
//  Note `angle` describes a line, not a ray: rotating it by 180° describes the same band, so it's
//  only meaningful modulo 180°. `direction` describes an actual movement vector and is meaningful
//  over the full 360°.
//

#include <metal_stdlib>

using namespace metal;

/// Converts a color from RGB to HSL representation.
/// Reference: https://en.wikipedia.org/wiki/HSL_and_HSV
/// - Parameter rgb: A vector representing a color with components (R, G, B).
/// - Returns: A vector representing a color with components (H, S, L).
half3 rgbToHSL(half3 rgb) {
    half min = min3(rgb.r, rgb.g, rgb.b);
    half max = max3(rgb.r, rgb.g, rgb.b);
    half delta = max - min;

    half3 hsl = half3(0.0h, 0.0h, 0.5h * (max + min));

    if (delta > 0.0h) {
        if (max == rgb.r) {
            hsl[0] = fmod((rgb.g - rgb.b) / delta, 6.0h);
        } else if (max == rgb.g) {
            hsl[0] = (rgb.b - rgb.r) / delta + 2.0h;
        } else {
            hsl[0] = (rgb.r - rgb.g) / delta + 4.0h;
        }
        hsl[0] /= 6.0h;
        if (hsl[2] > 0.0h && hsl[2] < 1.0h) {
            hsl[1] = delta / (1.0h - abs(2.0h * hsl[2] - 1.0h));
        } else {
            hsl[1] = 0.0h;
        }
    }

    return hsl;
}

/// Converts a color from HSL to RGB representation.
/// Reference: https://en.wikipedia.org/wiki/HSL_and_HSV
/// - Parameter hsl: A vector representing a color with components (H, S, L).
/// - Returns: A vector representing a color with components (R, G, B).
half3 hslToRGB(half3 hsl) {
    half c = (1.0h - abs(2.0h * hsl[2] - 1.0h)) * hsl[1];
    half h = hsl[0] * 6.0h;
    half x = c * (1.0h - abs(fmod(h, 2.0h) - 1.0h));

    half3 rgb = half3(0.0h, 0.0h, 0.0h);

    if (h < 1.0h) {
        rgb = half3(c, x, 0.0h);
    } else if (h < 2.0h) {
        rgb = half3(x, c, 0.0h);
    } else if (h < 3.0h) {
        rgb = half3(0.0h, c, x);
    } else if (h < 4.0h) {
        rgb = half3(0.0h, x, c);
    } else if (h < 5.0h) {
        rgb = half3(x, 0.0h, c);
    } else {
        rgb = half3(c, 0.0h, x);
    }

    half m = hsl[2] - 0.5h * c;
    return rgb + m;
}

/// Generates a shimmering effect by sweeping a gradient across the view at a configurable angle
/// and using it to modulate the lightness of each pixel.
///
/// This is a `.colorEffect` shader: it has no access to `SwiftUI::Layer` and simply transforms
/// the color already sampled by SwiftUI for the current pixel.
/// - Parameters:
///   - position: The user-space coordinate of the current pixel.
///   - color: The current color of the pixel.
///   - size: The size of the entire view, in user space.
///   - time: The number of elapsed seconds since the shader was created.
///   - animationDuration: The duration of a single loop of the shimmer animation, in seconds.
///   - gradientWidth: The width of the shimmer gradient in UV space.
///   - maxLightness: The maximum lightness at the peak of the gradient.
///   - direction: The direction the gradient sweeps in, in radians, measured from the x-axis
///     (0 = rightward). Meaningful over the full 0–2π range.
///   - angle: The orientation of the band itself, in radians, measured from the y-axis (0 =
///     vertical). Only meaningful modulo π, since a line looks the same rotated by π.
/// - Returns: The new pixel color.
[[ stitchable ]] half4 shimmer(float2 position, half4 color, float2 size, float time, float animationDuration, float gradientWidth, float maxLightness, float direction, float angle) {
    if (color.a == 0.0h) {
        return color;
    }

    // Calculate the current progress of the shimmer animation loop, from 0 to 1
    float loopedProgress = fmod(time, float(animationDuration));
    half progress = loopedProgress / animationDuration;

    // Center the coordinate on the view and express it in points (not uv), so angles below are
    // true geometric angles on screen rather than warped by a non-square aspect ratio. Also
    // normalize by the larger dimension so magnitudes stay in a consistent, size-independent
    // range regardless of the view's aspect ratio. This puts `centered` roughly in
    // [-0.5, 0.5] along the view's larger dimension.
    float maxDimension = max(size.x, size.y);
    half2 centered = half2((position - size / 2.0) / maxDimension);

    // The band is a stripe of pixels whose position along its own normal axis falls in a moving
    // window [start, end]. `bandNormal` is that axis: rotate `centered` by `angle` and take the
    // x-component. This is the standard 2D rotation formula x' = x·cos(θ) − y·sin(θ); `angle` is
    // measured from the y-axis (0 = vertical) rather than the x-axis, which is exactly what makes
    // this the perpendicular axis to a vertical band at angle = 0.
    half bandNormal = centered.x * half(cos(angle)) - centered.y * half(sin(angle));
    // Shift into roughly [0, 1] to match the original version's uv-based range.
    bandNormal += 0.5h;

    // The window's position along `bandNormal` isn't simply `progress` — it's the projection,
    // onto `bandNormal`, of how far the window has traveled along `direction`. A line oriented at
    // `angle` from the y-axis has its normal oriented at that same numeric angle from the x-axis
    // (rotating a line by 90° to get its normal shifts which axis you measure from, but not the
    // angle's value) — so `angle`, unchanged, is directly comparable to `direction`, which is
    // already measured from the x-axis. The angle between the direction of travel and the band's
    // normal is therefore just `direction − angle`, and its cosine is the fraction of travel that
    // actually advances the window along bandNormal. When they coincide (the usual case, e.g.
    // angle = direction = 0 — a vertical band swept rightward, i.e. along its own normal), this
    // is cos(0) = 1 and progress advances the window at full speed. When they're 90° apart
    // (motion runs along the band's own length instead, e.g. angle = 0, direction = 90°), this is
    // cos(90°) = 0 and the window doesn't advance along bandNormal at all — consistent with a
    // band sweeping along its own length being visually stationary. This value can also go
    // negative (motion more than 90° from the band's normal), which reverses the sweep direction.
    half travelAlongBandNormal = half(cos(direction - angle));

    // Calculate beyond the view's edges based on the gradient size
    half minU = 0.0h - gradientWidth;
    half maxU = 1.0h + gradientWidth;

    // Interpolate the window's position linearly between minU and maxU as progress goes 0 to 1,
    // scaled by travelAlongBandNormal around the range's midpoint. This — rather than
    // `minU + maxU * progress * travelAlongBandNormal`, which was tried and rejected here —
    // is required for negative travelAlongBandNormal to behave correctly: naively scaling `maxU`
    // by a negative travel collapses the sweep to a range that never re-enters [minU, maxU] as
    // progress advances (verified by direct simulation), rather than sweeping the range in
    // reverse. Interpolating around the midpoint instead means travelAlongBandNormal = -1 sweeps
    // maxU -> minU (the reverse of the +1 case) and travelAlongBandNormal = 0 pins the window at
    // the midpoint (stationary, centered) rather than jammed at one edge.
    half mid = (minU + maxU) / 2.0h;
    half halfRange = (maxU - minU) / 2.0h;
    half start = mid + halfRange * travelAlongBandNormal * (2.0h * progress - 1.0h);
    half end = start + gradientWidth;

    if (bandNormal > start && bandNormal < end) {
        // Determine the pixel's position within the gradient, from 0 to 1
        half gradient = smoothstep(start, end, bandNormal);
        // Determine gradient intensity using a sine wave
        half intensity = sin(gradient * M_PI_H);

        // Convert from RGB to HSL
        half3 hsl = rgbToHSL(color.rgb);
        // Modify the lightness component based on intensity
        hsl[2] = hsl[2] + half(maxLightness * (maxLightness > 0.0h ? 1 - hsl[2] : hsl[2])) * intensity;
        // Convert back to RGB
        color.rgb = hslToRGB(hsl);
    }

    return color;
}
