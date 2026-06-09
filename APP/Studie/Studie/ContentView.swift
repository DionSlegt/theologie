//
//  ContentView.swift
//  Studie
//
//  Created by Mac Studio van Dion on 09/04/2026.
//

import SwiftUI

private struct StudieLauncherCard: View {
    let title: String
    let subtitle: String
    var featured: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(featured ? Color.accentColor.opacity(0.12) : Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    featured ? Color.accentColor.opacity(0.45) : Color(.separator).opacity(0.6),
                    lineWidth: featured ? 1.5 : 1
                )
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kies waar je wilt oefenen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink {
                        DogmatiekRootView()
                    } label: {
                        StudieLauncherCard(
                            title: "Dogmatiek",
                            subtitle: "Oefenen met meerkeuze of zelf invullen."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OudeTestamentOverviewView()
                    } label: {
                        StudieLauncherCard(
                            title: "Oude Testament",
                            subtitle: "Kaders oefenen (zelf invullen), dezelfde stijl als bij Dogmatiek en NT."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        NieuweTestamentOverviewView()
                    } label: {
                        StudieLauncherCard(
                            title: "Nieuwe Testament",
                            subtitle: "Onderdelen kiezen en oefenen (zelf invullen), dezelfde stijl als bij Dogmatiek."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        BijbelvertalingenOverviewView()
                    } label: {
                        StudieLauncherCard(
                            title: "Kenmerken bijbelvertalingen",
                            subtitle: "Begrippen typeren en Bijbelvertalingen duiden."
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("Studie")
        }
    }
}

#Preview {
    ContentView()
        .environment(DogmatiekStore())
}
