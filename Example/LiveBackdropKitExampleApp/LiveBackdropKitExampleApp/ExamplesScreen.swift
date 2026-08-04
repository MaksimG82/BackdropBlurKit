//
//  ExamplesScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI
import BarKit

/// Catalog of CPU-snapshot-pipeline (`.layout` section) scenarios, shown on the CPU tab.
///
/// Selecting a scenario swaps the catalog for its detail view in place — there is no
/// `NavigationStack`/push transition, since capturing snapshots of views inside a push
/// transition has proven unreliable for this pipeline. See `ExamplesScreenLayerEffect` for the
/// GPU tab's counterpart, which has no such limitation and uses a real `NavigationStack`.
struct ExamplesScreen: View {

    // MARK: - Properties

    let viewModel: ExampleViewModel

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
            Section {
                ForEach(scenarios) { scenario in
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
            } header: {
                catalogTitle
            }
        }
    }

    /// A large-title-style header mimicking `.navigationTitle`'s appearance, since this screen
    /// has no `NavigationStack` to provide one natively.
    var catalogTitle: some View {
        Text("CPU")
            .font(.largeTitle.bold())
            .foregroundStyle(.primary)
            .textCase(nil)
            .padding(.leading, -16)
            .padding(.bottom, 4)
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

    /// All scenarios belonging to the `.layout` section.
    var scenarios: [ExampleScenario] {
        ExampleScenario.allCases.filter { $0.section == .layout }
    }

    /// Routes to the detail view for the given scenario.
    @ViewBuilder
    func destination(for scenario: ExampleScenario) -> some View {
        switch scenario {
        case .movingBackgroundFixedPanel:
            MovingBackgroundFixedPanelView()
        case .fixedBackgroundOffsetFromTop:
            FixedBackgroundOffsetFromTopView()
        case .movingPanelsFixedBackground:
            MovingPanelsFixedBackgroundView()
        case .movingBackgroundFixedPanelsLayerEffect, .movingPanelsFixedBackgroundLayerEffect:
            // GPU-pipeline scenarios never appear in this tab's filtered `scenarios` list.
            EmptyView()
        }
    }
}

#Preview {
    ExamplesScreen(viewModel: ExampleViewModel())
}
