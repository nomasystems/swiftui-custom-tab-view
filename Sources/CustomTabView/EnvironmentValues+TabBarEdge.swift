//
//  EnvironmentValues+TabBarEdge.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

public extension View {
    /// Sets the tab bar position to the view hierarchy it is applied to.
    ///
    /// Apply this modifier to the ``CustomTabView`` you have instantiated to change the default tab bar position.
    ///
    /// The default value is `Edge.bottom`.
    ///
    /// - Parameter value: The desired ``Edge``
    /// - Returns: A view that has the given value set in its environment.
    func tabBarEdge(_ value: Edge) -> some View {
        environment(\.tabBarEdge, value)
    }
}

private struct TabBarEdgeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Edge = .bottom
}

extension EnvironmentValues {
    var tabBarEdge: Edge {
        get { self[TabBarEdgeEnvironmentKey.self] }
        set { self[TabBarEdgeEnvironmentKey.self] = newValue }
    }
}
