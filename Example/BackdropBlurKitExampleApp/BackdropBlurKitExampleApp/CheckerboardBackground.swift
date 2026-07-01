//
//  CheckerboardBackground.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI

/// A high-contrast checkerboard pattern used to make blur quality and edge artifacts clearly visible.
struct CheckerboardBackground: View {

    /// The size of each individual square.
    var squareSize: CGFloat = 32

    /// The first color in the alternating pattern.
    var primaryColor: Color = .orange

    /// The second color in the alternating pattern.
    var secondaryColor: Color = .indigo

    init(squareSize: CGFloat = 32, primaryColor: Color = .orange, secondaryColor: Color = .indigo) {
        self.squareSize = squareSize
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / squareSize))
            let rows = Int(ceil(size.height / squareSize))

            for row in 0..<rows {
                for column in 0..<columns {
                    let isEven = (row + column).isMultiple(of: 2)
                    let rect = CGRect(
                        x: CGFloat(column) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isEven ? primaryColor : secondaryColor)
                    )
                }
            }
        }
    }
}

#Preview {
    CheckerboardBackground()
}
