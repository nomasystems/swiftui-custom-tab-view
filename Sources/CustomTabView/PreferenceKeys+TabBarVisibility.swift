import SwiftUI

public enum TabBarVisibility: Equatable {
    case visible(Animation? = nil)
    case hidden(Animation? = nil)

    var animation: Animation? {
        switch self {
        case .visible(let animation),
                .hidden(let animation):
            animation
        }
    }

    var isVisible: Bool {
        if case .visible = self {
            return true
        }
        return false
    }
}

public extension View {
    func tabBarVisibility(_ visibility: TabBarVisibility) -> some View {
        modifier(TabBarVisibilityModifier(visibility: visibility))
    }
}

struct TabBarVisibilityKey: PreferenceKey {
    static var defaultValue: TabBarVisibility { .visible() }

    static func reduce(value: inout TabBarVisibility, nextValue: () -> TabBarVisibility) {
        value = switch (value, nextValue()) {
        case (.visible, .hidden(let animation)): .hidden(animation)
        case (.hidden(let animation), .visible): .hidden(animation)
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
