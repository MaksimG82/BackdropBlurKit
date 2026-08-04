//
//  ExampleState.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 01.07.26.
//


/// Represents the entire state of the demo app.
struct ExampleState {

    // MARK: - Navigation

    /// The list of tab items displayed in the bar.
    var tabBarItems: [ExampleBarItem] = ExampleBarItem.allItems

    /// The currently active tab.
    var selectedTab: ExampleBarItem

    // MARK: - Scenario Selection

    /// The scenario currently being viewed on the CPU tab, if any. `nil` means the catalog is
    /// shown. The CPU tab keeps its hand-rolled catalog/detail switch (no `NavigationStack`) —
    /// see `ExamplesScreen`'s doc comment for why.
    var selectedScenario: ExampleScenario?

    /// The `NavigationStack` path for the GPU tab — an ordered list of pushed scenarios.
    /// Unlike the CPU tab, the `.layerEffect` pipeline has no snapshot-in-push-transition
    /// limitation, so this tab uses real `NavigationStack` push/pop navigation.
    var gpuPath: [ExampleScenario] = []

    // MARK: - Initialization

    init() {
        selectedTab = ExampleBarItem.allItems[0]
    }
}
