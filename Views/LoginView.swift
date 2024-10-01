//
//  LoginView.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct LoginView: View {
    
    
    @StateObject var viewModel = LoginViewViewModel()
    
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                // Header
                HeaderView(title: "Spotify Beat Sync",
                           subtitle: "Run On Tempo",
                           angle: 15)
                
            
                
                // Login Fields
                Form {
                    
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    BSButton(title: "Login",
                             color: Color(red: 29/255, green: 185/255, blue: 84/255)
                    ) {
                        viewModel.login()
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    
                }                

                // Create Account
                VStack {
                    NavigationLink("Register New Account") {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    }
                    .foregroundColor(Color(red: 29/255, green: 185/255, blue: 84/255))
                }
                .padding(30)
                
                Spacer()
                
            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct ClearBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
    }
}
