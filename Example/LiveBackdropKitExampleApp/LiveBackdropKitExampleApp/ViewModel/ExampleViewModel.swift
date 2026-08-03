//
//  ExampleViewModel.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import Observation

/// Manages the state and logic for the demo app.
@Observable
final class ExampleViewModel {

    // MARK: - State

    /// The single source of truth for the view.
    private(set) var state = ExampleState()

    // MARK: - Intent Handling

    /// Entry point for all user actions.
    func send(_ intent: ExampleIntent) {
        switch intent {
        case let .selectTab(item):
            state.selectedTab = item
        case let .selectScenario(scenario):
            state.selectedScenario = scenario
        case .dismissScenario:
            state.selectedScenario = nil
        }
    }
}



