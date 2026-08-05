# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This library is unpublished — no tagged release, no versioning guarantees. It's under active
development; APIs (including the CPU-snapshot pipeline described below and the newer
`.layerEffect`-based path under development on branch `feature/layerEffect`) may change shape
freely. Known gaps and rough edges (e.g. size-class-transition frame staleness in the
layerEffect path's target tracking) are expected at this stage and don't need to block work —
they get noted and revisited before any eventual first release, not fixed reflexively.

## What this is

Undertow is a Swift Package (iOS 17+, Swift 6 language mode) that provides a live,
performant backdrop visual-effects pipeline for SwiftUI, similar to `UIVisualEffectView` but working
across arbitrary scrolling/animating content and multiple simultaneous effect targets. It ships as a
library target (`Sources/Undertow`) plus an example iOS app (`Example/BackdropBlurKitExampleApp`)
that consumes the package locally. Currently the only implemented effect is Gaussian blur — see
`EffectConfiguration` in the Architecture section below.

## Commands

- Build the package: `swift build`
- Run tests: `swift test`
- Run a single test: `swift test --filter UndertowTests.example` (Swift Testing `@Test` functions
  are addressed as `<TargetTests>.<funcName>`)
- The example app is a standalone Xcode project at
  `Example/BackdropBlurKitExampleApp/BackdropBlurKitExampleApp.xcodeproj` — open it in Xcode to run on
  a simulator/device (it depends on the local package plus a remote package, `BarKit`, for its tab bar UI).

## Architecture

The library implements a snapshot-based effects pipeline: instead of a real-time compositor effect, it
periodically renders the background view hierarchy to an image, applies Core Image filters to
that image, and displays the resulting bitmap cropped behind each effect target.
Understanding it requires following data through four cooperating pieces:

1. **`effectCoordinator()`** (`EffectCoordinator/EffectCoordinatorModifier.swift`) — applied once, near the
   root of an effect subtree. It owns the shared `EffectSnapshotStore` (an `@Observable` reference
   type) and injects it into the environment (`\.effectSnapshotStore`), along with the coordinate
   space's size (`\.effectSourceSize`). It also listens for `EffectTargetFramesPreferenceKey` changes
   bubbling up from all `.effectTarget()` descendants and computes their union rect (`store.captureRect`),
   so the source only needs to render/process the minimal region actually visible behind effect targets.

2. **`effectSource()`** (`Extensions/View+effectSource.swift` → `EffectSourceWrapper` → `EffectSource`,
   `EffectSource/`) — applied to the background content that should be processed. `EffectSource` is a
   `UIViewControllerRepresentable` that hosts the content in an isolated `EffectHostingController`
   (a `UIHostingController` subclass exposing appear/disappear/layout as closures). Isolating it in
   its own hosting controller means the snapshot is clean — it doesn't accidentally capture floating
   `.effectTarget()` overlay views. Its `Coordinator`:
   - Drives capture via a `CADisplayLink` (`DisplayLinkCoordinator`), paused by default.
   - Uses `ScrollTracker` to recursively find `UIScrollView`s in the hosted hierarchy via KVO on
     `contentOffset`, and un-pauses the display link only while scrolling is active (perf optimization
     — no need to re-render every frame when nothing is moving).
   - On each capture tick, renders `view.layer` into a `UIGraphicsImageRenderer` bitmap cropped to
     `store.captureRect` (or the full view if no targets are registered yet), then hands the bitmap to
     `EffectSnapshotProcessor` on a detached background task.
   - Also re-captures immediately whenever `store.captureRect` changes (via
     `store.onCaptureRectChanged`), e.g. when a new effect target appears/moves/resizes.
   - Results are delivered back to the main actor and pushed into `store.snapshots`, keyed by
     `EffectConfiguration`.

3. **`EffectSnapshotProcessor`** (`EffectSource/EffectSnapshotProcessor.swift`) — a `Sendable` type holding
   one shared Metal-backed `CIContext` (expensive to create, so it's reused). For each requested
   `EffectConfiguration` it applies the corresponding Core Image filter and returns a
   `[EffectConfiguration: UIImage]` dictionary. Currently only `.gaussian(radius:)` is implemented;
   `.kawase(passes:distance:)` is defined in `Core/EffectConfiguration.swift` but its case in the
   processor's switch is a stub (not yet implemented) — treat Kawase as "declared API, no
   implementation" rather than assuming it works.

4. **`effectTarget()`** (`Extensions/View+effectTarget.swift` → `EffectTargetViewModifier`,
   `EffectTarget/`) — applied to any view that should show processed content behind it. It reads its own
   frame in the global coordinate space via `GeometryReader`, reports that frame up through
   `EffectTargetFramesPreferenceKey` (consumed by the coordinator, see above), looks up
   `store.snapshots[effectiveConfiguration]`, and renders a cropped/offset `Image` positioned so the
   snapshot lines up pixel-for-pixel with the target's location relative to `store.captureRect`.
   `effectiveConfiguration` resolves an explicit per-call `configuration:` override before falling
   back to the environment value (`\.effectConfiguration`), which itself defaults to
   `EffectConfiguration.default` (`.gaussian(radius: 8)`).

Multiple effect targets under one coordinator can request different `EffectConfiguration`s
simultaneously; the store keys snapshots by configuration and the processor processes the same base
snapshot once per distinct configuration in use.

Debug builds emit `os_signpost` intervals (`Extensions/EffectSignpost.swift`, subsystem
`Undertow`, category `Capture`) around whole-capture/render/process/deliver phases — useful
for profiling capture performance in Instruments. These are no-ops in release builds.

## Architecture Principle: One Snapshot Per Display-Link Tick

The ideal state is: exactly one snapshot capture + effect processing per CADisplayLink tick,
with no duplicate work or skipped frames.

This requires all three independent `captureSnapshot()` triggers (displayLink.onFrameUpdate,
onLayout, onCaptureRectChanged) to be coalesced into a single "needs snapshot" queue
consumed once per tick (target: optimization #5).

Hierarchy walks (bind throttle) are orthogonal and may use separate timers without
architectural conflict — provided they don't force displayLink to unpause when idle.

## Typical usage shape

```swift
ZStack {
    scrollingBackground
        .effectSource()

    fixedPanel
        .effectTarget(cornerRadius: 16)
}
.effectCoordinator()
```

`effectCoordinator()` must wrap both the `effectSource()` and any `.effectTarget()` views for the environment
plumbing to connect them — see `Example/.../Screens/SimpleScrollView.swift` for a working reference.

## Documentation

All public and internal types, properties, and functions must have DocC-style
doc comments (`///`). Use `- Parameters:` and `- Returns:` where applicable.
No exceptions for "obvious" declarations — every declaration gets a doc comment.

## Build policy

Do NOT run `swift build`, `swift test`, or `xcodebuild` (including against the
Example app's `.xcodeproj`) after making changes. Building and testing —
package and example app alike — is the user's responsibility and will be done
manually in Xcode.

## Debug logging

`print("[LOGGING] <event>, <time>")` statements in `EffectSnapshotStore`, `EffectTargetViewModifier`,
and `EffectSource` trace the capture pipeline (store mutations, target frame reporting, source
lifecycle events, capture entry/exit). These were added to diagnose the bare-root-screen
`targetFrames`-never-populates regression and are intentionally left in place — do not strip
them in a cleanup pass. Remove only if explicitly asked.

## Render path choice: drawHierarchy vs layer.render(in:)

EffectSource's snapshot capture can use either view.layer.render(in:) or view.drawHierarchy(in:afterScreenUpdates:). They are not interchangeable in all cases.

layer.render(in:) walks the layer tree on the CPU and draws each layer into a CGContext. It's roughly 3x faster (measured: ~4ms vs ~11-14ms mean, ~30-35ms max for drawHierarchy on comparable content). However, some system layers — notably CABackdropLayer and CAPortalLayer, which UIKit uses to composite live translucent backdrop effects (e.g. behind a UINavigationController's navigation bar) — have no locally-readable backing store; they're composited by the render server, not drawn into a CPU-accessible buffer. layer.render(in:) cannot resolve them: the result is a silently blank or corrupted region, with no error.

drawHierarchy(in:afterScreenUpdates:) goes through the normal screen-update/compositing path instead of walking the layer tree directly, so it captures these layer types correctly. The cost is the slower render time, plus (with afterScreenUpdates: true) a synchronous flush of any pending Core Animation transaction for the affected view hierarchy.

Current release does not attempt to detect or support this automatically inside a NavigationStack — known limitation, revisit before shipping nav-stack support.
