//
//  ExampleScenario.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

/// Catalog of interactive scenarios demonstrating Undertow's effect pipeline.
enum ExampleScenario: String, CaseIterable, Identifiable {

    /// A vertically scrolling checkerboard background with the GPU-based
    /// color-inversion effect masked to five real target markers' measured frames — genuine
    /// `PreferenceKey`-collected geometry.
    case movingBackgroundFixedPanels

    /// A single fixed (non-scrolling) effect source with multiple effect targets
    /// scrolling over it in a `ScrollView`/`LazyVStack`.
    case movingPanelsFixedBackground

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .movingBackgroundFixedPanels: "Moving Background, Fixed Panels"
        case .movingPanelsFixedBackground: "Moving Panels, Fixed Background"
        }
    }
}
