//
//  ContentView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI
import BackdropBlurKit
import BarKit

struct ContentView: View {

    // MARK: - Property Wrappers

    @State private var viewModel = ExampleViewModel()

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                contentRouter
            }

            FloatingTabBarView(
                items: viewModel.state.tabBarItems,
                selected: selectedItem
            )
        }
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
        case .examples:
            ExamplesScreen()
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




