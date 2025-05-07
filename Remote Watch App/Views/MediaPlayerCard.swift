//
//  MediaPlayerCard.swift
//  Remote
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI

struct MediaPlayerCard: View {
    let player: MediaPlayer
    
    var body: some View {
        HStack {
            // Your existing design, but expanded to fill width
            VStack(alignment: .leading) {
                Image(systemName: "tv")
                    .font(.system(size: 24))
                
                Text(player.name)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) 
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.vertical, 2)
    }
}


#Preview {
    MediaPlayerCard(player: MediaPlayer(entityId: "media_player.media_player_1", name: "Media Player 1 wlkhcdlwkhbckwjblkwbclkwjcbdlwk"))
}
