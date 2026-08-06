# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This library is published.

## What this is

Undertow is a Swift Package (iOS 17+, Swift 6 language mode) providing a live, performant
backdrop visual-effects pipeline for SwiftUI — similar to `UIVisualEffectView`, but working
across arbitrary scrolling/animating content and multiple simultaneous effect targets. Ships as
a library target (`Sources/Undertow`) plus an example iOS app (`Example/UndertowExampleApp`)
that consumes the package locally. Effects run via SwiftUI's shader modifiers
(`.layerEffect`/`.distortionEffect`/`.colorEffect`) — see `Effect` for the full list.

## Architecture

Understanding the library requires following data through three cooperating pieces:

1. **`effectCoordinator()`** (`EffectCoordinator/EffectCoordinatorModifier.swift`) — applied once,
   near the root of an effect subtree. Owns the shared `MaskStore` and injects it into the
   environment (`\.maskStore`), collecting `Set<TargetMask>` from all descendant
   `.effectTarget()` views via `EffectTargetFramePreferenceKey`.

2. **`effectSource()`** (`Extensions/View+effectSource.swift` → `EffectSourceViewModifier`,
   `EffectSource/`) — applied to the content the effect should run on. Reads `MaskStore` from
   the environment and masks the effect to the collected target masks.

3. **`effectTarget()`** (`Extensions/View+effectTarget.swift` → `EffectTargetViewModifier`,
   `EffectTarget/`) — applied to any view that should reveal the effect behind it. Reports its
   frame and corner radius via `EffectTargetFramePreferenceKey`. The target's own background
   must be transparent — the effect is revealed through it, not drawn on top of it.

One source drives exactly one `Effect` — there's no per-target override or environment-inherited
default.

## Typical usage shape

See `Example/UndertowExampleApp/View/Screens/MovingBackgroundFixedPanelsView.swift` for a
working reference. `effectCoordinator()` must wrap both the `effectSource()` and any
`.effectTarget()` views for the environment plumbing to connect them.

## Documentation

All public and internal types, properties, and functions must have DocC-style doc comments
(`///`). Use `- Parameters:` and `- Returns:` where applicable. No exceptions for "obvious"
declarations — every declaration gets a doc comment. Keep comments concise.

Avoid inline comments in code bodies unless something is genuinely non-obvious — the result of
trial and error, a non-trivial rationale, or a gotcha a reader can't derive from the code itself.
Otherwise, prefer making the code self-explanatory over commenting it.

Adding, removing, or renaming a public symbol? Update `Sources/Undertow/Documentation.docc/Undertow.md`'s
Topics list to match.

## Metal shaders

Changed a `.metal` file (in `/Shaders`)? Run `Scripts/compileShader.sh <ShaderName>` — regenerates
its `iphoneos`/`iphonesimulator` `.metallib` pair into `Sources/Undertow/Metal/`. Run once per
shader; commit the regenerated `.metallib`s with the change.

`Sources/Undertow/Metal/` holds only compiled `.metallib`s, bundled as package resources, so
consumers don't need the Metal toolchain to build the package.

## Build policy

NEVER run `swift build`, `swift test`, or `xcodebuild` — building and testing is the user's
responsibility, done manually in Xcode.

Don't suggest running the example app on a simulator — shaders fall back to CPU there and run
far slower than on device. Always test on a real device.
