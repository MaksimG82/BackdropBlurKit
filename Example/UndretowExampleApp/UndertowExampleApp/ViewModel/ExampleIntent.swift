//
//  ExampleIntent.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 01.07.26.
//


/// Defines all possible user actions that can modify the demo app state.
enum ExampleIntent {

    /// Changes the currently selected tab.
    case selectTab(ExampleBarItem)

    /// Replaces the GPU tab's `NavigationStack` path wholesale — driven by the stack's own
    /// `path` binding, so push (via `NavigationLink(value:)`) and pop (back button, back-swipe)
    /// both flow through this single intent.
    case setGPUPath([ExampleScenario])
}