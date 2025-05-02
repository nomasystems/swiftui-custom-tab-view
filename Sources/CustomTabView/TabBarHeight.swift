import SwiftUI

public struct TabBarBoundsForSafeAreaKey: PreferenceKey {
    public static var defaultValue: Anchor<CGRect>? { nil }

    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}
