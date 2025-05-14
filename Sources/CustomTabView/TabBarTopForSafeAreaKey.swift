import SwiftUI

public struct TabBarTopForSafeAreaKey: PreferenceKey {
    public static var defaultValue: Anchor<CGPoint>? { nil }

    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}
