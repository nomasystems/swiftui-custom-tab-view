import SwiftUI

public enum TabBarVisibility {
    case visible
    case hidden
}

public extension View {
    func tabBarVisibility(_ visibility: TabBarVisibility) -> some View {
        modifier(TabBarVisibilityModifier(visibility: visibility))
    }
}

struct TabBarVisibilityKey: PreferenceKey {
    static var defaultValue: TabBarVisibility { .visible }

    static func reduce(value: inout TabBarVisibility, nextValue: () -> TabBarVisibility) {
        value = switch (value, nextValue()) {
        case (.visible, .hidden): .hidden
        case (.hidden, .visible): .hidden
        case (_, let newValue): newValue
        }
    }
}

private struct TabBarVisibilityModifier: ViewModifier {
    let visibility: TabBarVisibility

    func body(content: Content) -> some View {
        content.preference(key: TabBarVisibilityKey.self, value: visibility)
    }
}
