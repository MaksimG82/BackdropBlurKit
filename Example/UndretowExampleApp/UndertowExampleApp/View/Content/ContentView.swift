//
//  ContentView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI
import Undertow
import BarKit

struct ContentView: View {

    // MARK: - Property Wrappers

    @State private var viewModel = ExampleViewModel()

    /// Shared bar-visibility state — written by any descendant's `.hideBar(id:)` to collapse
    /// the tab bar on deeper screens, read here to decide whether to render it at all.
    @State private var barVisibility: [String: Visibility] = [:]

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            contentRouter
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if barVisibility["tabBar"] != .hidden {
                FloatingTabBarView(
                    items: viewModel.state.tabBarItems,
                    selected: selectedItem
                )
            }
        }
        .registerBarVisibility($barVisibility)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - Subviews

private extension ContentView {

    /// Routes to the appropriate screen based on the selected tab.
    @ViewBuilder
    var contentRouter: some View {
        switch viewModel.state.selectedTab.type {
        case .info:
            InfoScreen()
        case .gpu:
            ExamplesScreen(viewModel: viewModel)
        }
    }

    /// A binding that bridges `ExampleBarItem` selection to `ExampleIntent`.
    var selectedItem: Binding<ExampleBarItem> {
        Binding(
            get: { viewModel.state.selectedTab },
            set: { viewModel.send(.selectTab($0)) }
        )
    }
}




