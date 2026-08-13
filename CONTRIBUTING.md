# Contributing a new effect

Every effect in Undertow is the same shape: a Metal shader, a compiled `.metallib`, and a few
lines of Swift wiring it into the public API. This walks through adding one from scratch, using
`GaussianBlur` as the reference example throughout.

## 1. Fork the repo

Standard GitHub fork + branch workflow.

## 2. Write the shader

Add `Shaders/<Name>.metal`. Undertow's shaders run through SwiftUI's `.layerEffect` pipeline, so
the entry point needs the `[[ stitchable ]]` attribute and the `SwiftUI::Layer` sampling API —
see `Shaders/GaussianBlur.metal` for a working example.

If you're new to SwiftUI shaders, start here:

- [Hacking with Swift — How to add Metal shaders to SwiftUI views using layer effects](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects)
- Apple docs: [`layerEffect(_:maxSampleOffset:isEnabled:)`](https://developer.apple.com/documentation/swiftui/view/layereffect(_:maxsampleoffset:isenabled:)), [`Shader`](https://developer.apple.com/documentation/swiftui/shader), [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)

Most of Undertow's existing shaders are adapted from [Inferno](https://github.com/twostraws/Inferno)
by Paul Hudson — a good source of ready-made SwiftUI-shader examples.

## 3. Compile it

```
./Scripts/compileShader.sh <Name>
```

Requires the Metal toolchain (Xcode). Produces `<Name>-iphoneos.metallib` and
`<Name>-iphonesimulator.metallib` in `Sources/Undertow/Metal/`. Commit both `.metallib` files
together with the `.metal` source — consumers of the package build from the compiled libraries,
not the shader source.

## 4. Add a case to `Effect`

In `Sources/Undertow/Core/Effect.swift`, add a case for your effect with its parameters, doc
comments included. If the effect needs a continuously updating time value to animate, add it to
the `isTimeBased` switch too.

## 5. Wire up the shader library

Add `Sources/Undertow/Extensions/ShaderLibrary+<name>Library.swift`, loading your compiled
`.metallib` from the bundle. Copy `ShaderLibrary+gaussianBlurLibrary.swift` and rename.

## 6. Add the `View` extension

Add `Sources/Undertow/Extensions/View+<name>Effect.swift`, applying your shader via
`.layerEffect`. Copy `View+gaussianBlurEffect.swift` as a starting point.

## 7. Dispatch the new case

In `EffectSourceViewModifier.swift`, add your case to the `switch` in `appliedEffect(to:boundingRect:time:)`,
calling the `View` extension from step 6.

## 8. Document it

Every public symbol needs a `///` doc comment (`- Parameters:` / `- Returns:` where applicable).
If you added public API, update the Topics list in `Sources/Undertow/Documentation.docc/Undertow.md`.

## 9. Add it to the example app (optional, appreciated)

The example app already has two scenarios — moving background/fixed panels and moving
panels/fixed background — each with a settings sheet that lets you pick an effect and tune its
parameters live. Both scenarios pick up a new effect automatically once it's in `EffectKind`, but
the parameter sliders don't — two things to add in
`Example/UndertowExampleApp/View/Reusable/EffectSettingsSheet.swift`:

- A case in `EffectKind` (`Example/UndertowExampleApp/Model/EffectKind.swift`): a `title` and a
  `defaultConfiguration`.
- A `<name>Section` in `EffectSettingsSheet` with a `SettingSlider` per parameter, plus a
  `Binding` for each that pattern-matches your `Effect` case to read/write it. Copy
  `gaussianBlurSection` and its two bindings as a template, and add your case to the
  `effectParameters` switch.

## 10. Open a PR
