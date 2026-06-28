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
}
