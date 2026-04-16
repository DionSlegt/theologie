//
//  StudieApp.swift
//  Studie
//
//  Created by Mac Studio van Dion on 09/04/2026.
//

import SwiftUI

@main
struct StudieApp: App {
    @State private var dogmatiekStore = DogmatiekStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dogmatiekStore)
        }
    }
}
