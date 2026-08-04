//
//  ExampleScenario.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

/// Catalog of interactive scenarios demonstrating BackdropBlurKit's behavior and limitations.
enum ExampleScenario: String, CaseIterable, Identifiable {

    /// A vertically scrolling list with a fixed blurred panel.
    case simpleScroll

    /// A fixed, non-scrolling block at the top with the scrolling backdrop starting at its
    /// bottom edge — stresses capture rect/offset math when the effect source doesn't span
    /// the full screen from the top.
    case fixedHeaderOffset

    /// A fixed, non-scrolling effect source with multiple effect targets scrolling over it in a
    /// `ScrollView`/`LazyVStack`, each tracking its own frame — the primary test of concurrent
    /// multi-target support.
    case multiTargetScroll

    /// A vertically scrolling checkerboard background with the GPU `.layerEffect`-based
    /// color-inversion test effect applied directly to the scrolling content — no capture,
    /// snapshot, or masking involved. For side-by-side comparison against `.simpleScroll`,
    /// which exercises the CPU-snapshot pipeline.
    case layerEffectScroll

    /// A vertically scrolling checkerboard background with the GPU `.layerEffect`-based
    /// color-inversion effect masked to five real target markers' measured frames — replaces
    /// `.layerEffectScroll`'s hardcoded mask rect with genuine `PreferenceKey`-collected
    /// geometry, still with no capture, snapshot, or CPU-pipeline coordinator involved.
    case layerEffectTargetsScroll

    /// A single fixed (non-scrolling) `.layerEffect` source with multiple effect targets
    /// scrolling over it in a `ScrollView`/`LazyVStack` — the `.layerEffect` counterpart to
    /// `.multiTargetScroll`, testing the same fixed-source/moving-targets pairing on the GPU
    /// pipeline.
    case multiTargetLayerEffectScroll

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .simpleScroll: "Simple Scroll"
        case .fixedHeaderOffset: "Fixed Header Offset"
        case .multiTargetScroll: "Multiple Targets"
        case .layerEffectScroll: "Layer Effect Scroll"
        case .layerEffectTargetsScroll: "Layer Effect Targets"
        case .multiTargetLayerEffectScroll: "Multiple Targets (Layer Effect)"
        }
    }

    /// The section this scenario belongs to.
    var section: ExampleSection {
        switch self {
        case .simpleScroll: .layout
        case .fixedHeaderOffset: .layout
        case .multiTargetScroll: .layout
        case .layerEffectScroll: .layerEffect
        case .layerEffectTargetsScroll: .layerEffect
        case .multiTargetLayerEffectScroll: .layerEffect
        }
    }
}
