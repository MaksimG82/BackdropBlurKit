//
//  LayerEffectScrollView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI
import LiveBackdropKit

/// A vertically scrolling checkerboard background with the GPU `.layerEffect`-based
/// color-inversion test effect applied directly to the scrolling content, for side-by-side
/// comparison against `SimpleScrollView`'s CPU-snapshot pipeline. There is no capture source,
/// effect target, or coordinator here — `invertedLayerEffect()` runs on every frame as a
/// native SwiftUI layer effect, with no masking.
struct LayerEffectScrollView: View {

    var body: some View {
        scrollingBackdrop
            .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension LayerEffectScrollView {

    var scrollingBackdrop: some View {
        ScrollView {
            CheckerboardBackground()
                .frame(height: 2000)
                .invertedLayerEffect()
        }
    }
}

#Preview {
    LayerEffectScrollView()
}
