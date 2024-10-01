//
//  RegistrationView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject var viewModel = RegisterViewViewModel()
    
    var body: some View {
    
        
        VStack {
            
            // Header
            HeaderView(title: "Register",
                       subtitle: "Sync Up Today",
                       angle: -15)
            
            // Register Fields
            Form {
                TextField("Your Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                BSButton(title: "Register",
                         color: Color(red: 29/255, green: 185/255, blue: 84/255)
                ) {
                    viewModel.register()
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
            }
            
            // Return to login
            VStack {
                
                NavigationLink("Login") {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
                .foregroundColor(Color(red: 29/255, green: 185/255, blue: 84/255))
            }
            .padding(30)
            
            Spacer()
            
            
        }
                
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
