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

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .simpleScroll: "Simple Scroll"
        case .fixedHeaderOffset: "Fixed Header Offset"
        }
    }

    /// The section this scenario belongs to.
    var section: ExampleSection {
        switch self {
        case .simpleScroll: .layout
        case .fixedHeaderOffset: .layout
        }
    }
}
