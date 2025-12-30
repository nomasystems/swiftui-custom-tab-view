//
//  CustomTabView.swift
//  
//
//  Created by Niccolò Fontana on 19/01/23.
//

import SwiftUI

/// A SwiftUI component that enables users to create a customizable TabView with a user-defined TabBar.
/// This component allows developers to specify a custom TabBar view and associate it with specific tabs.
///
/// ## Example Usage
/// ```swift
/// @State private var selection: String = "Tab1"
///
/// CustomTabView(
///    tabBarView: { geometry in MyCustomTabBar(selection: $selection) },
///    tabs: ["Tab1", "Tab2", "Tab3"],
///    selection: selection
/// ) {
///    // Content for each tab
///    Text("Content for Tab1")
///
///    Text("Content for Tab2")
///
///    Text("Content for Tab3")
/// }
/// ```
/// 
/// - Parameters:
///   - tabBarView: A function that returns a view that will serve as the tab bar. The geometry will be that of the entire tab bar container, and can be used to customize the tab bar based on, for example, the current safe area insets.
///   - tabs: An array of values conforming to `Hashable` that represent the tabs. The order of tabs in this array **must** be reflected in the TabBar view provided.
///   - selection: The currently selected tab.
///   - content: A closure that provides the content for each tab. The order and number of elements in the closure **must** match the `tabs` parameter.
public struct CustomTabView<SelectionValue: Hashable, TabBarView: View, Content: View>: View {
    
    // Tabs
    let selection: SelectionValue
    private let tabIndices: [SelectionValue: Int]
    
    // TabBar
    let tabBarView: (GeometryProxy) -> TabBarView

    // Content
    let content: Content
    
    public init(tabBarView: @escaping (GeometryProxy) -> TabBarView, tabs: [SelectionValue], selection: SelectionValue, @ViewBuilder content: () -> Content) {
        self.tabBarView = tabBarView
        self.selection = selection
        self.content = content()
        
        var tabIndices: [SelectionValue: Int] = [:]
        for (index, tab) in tabs.enumerated() {
            tabIndices[tab] = index
        }
        self.tabIndices = tabIndices
    }
    
    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            Group(subviews: content) { subviews in
                _TabBarLayoutView(
                    tabBarView: tabBarView,
                    selectedTabIndex: tabIndices[selection] ?? 0,
                    subviews: subviews
                )
            }
        } else {
            _VariadicView.Tree(
                _VariadicViewLayout<TabBarView>(
                    tabBarView: tabBarView,
                    selectedTabIndex: tabIndices[selection] ?? 0
                )
            ) {
                content
            }
        }
    }
}

private struct _VariadicViewLayout<TabBarView: View>: _VariadicView_UnaryViewRoot {
    let tabBarView: (GeometryProxy) -> TabBarView
    let selectedTabIndex: Int
    
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        _TabBarLayoutView(tabBarView: tabBarView, selectedTabIndex: selectedTabIndex, subviews: children)
    }
}

struct _TabBarLayoutView<TabBarView: View, Subviews>: View where Subviews: RandomAccessCollection, Subviews.Element: View & Identifiable, Subviews.Index == Int {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    @Environment(\.tabBarEdge) private var tabBarEdge: Edge

    @State private var tabBarVisibility: [Int: TabBarVisibility] = [:]
    @State private var tabBarHeight: CGFloat = 0

    let tabBarView: (GeometryProxy) -> TabBarView
    let selectedTabIndex: Int
    let subviews: Subviews

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: tabBarAlignment, content: {
                contentView(
                    subviews: subviews,
                    additionalSafeAreaInsets: .init(),
                    additionalSafeAreaInsetsTabBarVisible: additionalSafeAreaInsetsTabBarVisible
                )
                #if canImport(UIKit)
                .ignoresSafeArea(.all, edges: .vertical)
                #endif
                tabBarView(proxy)
                    .opacity(tabBarVisibility[selectedTabIndex] == .hidden ? 0 : 1)
                    .onPreferenceChange(TabBarTopForSafeAreaKey.self) {
                        if let anchor = $0 {
                            tabBarHeight = max(0, -(proxy[anchor].y - proxy.size.height))
                        }
                    }
            })
        }
    }

    private func contentView(subviews: Subviews, additionalSafeAreaInsets: EdgeInsets, additionalSafeAreaInsetsTabBarVisible: EdgeInsets) -> some View {
        #if canImport(UIKit)
        return UITabBarControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            tabBarVisibility: $tabBarVisibility,
            controlledViews: subviews,
            additionalSafeAreaInsets: additionalSafeAreaInsets,
            additionalSafeAreaInsetsTabBarVisible: additionalSafeAreaInsetsTabBarVisible
        )
        #elseif canImport(AppKit)
        return NSTabViewControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            controlledViews: subviews.map { NSHostingController(rootView: $0) }
        )
        #endif
    }

    private var additionalSafeAreaInsetsTabBarVisible: EdgeInsets {
        switch tabBarEdge {
        case .top:
            .init(top: tabBarHeight, leading: 0, bottom: 0, trailing: 0)
        case .leading:
            .init(top: 0, leading: tabBarHeight, bottom: 0, trailing: 0)
        case .bottom:
            .init(top: 0, leading: 0, bottom: tabBarHeight, trailing: 0)
        case .trailing:
            .init(top: 0, leading: 0, bottom: 0, trailing: tabBarHeight)
        }
    }

    private var tabBarAlignment: Alignment {
        switch tabBarEdge {
        case .top:
            .top
        case .leading:
            .leading
        case .bottom:
            .bottom
        case .trailing:
            .trailing
        }
    }
}
