//
//  SessionView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct SessionView: View {
    
    @StateObject var userViewModel = UserViewModel.shared
    @StateObject var viewModel = SessionViewViewModel()

    
    let myColor = Color(red: 29/255, green: 185/255, blue: 84/255)

    var body: some View {
        VStack {
            
     
            Picker("Now playing from:", selection: $viewModel.currentPlaylist) {
                ForEach(viewModel.allUserPlaylists, id: \.self) { playlist in
                    Text(playlist.name).tag(playlist as SpotifyPlaylistResponse.SpotifyPlaylist?)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: viewModel.currentPlaylist) { newValue in
                if let pID = newValue?.id {
                    viewModel.playShuffledPlaylist(playlistId: pID)
                }
            }
            .accentColor(myColor)
            
            
            
            
            // Song Information
            VStack (spacing: 10) {
                GeometryReader { geometry in
                    Text(viewModel.currentSong)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .frame(width: geometry.size.width)
                        .font(.system(size: 50))
                }

                Text(viewModel.currentArtist)
                    .font(.headline)
            }

            if let url = URL(string: viewModel.currentImgURL) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 300)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.bottom)
            } else {
                Text("No image available")
            }
            


            HStack {
                // Previous Song Button
                Button(action: {
                    viewModel.previousSong()
                }) {
                    Image(systemName: "backward.end.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(myColor)
                }
                .padding(20)
                
                // Play/Pause Button
                Button(action: {
                    viewModel.playback()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(myColor)
                }

                // Next Song Button
                Button(action: {
                    viewModel.nextSong()
                }) {
                    Image(systemName: "forward.end.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(myColor)
                }
                .padding(20)
            }
            
            BSButton(title: "Re-Sync Up", color: myColor) {
                
    
                viewModel.reSyncUp()
                // viewModel.calculateTargetBPM() // recalculate the right bpm
                // viewModel.nextSong() // skip to the next song which should fit that bpm
            }
            .frame(width: 320, height: 75)
            
            
            Text("Target BPM: \(viewModel.currentBPM)")
                .foregroundColor(myColor)
                .bold()
            
            
            
            Spacer()
            
            NavigationLink(destination: DashboardView()
                .navigationBarBackButtonHidden(true)) {
                                Text("End Session")
                                    .padding()
                                    .foregroundColor(.red)
                                    .font(.system(size:20))
                            }
        }
        //.navigationBarTitle("Now Playing", displayMode: .inline)
        .onAppear {
            viewModel.fetchUserPlaylists()
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
