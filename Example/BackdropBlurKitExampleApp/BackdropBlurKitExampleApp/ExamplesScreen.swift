//
//  ExamplesScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI

/// Catalog of interactive scenarios demonstrating BackdropBlurKit's behavior and limitations.
struct ExamplesScreen: View {

    var body: some View {
        List {
            ForEach(ExampleSection.allCases, id: \.self) { section in
                Section(section.rawValue) {
                    ForEach(scenarios(in: section)) { scenario in
                        NavigationLink(scenario.title) {
                            destination(for: scenario)
                        }
                    }
                }
            }
        }
        .navigationTitle("Examples")
    }
}

// MARK: - Helpers

private extension ExamplesScreen {

    /// Returns all scenarios belonging to the given section.
    func scenarios(in section: ExampleSection) -> [ExampleScenario] {
        ExampleScenario.allCases.filter { $0.section == section }
    }

    /// Routes to the detail view for the given scenario.
    @ViewBuilder
    func destination(for scenario: ExampleScenario) -> some View {
        switch scenario {
        case .simpleScroll:
            SimpleScrollView()
        }
    }
}

#Preview {
    NavigationStack {
        ExamplesScreen()
    }
}



