//
//  ProfileView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var userViewModel = UserViewModel.shared

    
    let myColor = Color(red: 29/255, green: 185/255, blue: 84/255)
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(myColor)
                        .frame(width: UIScreen.main.bounds.width * 3,
                               height: 200)
                    
                }
                .offset(y: -200)
                
                if !userViewModel.isLoading {
                    VStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .foregroundColor(myColor)
                        
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text("Name:")
                                    .bold()
                                Text(userViewModel.user?.name ?? "Unknown")
                            }
                            .padding()
                            HStack {
                                Text("Email:")
                                    .bold()
                                Text(userViewModel.user?.email ?? "Unknown")
                            }
                            .padding()
                            HStack {
                                Text("Date joined :")
                                    .bold()
                                Text(userViewModel.user != nil ? "\(Date(timeIntervalSince1970: userViewModel.user!.joined).formatted(date: .abbreviated, time: .shortened))" : "Unknown")
                            }
                            .padding()
                        }
                    }
                    .offset(y: -150)
                    
                    VStack {
                        
                        Spacer()
                        
                        // Link Spotify Account Button
                        if !userViewModel.isSpotifyLinked {
                            // show link button if not linked
                            
                            BSButton(title: "Link Spotify Account", color: myColor) {
                                userViewModel.linkSpotifyAccount()
                            }
                            .frame(height:70)
            
                        } else {
                            Text("Your Spotify account is linked!")
                                .foregroundColor(myColor)
                                .bold()
                                .font(.system(size:20))
                        }
                        
                        
                        // Sign out button
                        BSButton(title: "Sign Out",
                                 color: .red) {
                            userViewModel.logout()
                        }
                        .frame(height: 70)
                    }
                } else {
                    ProgressView("Loading...")
                }
                Spacer()
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            userViewModel.fetchUser()
            
            if userViewModel.isSpotifyLinked {
                SpotifyTokenManager.shared.fetchTokenData { success in
                    if !success {
                        print("Could not fetch token data on profile switch")
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
