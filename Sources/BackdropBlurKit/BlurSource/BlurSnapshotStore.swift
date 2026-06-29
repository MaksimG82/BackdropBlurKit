//
//  BlurSnapshotStore.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 26.06.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds processed blur snapshots keyed by configuration.
final class BlurSnapshotStore {
    /// The latest processed snapshots, updated by `BlurSource` and observed by `BlurTargetViewModifier`.
    var snapshots: [BlurConfiguration: UIImage] = [:]

    /// The minimal rect enclosing all `.blurred()` target frames, in local coordinates of `BlurSource`.
    /// A value of `.zero` indicates no targets are registered yet — triggers full snapshot fallback.
    var captureRect: CGRect = .zero {
        didSet {
            guard oldValue != captureRect else { return }
            onCaptureRectChanged?()
        }
    }
    
    /// Called when `captureRect` changes — signals `BlurSource` to re-capture immediately.
    var onCaptureRectChanged: (() -> Void)?
}
