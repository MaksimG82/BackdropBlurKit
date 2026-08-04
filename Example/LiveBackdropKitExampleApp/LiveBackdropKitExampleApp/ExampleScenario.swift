//
//  ExampleScenario.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

/// Catalog of interactive scenarios demonstrating BackdropBlurKit's behavior and limitations.
enum ExampleScenario: String, CaseIterable, Identifiable {

    /// A vertically scrolling list with a fixed blurred panel.
    case movingBackgroundFixedPanel

    /// A fixed, non-scrolling block at the top with the scrolling backdrop starting at its
    /// bottom edge — stresses capture rect/offset math when the effect source doesn't span
    /// the full screen from the top.
    case fixedBackgroundOffsetFromTop

    /// A fixed, non-scrolling effect source with multiple effect targets scrolling over it in a
    /// `ScrollView`/`LazyVStack`, each tracking its own frame — the primary test of concurrent
    /// multi-target support.
    case movingPanelsFixedBackground

    /// A vertically scrolling checkerboard background with the GPU `.layerEffect`-based
    /// color-inversion effect masked to five real target markers' measured frames — genuine
    /// `PreferenceKey`-collected geometry, no capture, snapshot, or CPU-pipeline coordinator
    /// involved.
    case movingBackgroundFixedPanelsLayerEffect

    /// A single fixed (non-scrolling) `.layerEffect` source with multiple effect targets
    /// scrolling over it in a `ScrollView`/`LazyVStack` — the `.layerEffect` counterpart to
    /// `.movingPanelsFixedBackground`, testing the same fixed-source/moving-targets pairing on
    /// the GPU pipeline.
    case movingPanelsFixedBackgroundLayerEffect

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .movingBackgroundFixedPanel: "Moving Background, Fixed Panel"
        case .fixedBackgroundOffsetFromTop: "Fixed Background, Offset From Top"
        case .movingPanelsFixedBackground: "Moving Panels, Fixed Background"
        case .movingBackgroundFixedPanelsLayerEffect: "Moving Background, Fixed Panels"
        case .movingPanelsFixedBackgroundLayerEffect: "Moving Panels, Fixed Background"
        }
    }

    /// The section this scenario belongs to.
    var section: ExampleSection {
        switch self {
        case .movingBackgroundFixedPanel: .layout
        case .fixedBackgroundOffsetFromTop: .layout
        case .movingPanelsFixedBackground: .layout
        case .movingBackgroundFixedPanelsLayerEffect: .layerEffect
        case .movingPanelsFixedBackgroundLayerEffect: .layerEffect
        }
    }
}
