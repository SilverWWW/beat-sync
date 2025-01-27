//
//  HomeViewModel.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var isModalPresented: Bool = false
    
    func startListening() -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showModal()
        }
    }
    
    func showModal() {
        isModalPresented = true
    }

    func dismissModal() {
        isModalPresented = false
    }
}
