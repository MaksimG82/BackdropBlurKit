//
//  ExampleScenario.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

/// Catalog of interactive scenarios demonstrating Undertow's `.layerEffect` pipeline.
enum ExampleScenario: String, CaseIterable, Identifiable {

    /// A vertically scrolling checkerboard background with the GPU `.layerEffect`-based
    /// color-inversion effect masked to five real target markers' measured frames — genuine
    /// `PreferenceKey`-collected geometry.
    case movingBackgroundFixedPanelsLayerEffect

    /// A single fixed (non-scrolling) `.layerEffect` source with multiple effect targets
    /// scrolling over it in a `ScrollView`/`LazyVStack`.
    case movingPanelsFixedBackgroundLayerEffect

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .movingBackgroundFixedPanelsLayerEffect: "Moving Background, Fixed Panels"
        case .movingPanelsFixedBackgroundLayerEffect: "Moving Panels, Fixed Background"
        }
    }
}
