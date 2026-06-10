//
//  NieuweTestamentBelangrijkePersonenQuizView.swift
//  Studie
//
//  Eerste + midden (geschud) + slot vast; zelf oordeel Goed/Fout; opnieuw hele ronde of alleen fouten.
//

import SwiftUI

private struct NTPersonenVraag: Identifiable {
    let id: String
    let prompt: String
    let antwoordMarkdown: String
}

private enum NieuweTestamentBelangrijkePersonenData {
    private static func personenMd(_ regels: [String]) -> String {
        regels.joined(separator: "\n\n")
    }

    private static let antwoordGriekseHeersers = personenMd([
        """
        - **Alexander de Grote:** Macedonische koning die Palestina veroverde (332 v.Chr.) en de **hellenisering** (verspreiding Griekse taal en cultuur) startte.
        - **Antiochus IV Epiphanes:** Seleucidische koning die de Joodse religie probeerde uit te roeien en de tempel ontheiligde met een altaar voor Zeus.
        """,
    ])

    private static let antwoordJoodseBevrijder = personenMd([
        """
        - **Judas de Makkabeeër:** Leider van de Joodse opstand ('de moker') die in 164 v.Chr. de tempel heroverde en reinigde (oorsprong **Chanoeka**).
        """,
    ])

    private static let antwoordRomeinseBestuurder = personenMd([
        """
        - **Pontius Pilatus:** Romeinse prefect van Judea (26–36 n.Chr.) die Jezus ter dood veroordeelde; historisch bekend als een meedogenloos bestuurder.
        """,
    ])

    private static let antwoordHerodessen = personenMd([
        """
        1. **Herodes de Grote:** Koning van heel Palestina (37–4 v.Chr.) tijdens Jezus' geboorte; een meesterbouwer (tempel Jeruzalem) die berucht was om zijn extreme paranoia.
        2. **Herodes Antipas:** Zoon van de Grote en **tetrarch** van Galilea tijdens Jezus' leven; liet Johannes de Doper onthoofden en verhoorde Jezus.
        3. **Herodes Agrippa I:** Kleinzoon van de Grote; vervolgde de vroege kerk, liet de apostel Jakobus doden en stierf een plotselinge dood.
        4. **Herodes Agrippa II:** Zoon van Agrippa I; trad op als adviseur voor Romeinse bestuurders en hoorde de verdediging van Paulus aan.
        """,
    ])

    static let alle: [NTPersonenVraag] = [
        NTPersonenVraag(
            id: "griekse-heersers",
            prompt: "**Griekse heersers**",
            antwoordMarkdown: antwoordGriekseHeersers
        ),
        NTPersonenVraag(
            id: "joodse-bevrijder",
            prompt: "**Joodse bevrijder**",
            antwoordMarkdown: antwoordJoodseBevrijder
        ),
        NTPersonenVraag(
            id: "romeinse-bestuurder",
            prompt: "**Romeinse bestuurder**",
            antwoordMarkdown: antwoordRomeinseBestuurder
        ),
        NTPersonenVraag(
            id: "herodessen",
            prompt: "**De vier Herodessen**",
            antwoordMarkdown: antwoordHerodessen
        ),
    ]

    static func maakVolgordeVoorRonde() -> [NTPersonenVraag] {
        alle
    }

    static func volgordeFouten(oordelen: [String: Bool]) -> [NTPersonenVraag]? {
        let fout = alle.filter { oordelen[$0.id] == false }
        guard !fout.isEmpty else { return nil }
        return fout
    }

    /// Lijst van alleen namen (eerste + slotvraag); werkt ook als markdown-regels zijn samengevallen.
    static func opsommingNamen(uit markdown: String) -> [String]? {
        var namen: [String] = []
        var zoek = markdown.startIndex
        while let open = markdown.range(of: "**", range: zoek..<markdown.endIndex) {
            let naOpen = open.upperBound
            guard let sluit = markdown.range(of: "**", range: naOpen..<markdown.endIndex) else { break }
            let naam = String(markdown[naOpen..<sluit.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !naam.isEmpty {
                namen.append(naam)
            }
            zoek = sluit.upperBound
        }
        return namen.count >= 2 ? namen : nil
    }
}

private struct MarkdownAntwoord: View {
    let markdown: String

    var body: some View {
        Group {
            if let namen = NieuweTestamentBelangrijkePersonenData.opsommingNamen(uit: markdown) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(namen, id: \.self) { naam in
                        Text(naam)
                            .fontWeight(.semibold)
                    }
                }
            } else if isLijstOfGemengdMarkdown(markdown) {
                enkeleMarkdownRegel(markdown.trimmingCharacters(in: .whitespacesAndNewlines))
            } else if let secties = markdownSecties(markdown) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(secties.enumerated()), id: \.offset) { _, sectie in
                        persoonSectieInhoud(sectie)
                    }
                }
            } else {
                persoonSectieInhoud(markdown)
            }
        }
        .font(.body)
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineSpacing(4)
    }

    @ViewBuilder
    private func persoonSectieInhoud(_ tekst: String) -> some View {
        let blok = tekst.trimmingCharacters(in: .whitespacesAndNewlines)
        if let scheiding = blok.range(of: "\n\n") {
            let kop = String(blok[..<scheiding.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let body = String(blok[scheiding.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            VStack(alignment: .leading, spacing: 8) {
                enkeleMarkdownRegel(kop)
                if !body.isEmpty {
                    enkeleMarkdownRegel(body)
                }
            }
        } else {
            enkeleMarkdownRegel(blok)
        }
    }

    @ViewBuilder
    private func enkeleMarkdownRegel(_ tekst: String) -> some View {
        if let attributed = try? AttributedString(markdown: tekst) {
            Text(attributed)
        } else {
            Text(tekst)
        }
    }

    private func isLijstOfGemengdMarkdown(_ tekst: String) -> Bool {
        let t = tekst.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("- ") || t.contains("\n- ") {
            return true
        }
        return t.range(of: #"(?m)^\d+\.\s"#, options: .regularExpression) != nil
    }

    /// Meerdere personen gescheiden door `\n\n\n`, of kopregels `**naam**`.
    private func markdownSecties(_ tekst: String) -> [String]? {
        if tekst.contains("\n\n\n") {
            let parts = tekst
                .components(separatedBy: "\n\n\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if parts.count >= 2 {
                return parts
            }
        }

        var secties: [String] = []
        var huidig: [String] = []

        func vastleggen() {
            let blok = huidig.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !blok.isEmpty {
                secties.append(blok)
            }
            huidig = []
        }

        for regel in tekst.components(separatedBy: "\n") {
            if isKopregelPersoon(regel), !huidig.isEmpty {
                vastleggen()
            }
            if isKopregelPersoon(regel) || !regel.trimmingCharacters(in: .whitespaces).isEmpty || !huidig.isEmpty {
                huidig.append(regel)
            }
        }
        vastleggen()

        guard secties.count >= 2 else { return nil }
        return secties
    }

    private func isKopregelPersoon(_ regel: String) -> Bool {
        let t = regel.trimmingCharacters(in: .whitespaces)
        guard t.hasPrefix("**") else { return false }
        let rest = t.dropFirst(2)
        return rest.contains("**")
    }
}

struct NieuweTestamentBelangrijkePersonenQuizView: View {
    @State private var volgorde: [NTPersonenVraag] = []
    @State private var index = 0
    @State private var antwoordZichtbaar = false
    @State private var oordelen: [String: Bool] = [:]
    @State private var rondeAf = false
    @State private var toonFoutenBekijken = false

    private var huidige: NTPersonenVraag? {
        guard index < volgorde.count else { return nil }
        return volgorde[index]
    }

    private var scoreTekst: String {
        let ids = volgorde.map(\.id)
        let goed = NieuweTestamentQuizScore.aantalGoed(oordelen: oordelen, totaalIds: ids)
        return "\(goed) van \(ids.count) goed"
    }

    private var foutVragen: [NTPersonenVraag] {
        volgorde.filter { oordelen[$0.id] == false }
    }

    private var foutTelling: Int { foutVragen.count }

    var body: some View {
        Group {
            if rondeAf {
                if toonFoutenBekijken {
                    personenFoutenBekijkenScherm
                } else {
                    afsluitView
                }
            } else if let v = huidige {
                vraagView(v)
            } else {
                ContentUnavailableView("Geen vragen", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("Oefenen · zelf invullen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if volgorde.isEmpty {
                startNieuweRonde(met: NieuweTestamentBelangrijkePersonenData.maakVolgordeVoorRonde())
            }
        }
        .nTBevestigingVoorQuizTerug()
    }

    private func startNieuweRonde(met items: [NTPersonenVraag]) {
        volgorde = items
        index = 0
        rondeAf = false
        antwoordZichtbaar = false
        oordelen = [:]
        toonFoutenBekijken = false
    }

    private var personenFoutenBekijkenScherm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    toonFoutenBekijken = false
                } label: {
                    Label("Terug naar samenvatting", systemImage: "chevron.backward")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Text("Fout gemarkeerd (\(foutTelling))")
                    .font(.title3.weight(.semibold))

                ForEach(foutVragen) { v in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(v.prompt)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        MarkdownAntwoord(markdown: v.antwoordMarkdown)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.quaternary.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding()
        }
    }

    private var afsluitView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                Text("Ronde klaar")
                    .font(.title2.weight(.semibold))
                Text(scoreTekst)
                    .font(.title3)
                Text("Vier koppen in vaste volgorde; na elke uitleg kon je Goed of Fout aangeven.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    if foutTelling > 0 {
                        Button {
                            toonFoutenBekijken = true
                        } label: {
                            Label("Fouten bekijken", systemImage: "eye.fill")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)

                        Button("Alleen fouten opnieuw") {
                            if let fout = NieuweTestamentBelangrijkePersonenData.volgordeFouten(oordelen: oordelen) {
                                startNieuweRonde(met: fout)
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .disabled(!NieuweTestamentQuizScore.heeftFouten(oordelen: oordelen))

                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: NieuweTestamentBelangrijkePersonenData.maakVolgordeVoorRonde())
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    } else {
                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: NieuweTestamentBelangrijkePersonenData.maakVolgordeVoorRonde())
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
    }

    private func vraagView(_ v: NTPersonenVraag) -> some View {
        NieuweTestamentOefenDogmatiekLayout(
            voortgangLabel: "Vraag \(index + 1) van \(volgorde.count)",
            promptInhoud: {
                Group {
                    if let attributed = try? AttributedString(markdown: v.prompt) {
                        Text(attributed)
                    } else {
                        Text(v.prompt)
                    }
                }
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            },
            tussenPromptEnPlaceholder: { EmptyView() },
            antwoordZichtbaar: antwoordZichtbaar,
            antwoordInhoud: {
                MarkdownAntwoord(markdown: v.antwoordMarkdown)
            },
            toonVorige: index > 0,
            onLaatAntwoordZien: { antwoordZichtbaar = true },
            onVorige: gaNaarVorigeVraag,
            onOordeelDirect: registreerOordeelEnVolgende
        )
    }

    private func gaNaarVorigeVraag() {
        guard index > 0 else { return }
        index -= 1
        antwoordZichtbaar = false
    }

    private func registreerOordeelEnVolgende(goed: Bool) {
        guard let v = huidige else { return }
        oordelen[v.id] = goed
        if index + 1 >= volgorde.count {
            rondeAf = true
            antwoordZichtbaar = false
            return
        }
        index += 1
        antwoordZichtbaar = false
    }
}

// MARK: - Gecombineerde oefening

enum NieuweTestamentBelangrijkePersonenOefenAdapter {
    static func kaartenVoorGecombineerd() -> [NieuweTestamentOefenKaart] {
        NieuweTestamentBelangrijkePersonenData.maakVolgordeVoorRonde().map { v in
            NieuweTestamentOefenKaart(
                id: "nt-pers-\(v.id)",
                bron: .belangrijkePersonen,
                promptWeergave: .plainTitle3,
                prompt: v.prompt,
                antwoordWeergave: .markdown,
                antwoord: v.antwoordMarkdown,
                secundaireHint: nil
            )
        }
    }
}

#Preview {
    NavigationStack {
        NieuweTestamentBelangrijkePersonenQuizView()
    }
}
