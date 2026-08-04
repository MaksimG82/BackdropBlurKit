//
//  ScenarioBackground.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// The background content a scenario renders behind its effect/target views, selectable from
/// the settings sheet's `Background` tab.
///
/// Mirrors `LayerEffectKind`'s shape: a case per background type, each carrying its own
/// parameters as associated values. Only `.checkerboard` is implemented so far — `.photo` and
/// `.video` are follow-up work (photo/video need a way to size a large-content `ScrollView`
/// from media rather than a fixed `.frame(height:)`, which isn't solved yet; video may end up
/// restricted to stationary-background scenarios only).
enum ScenarioBackground: Hashable {
    /// A high-contrast checkerboard pattern, used to make blur quality and edge artifacts
    /// clearly visible.
    /// - Parameters:
    ///   - squareSize: The size of each individual square, in points.
    ///   - primaryColor: The first color in the alternating pattern.
    ///   - secondaryColor: The second color in the alternating pattern.
    case checkerboard(squareSize: CGFloat, primaryColor: Color, secondaryColor: Color)

    /// The default checkerboard configuration, matching `CheckerboardBackground`'s own defaults.
    static let defaultCheckerboard = ScenarioBackground.checkerboard(
        squareSize: 64,
        primaryColor: .orange,
        secondaryColor: .indigo
    )

    /// Renders this background's content, so scenarios don't need their own `switch` over
    /// every `ScenarioBackground` case.
    @ViewBuilder
    var content: some View {
        switch self {
        case let .checkerboard(squareSize, primaryColor, secondaryColor):
            CheckerboardBackground(squareSize: squareSize, primaryColor: primaryColor, secondaryColor: secondaryColor)
        }
    }
}

/// A parameter-less identifier for each `ScenarioBackground` case, used to drive the background
/// picker in a scenario's settings sheet — same rationale as `LayerEffectKind` for
/// `LayerEffectConfiguration`.
enum ScenarioBackgroundKind: String, CaseIterable, Identifiable {
    case checkerboard

    var id: Self { self }

    /// The display name shown in the background picker.
    var title: String {
        switch self {
        case .checkerboard: "Checkerboard"
        }
    }

    /// The kind backing a given background, for initializing the picker's selection from an
    /// existing `ScenarioBackground`.
    init(_ background: ScenarioBackground) {
        switch background {
        case .checkerboard: self = .checkerboard
        }
    }

    /// The default parameter values used when this kind is first selected in the background
    /// picker.
    var defaultBackground: ScenarioBackground {
        switch self {
        case .checkerboard: .defaultCheckerboard
        }
    }
}
