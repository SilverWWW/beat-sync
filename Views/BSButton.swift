//
//  BSButton.swift
//  SpotifyBeatSync
//
//

import SwiftUI

struct BSButton: View {
    
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
        .padding(10)
    }
}

struct BSButton_Previews: PreviewProvider {
    static var previews: some View {
        BSButton(title: "Title",
                 color: Color.blue,
                 action: {() -> Void in}
        )
    }
}
