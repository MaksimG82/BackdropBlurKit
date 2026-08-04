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
/// native SwiftUI layer effect, applied to the same scrolling layer the checkerboard renders
/// on (not a separate, unsynchronized copy), so the effect's content always lines up with the
/// backdrop scrolling beneath it.
///
/// Step 3 placeholder: the effect is masked to five rounded-rect windows — four small ones
/// near the corners, one larger one centered — all pinned to fixed screen positions while the
/// backdrop scrolls underneath (like `SimpleScrollView`'s `targetView`), standing in for the
/// future target-frame-driven mask (PreferenceKey/coordinator wiring comes later). This is
/// also a quick empirical check of whether a multi-shape `.mask` stays a single composite
/// pass rather than costing once per shape. Each mask's position is computed from the scroll
/// content's own global-space geometry, since the mask lives inside the same `ScrollView` as
/// the effect it's clipping — it has to counter-scroll to stay visually fixed.
struct LayerEffectScrollView: View {

    var body: some View {
        scrollingBackdrop
            .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension LayerEffectScrollView {

    /// One masked window: a fixed on-screen size/position (in the scroll content's own
    /// coordinate space, before counter-scroll is applied) and corner radius.
    struct MaskWindow {
        let size: CGSize
        let screenPosition: CGPoint
        let cornerRadius: CGFloat
    }

    /// Four small corner windows and one larger centered window, all pinned to fixed screen
    /// positions. Positions are expressed as fractions of the viewport size so they land near
    /// the four corners and the center regardless of device size.
    func maskWindows(in viewportSize: CGSize) -> [MaskWindow] {
        let corner = CGSize(width: 90, height: 90)
        let inset: CGFloat = 70

        return [
            MaskWindow(
                size: corner,
                screenPosition: CGPoint(x: inset, y: inset),
                cornerRadius: 16
            ),
            MaskWindow(
                size: corner,
                screenPosition: CGPoint(x: viewportSize.width - inset, y: inset),
                cornerRadius: 16
            ),
            MaskWindow(
                size: corner,
                screenPosition: CGPoint(x: inset, y: viewportSize.height - inset),
                cornerRadius: 16
            ),
            MaskWindow(
                size: corner,
                screenPosition: CGPoint(x: viewportSize.width - inset, y: viewportSize.height - inset),
                cornerRadius: 16
            ),
            MaskWindow(
                size: CGSize(width: 180, height: 340),
                screenPosition: CGPoint(x: viewportSize.width / 2, y: viewportSize.height / 2),
                cornerRadius: 28
            ),
        ]
    }

    var scrollingBackdrop: some View {
        // Outer GeometryReader measures the actual on-screen viewport (the ScrollView's own
        // bounds), independent of content height — this is what mask window positions should
        // be expressed against, not the 2000pt-tall scrolling content.
        GeometryReader { viewportGeometry in
            let viewportSize = viewportGeometry.size

            ScrollView {
                GeometryReader { contentGeometry in
                    // The scroll content's own origin in global space. As the content
                    // scrolls, this becomes more negative — used below to counter-scroll each
                    // mask window so they stay pinned to the same screen positions regardless
                    // of scroll offset.
                    let contentOrigin = contentGeometry.frame(in: .global).origin

                    ZStack {
                        // Unaffected base layer — always fully visible, everywhere, at normal
                        // colors. Without this, masking the effect layer below would also cut
                        // away the checkerboard itself outside the mask windows, since `.mask`
                        // clips its entire input chain, not just the effect.
                        CheckerboardBackground()

                        // Second render of the identical content, effect applied, then masked
                        // down to five windows pinned to fixed screen positions. Because this
                        // is the same checkerboard pattern at the same scroll offset as the
                        // base layer (not an independent/unsynchronized copy), what shows
                        // through each window always lines up with the base layer around it.
                        CheckerboardBackground()
                            .invertedLayerEffect()
                            .mask(
                                // A single ZStack of shapes given to one `.mask(...)` call
                                // unions their opaque regions into one alpha mask, composited
                                // in one pass — not one `.mask` pass per shape. `.mask` sizes
                                // its canvas to the mask view, so each shape is positioned
                                // within a full-content-size ZStack — otherwise the union's
                                // own bounding box would become the only visible area of this
                                // layer.
                                ZStack {
                                    ForEach(Array(maskWindows(in: viewportSize).enumerated()), id: \.offset) { _, window in
                                        RoundedRectangle(cornerRadius: window.cornerRadius)
                                            .frame(width: window.size.width, height: window.size.height)
                                            .position(
                                                x: window.screenPosition.x - contentOrigin.x,
                                                y: window.screenPosition.y - contentOrigin.y
                                            )
                                    }
                                }
                                .frame(width: contentGeometry.size.width, height: contentGeometry.size.height, alignment: .topLeading)
                            )
                    }
                }
                .frame(height: 2000)
            }
        }
    }
}

#Preview {
    LayerEffectScrollView()
}
