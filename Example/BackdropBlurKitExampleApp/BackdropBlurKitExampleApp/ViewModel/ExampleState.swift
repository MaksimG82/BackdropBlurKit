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

    // MARK: - Initialization

    init() {
        selectedTab = ExampleBarItem.allItems[0]
    }
}
