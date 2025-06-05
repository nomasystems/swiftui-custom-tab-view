//
//  ExampleView.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

struct ExampleView: View {
    @State private var selectedTab: ExampleTab = .home

    private var tabBarView: some View {
        BottomFloatingTabBarView(selection: $selectedTab, onTabSelection: { tab in
            print("Maybe send some analytics here")
        })
    }

    var body: some View {
        CustomTabView(tabBarView: tabBarView, tabs: ExampleTab.allCases, selection: selectedTab) {
            #if os(iOS)
            NavigationView {
                ScrollView {
                    ZStack {
                        Color.clear
                        Text("Home")
                            .padding(.top, 100)
                    }
                }
                .background(Color.brown)
                .navigationTitle("Home")
            }
            #else
                Text("Home")
            #endif

            NavigationView {
                List {
                    ForEach((0..<20).map { $0 }, id: \.self) { item in
                        let hidesTabBar = item == 0
                        NavigationLink(
                            destination: destination(
                                item: item,
                                tabBarVisibility: hidesTabBar ? .hidden : .visible
                            )
                        ) {
                            Text("Go to \(item)" + (hidesTabBar ? " (hides tab bar)" : ""))
                        }
                    }
                }
                #if os(iOS)
                .navigationBarTitle("Explore")
                #endif
            }

            #if os(iOS)
            NavigationView {
                Text("Favourites")
                    .navigationBarTitle("Favourites")
            }
            #else
                Text("Favourites")
            #endif

            #if os(iOS)
            NavigationView {
                Text("Other")
                    .navigationBarTitle("Other")
            }
            #else
                Text("Other")
            #endif
        }
        #if os(iOS)
        .tabBarEdge(.bottom)
        .navigationViewStyle(.stack)
        #endif
    }

    @ViewBuilder private func destination(
        item: Int,
        tabBarVisibility: TabBarVisibility
    ) -> some View {
        NavigationLink(
            destination: nestedDestination()
        ) {
            ZStack {
                Color.red.ignoresSafeArea(.all)
                Text("Destination \(item)")
            }
            .tabBarVisibility(tabBarVisibility)
        }
    }

    @ViewBuilder private func nestedDestination() -> some View {
        ZStack {
            Color.red.ignoresSafeArea(.all)
            Text("Nested destination")
        }
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
