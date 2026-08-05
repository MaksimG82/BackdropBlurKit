//
//  EnvironmentValues.swift
//  Undertow
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

extension EnvironmentValues {
    /// The shared target-frame store distributed by the nearest ancestor `effectCoordinator`.
    @Entry var effectTargetStore: EffectTargetStore? = nil
}
