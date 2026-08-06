//
//  ScenarioBackground.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// The background content a scenario renders behind its effect/target views, selectable from
/// the settings sheet's `Background` tab.

enum ScenarioBackground {
    /// A high-contrast checkerboard pattern, used to make blur quality and edge artifacts
    /// clearly visible.
    /// - Parameters:
    ///   - squareSize: The size of each individual square, in points.
    ///   - primaryColor: The first color in the alternating pattern.
    ///   - secondaryColor: The second color in the alternating pattern.
    case checkerboard(squareSize: CGFloat, primaryColor: Color, secondaryColor: Color)

    /// A user-picked photo, chosen via `PhotosPicker`. Only meaningful for stationary-background
    /// scenarios — a single photo has no natural way to fill a tall, scrolling `ScrollView`
    /// without stretching or tiling, so this case isn't offered there (see
    /// `ScenarioBackgroundKind.availableKinds(forMovingBackground:)`).
    /// - Parameter image: The picked photo, or `nil` before the user has picked one.
    case photo(image: Image?)

    /// The default checkerboard configuration, matching `CheckerboardBackground`'s own defaults.
    static let defaultCheckerboard = ScenarioBackground.checkerboard(
        squareSize: 44,
        primaryColor: Color(red: 0.11, green: 0.12, blue: 0.16),
        secondaryColor: Color(red: 0.98, green: 0.42, blue: 0.32)
    )

    /// The default photo configuration — no photo picked yet.
    static let defaultPhoto = ScenarioBackground.photo(image: nil)
}

