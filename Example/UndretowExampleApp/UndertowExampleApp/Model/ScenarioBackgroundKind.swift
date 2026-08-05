//
//  ScenarioBackgroundKind.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//


/// A parameter-less identifier for each `ScenarioBackground` case, used to drive the background
/// picker in a scenario's settings sheet — same rationale as `LayerEffectKind` for
/// `LayerEffectConfiguration`.
enum ScenarioBackgroundKind: String, CaseIterable, Identifiable {
    case checkerboard
    case photo

    var id: Self { self }

    /// The display name shown in the background picker.
    var title: String {
        switch self {
        case .checkerboard: "Checkerboard"
        case .photo: "Photo"
        }
    }

    /// The kind backing a given background, for initializing the picker's selection from an
    /// existing `ScenarioBackground`.
    init(_ background: ScenarioBackground) {
        switch background {
        case .checkerboard: self = .checkerboard
        case .photo: self = .photo
        }
    }

    /// The default parameter values used when this kind is first selected in the background
    /// picker.
    var defaultBackground: ScenarioBackground {
        switch self {
        case .checkerboard: .defaultCheckerboard
        case .photo: .defaultPhoto
        }
    }

    /// The kinds offered in the background picker. `.photo` is excluded for scenarios whose
    /// background scrolls — see `ScenarioBackground.photo`'s doc comment for why.
    static func availableKinds(forMovingBackground isMoving: Bool) -> [ScenarioBackgroundKind] {
        isMoving ? [.checkerboard] : allCases
    }
}
