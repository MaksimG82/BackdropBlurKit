# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This library is unpublished — no tagged release, no versioning guarantees. It's under active
development; the public API may change shape freely. Known gaps and rough edges (e.g.
size-class-transition frame staleness in target tracking) are expected at this stage and don't
need to block work — they get noted and revisited before any eventual first release, not fixed
reflexively.

## What this is

Undertow is a Swift Package (iOS 18+, Swift 6 language mode) that provides a live,
performant backdrop visual-effects pipeline for SwiftUI, similar to `UIVisualEffectView` but working
across arbitrary scrolling/animating content and multiple simultaneous effect targets. It ships as a
library target (`Sources/Undertow`) plus an example iOS app (`Example/UndertowExampleApp`)
that consumes the package locally. Effects run entirely on the GPU via SwiftUI's `.layerEffect`,
`.distortionEffect`, and `.colorEffect` shader modifiers — see `Effect` for the
full list of implemented effects (Gaussian blur, color inversion, RGB-shift, emboss, water/wave
distortion, shimmer, and noise).

## Commands

- Build the package: `swift build`
- Run tests: `swift test`
- Run a single test: `swift test --filter UndertowTests.example` (Swift Testing `@Test` functions
  are addressed as `<TargetTests>.<funcName>`)
- The example app is a standalone Xcode project at
  `Example/UndertowExampleApp/UndertowExampleApp.xcodeproj` — open it in Xcode to run on
  a simulator/device (it depends on the local package plus a remote package, `BarKit`, for its tab bar UI).

## Architecture

The library applies GPU shader effects directly to live SwiftUI content — no snapshotting,
capturing, or image processing involved. `.layerEffect` runs on every render pass automatically.
Understanding it requires following data through three cooperating pieces:

1. **`effectCoordinator()`** (`EffectCoordinator/EffectCoordinatorModifier.swift`) —
   applied once, near the root of an effect subtree. It owns the shared `FrameStore`
   (an `@Observable` reference type) and injects it into the environment
   (`\.effectTargetStore`). It listens for `EffectTargetFramePreferenceKey` changes
   bubbling up from all `.effectTarget()` descendants and stores their frames, keyed by a
   stable per-target identity.

2. **`effectSource()`** (`Extensions/View+effectSource.swift` →
   `EffectSourceViewModifier`, `EffectSource/`) — applied to the background content the
   effect should run on. Renders the content twice inside a `GeometryReader`: once unaffected
   (always visible, everywhere), and once with the configured shader effect applied, masked to a
   `ZStack` of rounded rects — one per collected target frame, unioned into a single `.mask(...)`
   pass. Each mask shape is counter-scrolled against the source's own global-space origin so it
   stays pinned to its target's screen position while the content scrolls underneath. Dispatches
   to the shader-applying modifier for the given `Effect` (e.g.
   `gaussianBlurEffect(radius:boundingRect:maxSamples:)`), wrapping in a
   `TimelineView(.animation)` only for time-based configurations (`configuration.isTimeBased`).

3. **`effectTarget()`** (`Extensions/View+effectTarget.swift` →
   `EffectTargetViewModifier`, `EffectTarget/`) — applied to any view that should reveal
   the effect behind it. Measures its own frame in the global coordinate space via `GeometryReader`
   and reports it through `EffectTargetFramePreferenceKey` (consumed by the coordinator, see
   above) — a standard SwiftUI multi-value `PreferenceKey` merge.

One source drives exactly one `Effect` — there's no per-target override or
environment-inherited default. Running several effects on screen at once means several
independent `effectSource()`/`effectTarget()`/`effectCoordinator()` trees.

## Typical usage shape

```swift
ZStack {
    scrollingBackground
        .effectSource(configuration: .gaussianBlur(radius: 10, maxSamples: 5), cornerRadius: 16)

    fixedPanel
        .effectTarget()
}
.effectCoordinator()
```

`effectCoordinator()` must wrap both the `effectSource()` and any `.effectTarget()`
views for the environment plumbing to connect them — see
`Example/UndertowExampleApp/View/Screens/MovingBackgroundFixedPanelsView.swift` for a
working reference.

## Documentation

All public and internal types, properties, and functions must have DocC-style
doc comments (`///`). Use `- Parameters:` and `- Returns:` where applicable.
No exceptions for "obvious" declarations — every declaration gets a doc comment.

## Metal shaders

Shader sources (`.metal`) live in `/Shaders` at the package root, not in `Sources/Undertow`.
`Sources/Undertow/Metal/` contains only precompiled `.metallib` binaries (two per shader —
`<Name>-iphoneos.metallib` and `<Name>-iphonesimulator.metallib`), bundled as package resources.
This avoids requiring consumers to have the Metal toolchain installed just to build the package.

To change a shader:

1. Edit the `.metal` source in `/Shaders`.
2. Recompile it with `Scripts/compileShader.sh <ShaderName>` — this regenerates both the
   `iphoneos` and `iphonesimulator` `.metallib` files into `Sources/Undertow/Metal/`, overwriting
   the old ones. Run it once per shader file (it does not batch-compile).
3. Commit the updated `.metallib` files alongside the `.metal` source change — they are not
   regenerated automatically (no CI step does this).

Each shader has a corresponding `ShaderLibrary+<name>Library.swift` file (`Extensions/`) that
picks the right `.metallib` (device vs. simulator) at runtime and exposes it as a static
`ShaderLibrary` property — see `ShaderLibrary+waterLibrary.swift` for the pattern.

For fast local iteration without recompiling `.metallib` on every change, `.metal` files can
temporarily be added back into `Sources/Undertow` and referenced via `ShaderLibrary.default`
instead of the bundled `.metallib` — this requires the Metal toolchain (`xcrun metal`) to be
installed, which SPM invokes automatically when compiling `.metal` sources inside a target.
Revert to the bundled `.metallib` before committing.

## Build policy

Do NOT run `swift build`, `swift test`, or `xcodebuild` (including against the
Example app's `.xcodeproj`) after making changes. Building and testing —
package and example app alike — is the user's responsibility and will be done
manually in Xcode.

## Debug logging

`logEvent(_:)` (`Extensions/EffectLog.swift`) prints a `[LOG]`-tagged, timestamped diagnostic
line. Intentionally left in place rather than stripped after debugging — do not remove call
sites in a cleanup pass unless explicitly asked.
