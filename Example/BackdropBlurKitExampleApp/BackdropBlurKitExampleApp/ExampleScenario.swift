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

    /// A stable identifier for use in SwiftUI lists and navigation.
    var id: Self { self }

    /// The display title shown in the scenario list.
    var title: String {
        switch self {
        case .simpleScroll: "Simple Scroll"
        }
    }

    /// The section this scenario belongs to.
    var section: ExampleSection {
        switch self {
        case .simpleScroll: .layout
        }
    }
}
