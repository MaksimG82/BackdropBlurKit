//
//  Shimmer.metal
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//
//  Adapted from Shimmer.metal in Inferno (https://github.com/twostraws/Inferno),
//  by Paul Hudson / twostraws. Adaptation by Maksim Gaisin.
//
//  Unlike the original (horizontal-only), this version adds two independent angle parameters:
//  `angle` (the band's own orientation) and `direction` (which way the gradient sweeps). Both are
//  computed in centered, aspect-corrected coordinates rather than raw uv, to avoid warping on
//  non-square views.
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

    float loopedProgress = fmod(time, float(animationDuration));
    half progress = loopedProgress / animationDuration;

    // Centered, aspect-corrected coordinate (roughly [-0.5, 0.5] along the larger dimension) so
    // angles are true geometric angles, not warped by a non-square view.
    float maxDimension = max(size.x, size.y);
    half2 centered = half2((position - size / 2.0) / maxDimension);

    // bandNormal is the axis perpendicular to the band: rotate `centered` by `angle` and take the
    // x-component (standard 2D rotation, x' = x·cos(θ) − y·sin(θ)).
    half bandNormal = centered.x * half(cos(angle)) - centered.y * half(sin(angle));
    bandNormal += 0.5h;

    // How fast the window advances along bandNormal is the cosine of the angle between the
    // travel direction and the band's normal — 1 when they coincide (full speed), 0 when travel
    // runs along the band's own length (visually stationary), negative to reverse.
    half travelAlongBandNormal = half(cos(direction - angle));

    half minU = 0.0h - gradientWidth;
    half maxU = 1.0h + gradientWidth;

    // Interpolate around the midpoint (rather than scaling maxU directly) so negative
    // travelAlongBandNormal correctly reverses the sweep instead of collapsing the range.
    half mid = (minU + maxU) / 2.0h;
    half halfRange = (maxU - minU) / 2.0h;
    half start = mid + halfRange * travelAlongBandNormal * (2.0h * progress - 1.0h);
    half end = start + gradientWidth;

    if (bandNormal > start && bandNormal < end) {
        half gradient = smoothstep(start, end, bandNormal);
        half intensity = sin(gradient * M_PI_H);

        half3 hsl = rgbToHSL(color.rgb);
        hsl[2] = hsl[2] + half(maxLightness * (maxLightness > 0.0h ? 1 - hsl[2] : hsl[2])) * intensity;
        color.rgb = hslToRGB(hsl);
    }

    return color;
}
