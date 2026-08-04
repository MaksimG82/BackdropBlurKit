//
//  ExamplesScreen.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI

/// Catalog of interactive scenarios demonstrating BackdropBlurKit's behavior and limitations.
///
/// Selecting a scenario swaps the catalog for its detail view in place — there is no
/// `NavigationStack`/push transition, since capturing snapshots of views inside a push
/// transition has proven unreliable for this library's capture pipeline.
struct ExamplesScreen: View {

    // MARK: - Properties

    let viewModel: ExampleViewModel

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            if let scenario = viewModel.state.selectedScenario {
                destination(for: scenario)
                scenarioHeader(for: scenario)
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
            ForEach(ExampleSection.allCases, id: \.self) { section in
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
    ExamplesScreen(viewModel: ExampleViewModel())
}
