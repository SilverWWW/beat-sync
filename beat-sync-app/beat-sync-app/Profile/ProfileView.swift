//
//  ProfileView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        
        VStack {
            
            Text.BS("Welcome, Will",
                    size: 34,
                    color: BSColor.beatsyncDark,
                    bold: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .top], 12)
            
            Text.BS("Ready to run?",
                    size: 24,
                    color: BSColor.beatsyncDark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 18)
            .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.2, d: 1, tx: 0, ty: 0))
            
            
            Spacer()
           
            Button(action: viewModel.clearUserData) {
                Text.BS("Clear User Data", color: .gray, underline: true)
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
                
}

#Preview {
    ProfileView()
}
