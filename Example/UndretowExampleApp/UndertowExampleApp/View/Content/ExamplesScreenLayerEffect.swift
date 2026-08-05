//
//  ExamplesScreenLayerEffect.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI
import BarKit

/// Catalog of `.layerEffect`-pipeline scenarios, shown on the GPU tab.
///
/// Scenarios push via a real `NavigationStack`, giving native transitions, back-swipe, and a
/// system navigation bar to hang a settings toolbar button on later.
struct ExamplesScreenLayerEffect: View {

    // MARK: - Properties

    let viewModel: ExampleViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack(path: pathBinding) {
            catalog
                .navigationDestination(for: ExampleScenario.self) { scenario in
                    destination(for: scenario)
                        .navigationTitle(scenario.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .hideBar(id: "tabBar")
                }
        }
    }
}

// MARK: - Subviews

private extension ExamplesScreenLayerEffect {

    var catalog: some View {
        List {
            Section {
                ForEach(scenarios) { scenario in
                    NavigationLink(scenario.title, value: scenario)
                }
            } header: {
                catalogTitle
            }
        }
    }

    /// A large-title-style header matching `ExamplesScreen`'s `catalogTitle`, so both scenario
    /// catalogs look alike despite this screen sitting under a `NavigationStack` and that one
    /// not.
    var catalogTitle: some View {
        Text("GPU")
            .font(.largeTitle.bold())
            .foregroundStyle(.primary)
            .textCase(nil)
            .padding(.leading, -16)
            .padding(.bottom, 4)
    }

    /// All available scenarios.
    var scenarios: [ExampleScenario] {
        ExampleScenario.allCases
    }

    /// Routes to the detail view for the given scenario.
    @ViewBuilder
    func destination(for scenario: ExampleScenario) -> some View {
        switch scenario {
        case .movingBackgroundFixedPanelsLayerEffect:
            MovingBackgroundFixedPanelsLayerEffectView()
        case .movingPanelsFixedBackgroundLayerEffect:
            MovingPanelsFixedBackgroundLayerEffectView()
        }
    }
}

// MARK: - Navigation Path Binding

private extension ExamplesScreenLayerEffect {

    /// Bridges the `NavigationStack`'s own path binding to `ExampleIntent`, so both push (via
    /// `NavigationLink(value:)`) and pop (back button, back-swipe) flow through the view model.
    var pathBinding: Binding<[ExampleScenario]> {
        Binding(
            get: { viewModel.state.gpuPath },
            set: { viewModel.send(.setGPUPath($0)) }
        )
    }
}

#Preview {
    ExamplesScreenLayerEffect(viewModel: ExampleViewModel())
}
