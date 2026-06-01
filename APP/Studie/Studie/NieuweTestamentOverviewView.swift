//
//  NieuweTestamentOverviewView.swift
//  Studie
//

import SwiftUI

/// Onderdeel dat nog niet klaar is om te oefenen.
struct NieuweTestamentBinnenkortView: View {
    let onderwerp: String

    var body: some View {
        ContentUnavailableView {
            Label(onderwerp, systemImage: "calendar.badge.clock")
        } description: {
            Text(
                "Dit onderdeel is nog in voorbereiding en wordt binnenkort toegevoegd aan de app."
            )
            .multilineTextAlignment(.center)
        }
        .navigationTitle(onderwerp)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Placeholder voor onderwerpen zonder eigen scherm.
struct NieuweTestamentTopicDetailView: View {
    let bron: String
    let onderwerp: String

    var body: some View {
        List {
            Section {
                (Text("Hier komt straks het studiemateriaal voor ")
                    + Text(onderwerp).fontWeight(.semibold)
                    + Text(" (\(bron))."))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(onderwerp)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NieuweTestamentOverviewView: View {
    private let hs12PowellOnderwerpen = [
        "Tijdsperiode",
        "Begrippen",
        "Belangrijke personen",
        "Stromingen",
    ]

    private let hs3PowellOnderwerpen = [
        "Opbouw/type boeken NT",
        "Begrippen",
    ]

    private let bronHs12 = "Hs 1–2 Powell"
    private let bronHs3 = "Hs 3 Powell"
    private let bronAchtenmeier = "Achtenmeier"

    var body: some View {
        List {
            Section {
                ForEach(hs12PowellOnderwerpen, id: \.self) { onderwerp in
                    NavigationLink {
                        if onderwerp == "Tijdsperiode" {
                            NieuweTestamentTijdsperiodeQuizView()
                        } else if onderwerp == "Begrippen" {
                            NieuweTestamentBegrippenView(deel: .powellHs12)
                        } else if onderwerp == "Belangrijke personen" {
                            NieuweTestamentBelangrijkePersonenQuizView()
                        } else if onderwerp == "Stromingen" {
                            NieuweTestamentStromingenQuizView()
                        } else {
                            NieuweTestamentTopicDetailView(bron: bronHs12, onderwerp: onderwerp)
                        }
                    } label: {
                        Text(onderwerp)
                    }
                }
            } header: {
                Text("Hs 1–2 Powell")
            }

            Section {
                ForEach(hs3PowellOnderwerpen, id: \.self) { onderwerp in
                    NavigationLink {
                        if onderwerp == "Opbouw/type boeken NT" {
                            NieuweTestamentOpbouwNTView()
                        } else if onderwerp == "Begrippen" {
                            NieuweTestamentBegrippenView(deel: .powellHs3)
                        } else {
                            NieuweTestamentTopicDetailView(bron: bronHs3, onderwerp: onderwerp)
                        }
                    } label: {
                        Text(onderwerp)
                    }
                }
            } header: {
                Text("Hs 3 Powell")
            }

            Section {
                NavigationLink {
                    NieuweTestamentAchtenmeierCanonView()
                } label: {
                    Text("Canonvorming NT")
                }
            } header: {
                Text("Achtenmeier")
            }
        }
        .navigationTitle("Nieuwe Testament")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        NieuweTestamentOverviewView()
    }
}
