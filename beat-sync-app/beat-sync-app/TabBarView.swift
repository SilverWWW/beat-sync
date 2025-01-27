//
//  TabBarView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import SwiftUI

struct TabBarView: View {
        
    @State private var opacity = 0.0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white // tab bar background appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "music.house.fill")
                    Text("Home")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
            
        }
        .tint(BSColor.beatsyncDark)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    TabBarView()
}
