//
//  ExampleBarItem.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 29.06.26.
//

import Foundation
import BarKit

/// An `ExampleBarItem` demonstrates the tab bar navigation within the demo app.
/// Each tab represents a distinct showcase of the BackdropBlurKit library.
struct ExampleBarItem: BarItemProtocol {

    /// Internal types for the example app tabs.
    enum TabType: String, CaseIterable {
        case info, cpu, gpu
    }

    // MARK: - Properties

    /// The logical type of this tab, used as a stable identifier.
    var type: TabType

    /// The display title shown below the icon.
    var title: String {
        switch type {
        case .info: "Info"
        case .cpu: "CPU"
        case .gpu: "GPU"
        }
    }

    /// The icon displayed in the bar for this tab.
    var icon: BarIcon {
        switch type {
        case .cpu:
                .system("square.stack.fill")
        case .gpu:
                .system("wand.and.rays")
        case .info:
                .system("info.circle.fill")
        }
    }

    /// The visual style of the tab item (regular or prominent).
    var style: BarItemStyle = .regular

    /// A stable unique identifier derived from the title.
    var id: AnyHashable { title }
}

// MARK: - Default Set

extension ExampleBarItem {
    /// The default set of items covering all available example tabs.
    static var allItems: [ExampleBarItem] {
        TabType.allCases.map { .init(type: $0) }
    }
}


