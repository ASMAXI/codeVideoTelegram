//
//  PlayerOnTelegramApp.swift
//  PlayerOnTelegram
//
//  Created by  Max on 06.10.2024.
//

import SwiftUI

@main
struct PlayerOnTelegramApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PlayerOnTelegramDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
