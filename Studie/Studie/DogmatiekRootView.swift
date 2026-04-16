//
//  DogmatiekRootView.swift
//  Studie
//

import SwiftUI

struct DogmatiekRootView: View {
    @Environment(DogmatiekStore.self) private var store

    var body: some View {
        List {
            Section {
                NavigationLink {
                    DogmatiekStudyOptionsView()
                } label: {
                    Label("Oefenen", systemImage: "rectangle.stack")
                }
                .disabled(store.cards.isEmpty)
                .accessibilityHint(store.cards.isEmpty ? "Voeg eerst minstens één term toe." : "Kies een hoofdstuk of oefen met alles.")

                NavigationLink {
                    DogmatiekManageView()
                } label: {
                    Label("Termen beheren", systemImage: "books.vertical")
                }
                .accessibilityHint("Voeg termen en definities toe of pas ze aan.")
            } footer: {
                Text("Klap ‘Hoofdstukken’ open, kies losse hoofdstukken of ‘Alle hoofdstukken’, en start onderaan. Tijdens de ronde zie je niet of een antwoord goed of fout was; aan het eind krijg je een overzicht.")
                    .font(.footnote)
            }
        }
        .navigationTitle("Dogmatiek")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        DogmatiekRootView()
    }
    .environment(DogmatiekStore())
}
