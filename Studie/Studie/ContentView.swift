//
//  ContentView.swift
//  Studie
//
//  Created by Mac Studio van Dion on 09/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        DogmatiekRootView()
                    } label: {
                        Label("Dogmatiek", systemImage: "book.pages")
                    }
                    .accessibilityHint("Termen en definities voor dogmatiek.")
                } footer: {
                    Text("Meer vakken kun je later toevoegen.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Studie")
        }
    }
}

#Preview {
    ContentView()
        .environment(DogmatiekStore())
}
