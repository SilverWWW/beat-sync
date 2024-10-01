//
//  DashboardView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct DashboardView: View {
    
    @StateObject var userViewModel = UserViewModel.shared
    @StateObject var viewModel = DashboardViewViewModel()
    let myColor = Color(red: 29/255, green: 185/255, blue: 84/255)
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(Color(red: 29/255, green: 185/255, blue: 84/255))
                        .frame(width: UIScreen.main.bounds.width * 3,
                               height: 200)
                    
                }
                .offset(y: -200)
                
                
                
                Spacer()
                
                if !userViewModel.isLoading {
                    
                    if userViewModel.isSpotifyLinked {
                        NavigationLink(destination: SessionView()
                            .navigationBarBackButtonHidden(true)) {
                                Text("Start Listening")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color(red: 29/255,
                                                      green: 185/255,
                                                      blue: 84/255))
                                    .cornerRadius(10)
                                    .font(.system(size:20))
                                    .bold()
                                    .offset(y: -10)
                            }
                    } else {
                        Text("Please link Spotify account under the Profile tab to begin listening.")
                            .foregroundColor(.red)
                            .frame(width: 300)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                    }
                } else {
                    ProgressView("Loading...")
                }
                                
                                
                                
            }
            .navigationTitle("Beat Sync")
        }
        .onAppear {
            userViewModel.fetchUser()
            
            if userViewModel.isSpotifyLinked {
                SpotifyTokenManager.shared.fetchTokenData { success in
                    if !success {
                        print("Could not fetch token data on dashboard switch")
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
