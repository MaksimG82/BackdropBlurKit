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

    /// The minimal rect enclosing all `.blurred()` target frames, in global/window coordinates.
    /// A value of `.zero` indicates no targets are registered yet — triggers full snapshot fallback.
    /// Consumers that crop against a view's own local layer space (e.g. `BlurSource`) must first
    /// subtract that view's own window origin.
    var captureRect: CGRect = .zero {
        didSet {
            // TEMP: captureRect wiring investigation — remove after verification
            print("TEMP captureRect wiring: t=\(CACurrentMediaTime()) captureRect didSet " +
                  "old=\(oldValue) new=\(captureRect) unchanged=\(oldValue == captureRect) " +
                  "hasCallback=\(onCaptureRectChanged != nil)")
            guard oldValue != captureRect else { return }
            onCaptureRectChanged?()
        }
    }
    
    /// Called when `captureRect` changes — signals `BlurSource` to re-capture immediately.
    var onCaptureRectChanged: (() -> Void)?
}
