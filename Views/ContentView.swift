//
//  ContentView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ContentViewViewModel()
    let myColor = Color(red: 29/255, green: 185/255, blue: 84/255)
    
    var body: some View {
        
        if viewModel.isSignedIn, !viewModel.currentUserID.isEmpty {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                        
                    }
            }
        } else {
            LoginView()
        }    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
