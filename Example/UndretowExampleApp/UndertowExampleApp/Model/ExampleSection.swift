//
//  ExampleSection.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

/// Top-level grouping for scenarios shown in the Examples list.
enum ExampleSection: String, CaseIterable {

    /// Scenarios stressing scroll and layout behavior in the CPU-snapshot pipeline
    /// (`effectSource`/`effectTarget`/`effectCoordinator`).
    case layout = "Layout"

    /// Scenarios exercising the alternative GPU `.layerEffect` pipeline, for side-by-side
    /// comparison against the CPU-snapshot pipeline in `.layout`.
    case layerEffect = "Layer Effect"
}
