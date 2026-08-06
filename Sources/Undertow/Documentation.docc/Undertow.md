
# ``Undertow``

A live, performant backdrop visual-effects pipeline for SwiftUI, running entirely on the GPU.

## Overview

Undertow works like `UIVisualEffectView`, but across arbitrary scrolling/animating content and
multiple simultaneous effect targets. Apply an effect to a source view, mark any number of
descendant views as targets, and the effect reveals itself only behind those targets — moving
with them as content scrolls.

## Topics

### Applying effects

- ``SwiftUICore/View/effectSource(configuration:)``
- ``SwiftUICore/View/effectTarget(cornerRadius:)``
- ``SwiftUICore/View/effectCoordinator()``

### Effects

- ``Effect``
