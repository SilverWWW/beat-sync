//
//  SessionView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/20/25.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject private var viewModel: SessionViewModel
    
    private let horizontalPadding = CGFloat(24)
    
    init(closeSessionCompletion: @escaping () -> Void) {
        viewModel = SessionViewModel(closeSessionCompletion: closeSessionCompletion)
    }
        
    var body: some View {
        
        ZStack {
            uninterruptedView
                .blur(radius: viewModel.spotifyIsAsleep ? 10 : 0)
                .overlay(
                    viewModel.spotifyIsAsleep ? Color.black.opacity(0.3) : Color.clear
                )
                .animation(.easeInOut, value: viewModel.spotifyIsAsleep)
                .allowsHitTesting(!viewModel.spotifyIsAsleep)
            
            if viewModel.spotifyIsAsleep {
                VStack {
                    Text.BS("Spotify is asleep", size: 24, color: BSColor.beatsyncDark)
                    
                    Button(action: viewModel.start) {
                        Text.BS("Wake it up!", size: 24, color: .white, bold: true)
                            .padding(8)
                            .background(BSColor.beatsyncDark)
                            .cornerRadius(8)
                    }
                }
                .frame(width: 300, height: 150)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(BSColor.beatsyncDark, lineWidth: 4)
                )
                .cornerRadius(12)
                .opacity(viewModel.spotifyIsAsleep ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: viewModel.spotifyIsAsleep)
            }
        }
        .onAppear {
            viewModel.start()
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            SyncView(closeSyncView: viewModel.closeSyncSheet, didMeasureBPM: viewModel.didMeasureBPM)
            .interactiveDismissDisabled(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
    
    var uninterruptedView: some View {
        VStack {
                        
            closeSession
                .padding(.horizontal, horizontalPadding)
            
            Spacer()
            
            playbackInfo
                .padding(.horizontal, horizontalPadding)
                .frame(maxHeight: 500)
            
            Spacer()
            
            syncUpButton
                .padding(.horizontal, horizontalPadding)
            
            Spacer()
            
            playbackControls
                .padding(.horizontal, horizontalPadding * 2)
                .padding(.bottom, 24)

        }
    }
            
    var closeSession: some View {
        HStack {
            Spacer()
            Button(action: viewModel.closeSession) {
                Image.BS(systemName: "xmark", color: BSColor.beatsyncDark)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var playbackInfo: some View {
        VStack(spacing: 4) {
            
            // song info
            HStack {
                HStack {
                    Image.BS(systemName: "chevron.down", color: BSColor.beatsyncGrey)
                        .frame(width: 10, height: 10)
                    
                    Text.BS("Playing from: \(viewModel.songContext)", color: BSColor.beatsyncDarkGrey)
                        .lineLimit(1)
                }
                .frame(maxWidth: UIScreen.main.bounds.width - horizontalPadding * 2 - 100, alignment: .leading)
                .padding(.leading, 4)
                
                Spacer()
                
                Text.BS("BPM: 110", color: BSColor.beatsyncDarkGrey)
                    .frame(alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            
            // song art
            if let image = viewModel.currentImage {
                Image.BS(uiImage: image)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.width - horizontalPadding * 2)
                    
            } else {
                ZStack(alignment: .center) {
                    BSColor.beatsyncDarkGrey
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.width - horizontalPadding * 2)
                    
                    Image.BS(systemName: "music.note", color: BSColor.beatsyncGrey)
                        .frame(width: 100, height: 100)
                }
            }
            
            // song title / artist
            VStack(alignment: .leading, spacing: 4) {
                Text.BS(viewModel.currentTrack?.name ?? "Unknown Track", size: 24, color: BSColor.beatsyncDarkGrey)
                    .lineLimit(1)
                Text.BS(viewModel.currentTrack?.artist.name ?? "Unknown Artist", size: 12, color: BSColor.beatsyncDarkGrey)
                    .lineLimit(1)
            }
            .padding(.leading, 2)
            .frame(maxWidth:.infinity, alignment: .leading)
            
            // progress bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(BSColor.beatsyncDarkGrey)
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
                    .cornerRadius(2)
                Circle()
                    .fill(BSColor.beatsyncDarkGrey)
                    .frame(width: 8, height: 8)
                    .offset(x: CGFloat(viewModel.songProgress) * (UIScreen.main.bounds.width - horizontalPadding * 2) - 4)
            }
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
        }
    }
    
    var syncUpButton: some View {
        Button(action: viewModel.syncUpButton) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [BSColor.beatsyncGradientLight,
                                                        BSColor.beatsyncDark,
                                                        BSColor.beatsyncGradientDark]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8)
                
                HStack {
                    Image.BS(systemName: "music.note.list", color: .white)
                        .frame(height: 40)
                    Spacer()
                    Image.BS("sync-up", color: .white)
                        .frame(height: 40)
                    Spacer()
                    Image.BS(systemName: "music.note.list", color: .white)
                        .frame(height: 40)
                }
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(BSColor.beatsyncDarkGrey, lineWidth: 2)
            )
        }
    }
    
    var playbackControls: some View {
        VStack(spacing: 12) {
            
            // Buttons
            HStack {
                Button {
                    viewModel.skipPrevious()
                } label: {
                    Image.BS(systemName: "backward.fill", color: BSColor.beatsyncDarkGrey)
                        .frame(width: 45, height: 45)
                }
                
                Spacer()
                
                Button {
                    viewModel.pauseOrResume()
                } label: {
                    Image.BS(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill", color: BSColor.beatsyncDarkGrey)
                        .frame(width: 75, height: 75)
                }
                
                Spacer()
                
                Button {
                    viewModel.skipNext()
                } label: {
                    Image.BS(systemName: "forward.fill", color: BSColor.beatsyncDarkGrey)
                        .frame(width: 45, height: 45)
                }
            }
            
        }
    }
}

#Preview {
    SessionView(closeSessionCompletion: {})
}
