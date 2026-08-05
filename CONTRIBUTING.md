# Contributing to Undertow

Undertow is early and the public API may still change — check open issues and discussions
before starting significant work, to avoid overlap.

## Getting started

1. Fork the repo and clone your fork.
2. Open `Example/UndertowExampleApp/UndertowExampleApp.xcodeproj` in Xcode to build and run
   against the local package.
3. Building and testing is done manually in Xcode — there's no separate build step to run first.

## Adding or changing a shader effect

1. Edit or add the `.metal` source in `/Shaders`.
2. Compile it with `Scripts/compileShader.sh <ShaderName>` (requires the Metal toolchain) —
   this regenerates the `iphoneos`/`iphonesimulator` `.metallib` pair into
   `Sources/Undertow/Metal/`.
3. Commit the regenerated `.metallib` files alongside your `.metal` change.
4. Add the corresponding `Effect` case and dispatch entry, following the shape of an existing
   effect.

## Code style

- All public and internal declarations need a DocC-style (`///`) doc comment. Keep them concise.
- Avoid inline comments unless something is genuinely non-obvious — prefer making the code
  self-explanatory.
- See `AGENTS.md` for more on the library's architecture and conventions.

## Submitting changes

Open a pull request with a clear description of what changed and why. Keep PRs focused — one
effect, fix, or improvement at a time is easier to review than a bundle of unrelated changes.
