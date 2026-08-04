//
//  ExamplesScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI
import BarKit

/// Catalog of interactive scenarios demonstrating BackdropBlurKit's behavior and limitations.
///
/// Selecting a scenario swaps the catalog for its detail view in place — there is no
/// `NavigationStack`/push transition, since capturing snapshots of views inside a push
/// transition has proven unreliable for this library's capture pipeline.
struct ExamplesScreen: View {

    // MARK: - Properties

    let viewModel: ExampleViewModel

    /// Restricts the catalog and routing to scenarios belonging to this section — `.layout`
    /// for the CPU tab, `.layerEffect` for the GPU tab.
    let section: ExampleSection

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            if let scenario = viewModel.state.selectedScenario {
                Group {
                    destination(for: scenario)
                    scenarioHeader(for: scenario)
                }
                .hideBar(id: "tabBar")
            } else {
                catalog
            }
        }
    }
}

// MARK: - Subviews

private extension ExamplesScreen {

    var catalog: some View {
        List {
            Section(section.rawValue) {
                ForEach(scenarios(in: section)) { scenario in
                    Button {
                        viewModel.send(.selectScenario(scenario))
                    } label: {
                        HStack {
                            Text(scenario.title)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    /// A minimal back control shown above the active scenario's content.
    func scenarioHeader(for scenario: ExampleScenario) -> some View {
        HStack(spacing: 8) {
            Button {
                viewModel.send(.dismissScenario)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }

            Text(scenario.title)
                .font(.headline)

            Spacer()
        }
        .padding()
    }

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
        case .fixedHeaderOffset:
            FixedHeaderOffsetView()
        case .multiTargetScroll:
            MultiTargetScrollView()
        case .layerEffectScroll:
            LayerEffectScrollView()
        case .layerEffectTargetsScroll:
            LayerEffectTargetsScrollView()
        case .multiTargetLayerEffectScroll:
            MultiTargetLayerEffectScrollView()
        }
    }
}

#Preview {
    ExamplesScreen(viewModel: ExampleViewModel(), section: .layout)
}
