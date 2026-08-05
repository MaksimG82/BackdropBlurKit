//
//  ScenarioBackgroundView.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// Renders a `ScenarioBackground`'s content, so scenarios don't need their own `switch` over
/// every case. Kept separate from `ScenarioBackground` itself so that type stays a plain data
/// model with no SwiftUI rendering knowledge.
struct ScenarioBackgroundView: View {

    /// The background to render.
    let background: ScenarioBackground

    var body: some View {
        switch background {
        case let .checkerboard(squareSize, primaryColor, secondaryColor):
            CheckerboardBackground(squareSize: squareSize, primaryColor: primaryColor, secondaryColor: secondaryColor)
        case let .photo(image):
            if let image {
                GeometryReader { proxy in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            } else {
                Color(.systemGray5)
            }
        }
    }
}
