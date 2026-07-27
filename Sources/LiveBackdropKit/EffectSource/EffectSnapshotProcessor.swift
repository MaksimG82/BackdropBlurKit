//
//  EffectSnapshotProcessor.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import UIKit
import CoreImage

/// Applies visual effects to a snapshot image for each requested configuration.
///
/// A single shared `CIContext` is reused across calls to avoid costly Metal pipeline recreation.
final class EffectSnapshotProcessor: Sendable {

    /// The Core Image rendering context backed by a Metal device.
    private let ciContext: CIContext

    /// Initializes the processor with a Metal-backed Core Image context.
    init() {
        ciContext = CIContext(options: [.useSoftwareRenderer: false])
    }

    /// Applies each effect configuration to the snapshot and returns a dictionary of results.
    /// - Parameters:
    ///   - snapshot: The raw unprocessed snapshot of the source view hierarchy.
    ///   - configurations: The set of unique effect configurations to apply.
    /// - Returns: A dictionary mapping each configuration to its processed output image.
    func process(snapshot: UIImage, configurations: Set<EffectConfiguration>) -> [EffectConfiguration: UIImage] {
        guard let ciImage = CIImage(image: snapshot) else { return [:] }

        var result: [EffectConfiguration: UIImage] = [:]

        for configuration in configurations {
            switch configuration {
            case .gaussian(let radius):
                result[configuration] = applyGaussian(to: ciImage, radius: radius, original: snapshot)
            case .kawase:
                break
            }
        }

        return result
    }

    /// Applies a Gaussian blur filter using Core Image.
    /// - Parameters:
    ///   - image: The source `CIImage` to process.
    ///   - radius: The blur radius passed to `CIGaussianBlur`.
    ///   - original: The original `UIImage` used as fallback and for scale/orientation metadata.
    /// - Returns: A blurred `UIImage`, or the original if rendering fails.
    private func applyGaussian(to image: CIImage, radius: CGFloat, original: UIImage) -> UIImage {
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            return original
        }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        guard let output = filter.outputImage else {
            return original
        }

        let cropped = output.cropped(to: image.extent)

        // TEMP: lag investigation — remove after verification
        // Brackets only the GPU-bound render/readback, so this measures actual
        // frame-budget cost under real load, not filter-graph setup time.
        effectSignpostBegin("applyGaussian")
        let cgImage = ciContext.createCGImage(cropped, from: cropped.extent)
        effectSignpostEnd("applyGaussian")

        guard let cgImage else {
            return original
        }

        return UIImage(cgImage: cgImage, scale: original.scale, orientation: original.imageOrientation)
    }
}
