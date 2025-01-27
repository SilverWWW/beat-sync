//
//  HomeView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                GradientRippleButton(action: viewModel.startListening)
            }
        }
        .fullScreenCover(isPresented: $viewModel.isModalPresented) {
            SessionView(closeSessionCompletion: viewModel.dismissModal)
        }
    }
    
}

#Preview {
    HomeView()
}
