//
//  UITabBarControllerRepresentable.swift
//  
//
//  Created by Niccolò Fontana on 19/01/23.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

struct UITabBarControllerRepresentable<Subviews>: UIViewControllerRepresentable where Subviews: RandomAccessCollection, Subviews.Element: View & Identifiable, Subviews.Index == Int {
    let selectedTabIndex: Int
    @Binding var tabBarVisibility: [Int: TabBarVisibility]
    let controlledViews: Subviews
    let additionalSafeAreaInsets: EdgeInsets
    let additionalSafeAreaInsetsTabBarVisible: EdgeInsets

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            controlledViews.enumerated().map { index, view in
                UIHostingController(
                    rootView: view
                        .onPreferenceChange(TabBarVisibilityKey.self) { tabBarVisibility[index] = $0 }
                )
            },
            animated: false
        )
        tabBarController.selectedIndex = selectedTabIndex
        tabBarController.tabBar.isHidden = true
        if #available(iOS 18.0, *) {
            tabBarController.isTabBarHidden = true
        }
        return tabBarController
    }
    
    func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
        tabBarController.selectedIndex = selectedTabIndex
        tabBarController.viewControllers?.enumerated().forEach { index, vc in
            (vc as? UIHostingController)?.rootView = controlledViews[index]
                .onPreferenceChange(TabBarVisibilityKey.self) { tabBarVisibility[index] = $0 }
            let additionalSafeAreaInsets = tabBarVisibility[index] == .visible
                ? additionalSafeAreaInsetsTabBarVisible
                : self.additionalSafeAreaInsets
            vc.additionalSafeAreaInsets = .init(
                top: additionalSafeAreaInsets.top,
                left: additionalSafeAreaInsets.leading,
                bottom: additionalSafeAreaInsets.bottom,
                right: additionalSafeAreaInsets.trailing
            )
        }
    }
}

#endif
