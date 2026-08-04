//
//  SettingSlider.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 13.04.26.
//

import SwiftUI

/// A labeled slider showing its current value, used throughout the settings sheets for
/// numeric effect parameters. Copied from BarKit's example app (`BarKitExample`), which uses
/// the identical pattern for its own settings screens.
struct SettingSlider<Value>: View
where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint {

    /// Formatting for the value shown next to `title`.
    enum ValueFormat: String {
        case integer = "%.0f"
        case fractionalOne = "%.1f"
        case fractionalTwo = "%.2f"
    }

    /// The label shown alongside the current value.
    let title: String

    /// The bound value controlled by the slider.
    @Binding var value: Value

    /// The slider's allowed range.
    let range: ClosedRange<Value>

    /// The slider's step size. Defaults to `1`.
    var step: Value.Stride = 1

    /// How the current value is formatted next to `title`. Defaults to `.integer`.
    var format: ValueFormat = .integer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(title): \(String(format: format.rawValue, Double(value)))")
                .font(.subheadline)
            Slider(value: $value, in: range, step: step)
                .contentShape(Rectangle())
                .defersSystemGestures(on: .horizontal)
        }
    }
}
