# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

BackdropBlurKit is a Swift Package (iOS 17+, Swift 6 language mode) that provides a live,
performant backdrop-blur effect for SwiftUI, similar to `UIVisualEffectView` but working across
arbitrary scrolling/animating content and multiple simultaneous blur targets. It ships as a
library target (`Sources/BackdropBlurKit`) plus an example iOS app (`Example/BackdropBlurKitExampleApp`)
that consumes the package locally.

## Commands

- Build the package: `swift build`
- Run tests: `swift test`
- Run a single test: `swift test --filter BackdropBlurKitTests.example` (Swift Testing `@Test` functions
  are addressed as `<TargetTests>.<funcName>`)
- The example app is a standalone Xcode project at
  `Example/BackdropBlurKitExampleApp/BackdropBlurKitExampleApp.xcodeproj` — open it in Xcode to run on
  a simulator/device (it depends on the local package plus a remote package, `BarKit`, for its tab bar UI).

Note: `Package.swift` declares the test target `path: "Tests/BackdropBlurKit"`, but the folder on disk is
`Tests/BackdropBlurKitTests`. If `swift build`/`swift test` fail to resolve the test target, check whether
this path has been reconciled before assuming it's your change that broke it.

## Architecture

The library implements a snapshot-based blur pipeline: instead of a real-time compositor blur, it
periodically renders the background view hierarchy to an image, applies Core Image blur filters to
that image off the main thread, and displays the resulting bitmap cropped behind each blur target.
Understanding it requires following data through four cooperating pieces:

1. **`blurCoordinator()`** (`BlurCoordinator/BlurCoordinatorModifier.swift`) — applied once, near the
   root of a blur-effect subtree. It owns the shared `BlurSnapshotStore` (an `@Observable` reference
   type) and injects it into the environment (`\.blurSnapshotStore`), along with the coordinate
   space's size (`\.blurSourceSize`). It also listens for `BlurTargetFramesPreferenceKey` changes
   bubbling up from all `.blurred()` descendants and computes their union rect (`store.captureRect`),
   so the source only needs to render/blur the minimal region actually visible behind blur targets.

2. **`blurSource()`** (`Extensions/View+blurSource.swift` → `BlurSourceWrapper` → `BlurSource`,
   `BlurSource/`) — applied to the background content that should be blurred. `BlurSource` is a
   `UIViewControllerRepresentable` that hosts the content in an isolated `BlurHostingController`
   (a `UIHostingController` subclass exposing appear/disappear/layout as closures). Isolating it in
   its own hosting controller means the snapshot is clean — it doesn't accidentally capture floating
   `.blurred()` overlay views. Its `Coordinator`:
   - Drives capture via a `CADisplayLink` (`DisplayLinkCoordinator`), paused by default.
   - Uses `ScrollTracker` to recursively find `UIScrollView`s in the hosted hierarchy via KVO on
     `contentOffset`, and un-pauses the display link only while scrolling is active (perf optimization
     — no need to re-render every frame when nothing is moving).
   - On each capture tick, renders `view.layer` into a `UIGraphicsImageRenderer` bitmap cropped to
     `store.captureRect` (or the full view if no targets are registered yet), then hands the bitmap to
     `BlurSnapshotProcessor` on a detached background task.
   - Also re-captures immediately whenever `store.captureRect` changes (via
     `store.onCaptureRectChanged`), e.g. when a new blur target appears/moves/resizes.
   - Results are delivered back to the main actor and pushed into `store.snapshots`, keyed by
     `BlurConfiguration`.

3. **`BlurSnapshotProcessor`** (`BlurSource/BlurSnapshotProcessor.swift`) — a `Sendable` type holding
   one shared Metal-backed `CIContext` (expensive to create, so it's reused). For each requested
   `BlurConfiguration` it applies the corresponding Core Image filter and returns a
   `[BlurConfiguration: UIImage]` dictionary. Currently only `.gaussian(radius:)` is implemented;
   `.kawase(passes:distance:)` is defined in `Core/BlurConfiguration.swift` but its case in the
   processor's switch is a stub (not yet implemented) — treat Kawase as "declared API, no
   implementation" rather than assuming it works.

4. **`blurred()`** (`Extensions/View+blurred.swift` → `BlurTargetViewModifier`,
   `BlurTarget/`) — applied to any view that should show blurred content behind it. It reads its own
   frame in the global coordinate space via `GeometryReader`, reports that frame up through
   `BlurTargetFramesPreferenceKey` (consumed by the coordinator, see above), looks up
   `store.snapshots[effectiveConfiguration]`, and renders a cropped/offset `Image` positioned so the
   snapshot lines up pixel-for-pixel with the target's location relative to `store.captureRect`.
   `effectiveConfiguration` resolves an explicit per-call `blurConfiguration:` override before falling
   back to the environment value (`\.blurConfiguration`), which itself defaults to
   `BlurConfiguration.default` (`.gaussian(radius: 8)`).

Multiple blur targets under one coordinator can request different `BlurConfiguration`s
simultaneously; the store keys snapshots by configuration and the processor blurs the same base
snapshot once per distinct configuration in use.

Debug builds emit `os_signpost` intervals (`Extensions/BlurSignpost.swift`, subsystem
`BackdropBlurKit`, category `Capture`) around whole-capture/render/process/deliver phases — useful
for profiling capture performance in Instruments. These are no-ops in release builds.

## Typical usage shape

```swift
ZStack {
    scrollingBackground
        .blurSource()

    fixedPanel
        .blurred(cornerRadius: 16)
}
.blurCoordinator()
```

`blurCoordinator()` must wrap both the `blurSource()` and any `.blurred()` views for the environment
plumbing to connect them — see `Example/.../Screens/SimpleScrollView.swift` for a working reference.

## Documentation

All public and internal types, properties, and functions must have DocC-style
doc comments (`///`). Use `- Parameters:` and `- Returns:` where applicable.
No exceptions for "obvious" declarations — every declaration gets a doc comment.

## Build policy

Do NOT run `swift build` or `swift test` after making changes. Building and
testing is the user's responsibility and will be done manually in Xcode.
