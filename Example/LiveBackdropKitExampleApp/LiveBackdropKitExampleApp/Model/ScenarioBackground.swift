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
/// parameters as associated values. Only `.checkerboard` and `.gradient` are implemented so
/// far — `.photo` and `.video` are follow-up work (photo/video need a way to size a
/// large-content `ScrollView` from media rather than a fixed `.frame(height:)`, which isn't
/// solved yet; video may end up restricted to stationary-background scenarios only).
enum ScenarioBackground: Hashable {
    /// A high-contrast checkerboard pattern, used to make blur quality and edge artifacts
    /// clearly visible.
    /// - Parameters:
    ///   - squareSize: The size of each individual square, in points.
    ///   - primaryColor: The first color in the alternating pattern.
    ///   - secondaryColor: The second color in the alternating pattern.
    case checkerboard(squareSize: CGFloat, primaryColor: Color, secondaryColor: Color)

    /// A linear gradient between two colors.
    /// - Parameters:
    ///   - startColor: The color at the gradient's start point.
    ///   - endColor: The color at the gradient's end point.
    ///   - direction: The direction the gradient sweeps in.
    case gradient(startColor: Color, endColor: Color, direction: GradientDirection)

    /// The default checkerboard configuration, matching `CheckerboardBackground`'s own defaults.
    static let defaultCheckerboard = ScenarioBackground.checkerboard(
        squareSize: 64,
        primaryColor: .orange,
        secondaryColor: .indigo
    )

    /// The default gradient configuration.
    static let defaultGradient = ScenarioBackground.gradient(
        startColor: .blue,
        endColor: .purple,
        direction: .topToBottom
    )

    /// Renders this background's content, so scenarios don't need their own `switch` over
    /// every `ScenarioBackground` case.
    @ViewBuilder
    var content: some View {
        switch self {
        case let .checkerboard(squareSize, primaryColor, secondaryColor):
            CheckerboardBackground(squareSize: squareSize, primaryColor: primaryColor, secondaryColor: secondaryColor)
        case let .gradient(startColor, endColor, direction):
            LinearGradient(
                colors: [startColor, endColor],
                startPoint: direction.startPoint,
                endPoint: direction.endPoint
            )
        }
    }
}

/// The sweep direction for a `.gradient` background — a fixed set of standard directions
/// (rather than a free-form angle) so the settings sheet can offer a simple picker instead of
/// two separate X/Y sliders.
enum GradientDirection: String, CaseIterable, Identifiable {
    case topToBottom
    case bottomToTop
    case leadingToTrailing
    case trailingToLeading
    case topLeadingToBottomTrailing
    case topTrailingToBottomLeading

    var id: Self { self }

    /// The display name shown in the direction picker.
    var title: String {
        switch self {
        case .topToBottom: "Top to Bottom"
        case .bottomToTop: "Bottom to Top"
        case .leadingToTrailing: "Leading to Trailing"
        case .trailingToLeading: "Trailing to Leading"
        case .topLeadingToBottomTrailing: "Diagonal ↘"
        case .topTrailingToBottomLeading: "Diagonal ↙"
        }
    }

    /// The gradient's starting `UnitPoint`.
    var startPoint: UnitPoint {
        switch self {
        case .topToBottom: .top
        case .bottomToTop: .bottom
        case .leadingToTrailing: .leading
        case .trailingToLeading: .trailing
        case .topLeadingToBottomTrailing: .topLeading
        case .topTrailingToBottomLeading: .topTrailing
        }
    }

    /// The gradient's ending `UnitPoint`.
    var endPoint: UnitPoint {
        switch self {
        case .topToBottom: .bottom
        case .bottomToTop: .top
        case .leadingToTrailing: .trailing
        case .trailingToLeading: .leading
        case .topLeadingToBottomTrailing: .bottomTrailing
        case .topTrailingToBottomLeading: .bottomLeading
        }
    }
}

/// A parameter-less identifier for each `ScenarioBackground` case, used to drive the background
/// picker in a scenario's settings sheet — same rationale as `LayerEffectKind` for
/// `LayerEffectConfiguration`.
enum ScenarioBackgroundKind: String, CaseIterable, Identifiable {
    case checkerboard
    case gradient

    var id: Self { self }

    /// The display name shown in the background picker.
    var title: String {
        switch self {
        case .checkerboard: "Checkerboard"
        case .gradient: "Gradient"
        }
    }

    /// The kind backing a given background, for initializing the picker's selection from an
    /// existing `ScenarioBackground`.
    init(_ background: ScenarioBackground) {
        switch background {
        case .checkerboard: self = .checkerboard
        case .gradient: self = .gradient
        }
    }

    /// The default parameter values used when this kind is first selected in the background
    /// picker.
    var defaultBackground: ScenarioBackground {
        switch self {
        case .checkerboard: .defaultCheckerboard
        case .gradient: .defaultGradient
        }
    }
}
