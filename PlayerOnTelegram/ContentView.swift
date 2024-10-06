//
//  ContentView.swift
//  PlayerOnTelegram
//
//  Created by  Max on 06.10.2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PlayerOnTelegramDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(PlayerOnTelegramDocument()))
}
