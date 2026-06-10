//
//  NieuweTestamentOpbouwNTView.swift
//  Studie
//
//  Opbouw/type boeken NT: intro + zeven categorieën; zelfde reveal/Goed-Fout-lay-out als andere NT-oefeningen; fouten bekijken na de ronde.
//

import SwiftUI

private struct OpbouwNTCategorie {
    let volgnummer: Int
    let titelMarkdown: String
    let bodyMarkdown: String
}

private enum OpbouwNTContent {
    static let introEnVraag: String = [
        "De opbouw van het Nieuwe Testament bestaat uit een verzameling van 27 boeken die door vrijwel alle christelijke denominaties wereldwijd als gezaghebbend worden erkend. Hoewel deze boeken gezamenlijk het Nieuwe Verbond vormen, staan ze niet in chronologische volgorde van schrijven.",
        "",
        "Het Nieuwe Testament wordt gebruikelijk onderverdeeld in zeven categorieën. Welke zijn dat?",
    ].joined(separator: "\n")

    static let introAntwoordMarkdown: String = [
        "De 4 Evangeliën (verhalen over het leven en de leer van Jezus)",
        "",
        "Het boek Handelingen (de vroege geschiedenis van de kerk)",
        "",
        "Brieven van Paulus aan gemeenten",
        "",
        "Brieven van Paulus aan individuen (vaak de pastorale brieven genoemd)",
        "",
        "De brief aan de Hebreeën",
        "",
        "De algemene of katholieke brieven (zoals Jakobus, Petrus en Johannes)",
        "",
        "Het boek Openbaring",
    ].joined(separator: "\n")

    static let categorieën: [OpbouwNTCategorie] = [
        OpbouwNTCategorie(
            volgnummer: 1,
            titelMarkdown: "**1. De vier evangeliën (Matteüs, Marcus, Lucas, Johannes)**",
            bodyMarkdown: [
                "De evangeliën vormen het fundament en vertellen vier verschillende accenten op hetzelfde kernverhaal: het leven, de bediening, de dood en de opstanding van Jezus. Er is veel overlap in de inhoud; tegelijk biedt elk boek een eigen perspectief op zijn missie. De titels verwijzen naar de personen die de traditie als auteurs toeschrijft; de handschriften zelf zijn vaak anoniem.",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 2,
            titelMarkdown: "**2. Het boek Handelingen (Handelingen van de apostelen)**",
            bodyMarkdown: [
                "Dit boek wordt vaak gezien als het tweede deel van het evangelie naar Lucas. Het staat in een aparte categorie omdat het het enige boek is dat de vroege geschiedenis van de christelijke kerk beschrijft, direct na de gebeurtenissen uit de evangeliën.",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 3,
            titelMarkdown: "**3. Brieven van Paulus aan gemeenten**",
            bodyMarkdown: [
                "Negen brieven zijn geschreven door de missionaris Paulus en zijn gericht aan specifieke christelijke gemeenschappen. De titels verwijzen naar geografische locaties (bijvoorbeeld de gemeente in Efeze, vandaar de naam “Efeziërs”). In het Nieuwe Testament staan ze gerangschikt op lengte, van het langste boek tot het kortste:",
                "",
                "**Romeinen**",
                "**1 en 2 Korintiërs**",
                "**Galaten**",
                "**Efeziërs**",
                "**Filippenzen**",
                "**Kolossenzen**",
                "**1 en 2 Tessalonicenzen**",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 4,
            titelMarkdown: "**4. Brieven van Paulus aan individuen**",
            bodyMarkdown: [
                "Naast de brieven aan gemeenten zijn er vier brieven van Paulus gericht aan specifieke personen. Ook deze staan op lengte gerangschikt. In totaal worden dertien brieven in het Nieuwe Testament officieel aan Paulus toegeschreven:",
                "",
                "**1 en 2 Timoteüs**",
                "**Titus**",
                "**Filemon**",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 5,
            titelMarkdown: "**5. De brief aan de Hebreeën**",
            bodyMarkdown: [
                "Dit is een anoniem geschrift dat in een eigen categorie valt. De auteur is onbekend; traditioneel spreekt men van “de brief aan de Hebreeën” omdat het oorspronkelijk waarschijnlijk voor Joodse christenen is geschreven.",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 6,
            titelMarkdown: "**6. De algemene (of katholieke) brieven**",
            bodyMarkdown: [
                "Deze zeven brieven zijn niet naar de ontvangers vernoemd (zoals bij Paulus), maar naar de personen die traditioneel als auteurs gelden. “Katholiek” betekent hier “universeel” of “algemeen”: ze waren voor een breder publiek bedoeld.",
                "",
                "**Jakobus**",
                "**1 en 2 Petrus**",
                "**1, 2 en 3 Johannes**",
                "**Judas**",
            ].joined(separator: "\n")
        ),
        OpbouwNTCategorie(
            volgnummer: 7,
            titelMarkdown: "**7. Het boek Openbaring**",
            bodyMarkdown: [
                "Dit boek staat op zichzelf. In de traditie wordt het ook wel **Apocalyps van Johannes** genoemd. Het verhaalt visionaire ervaringen toegeschreven aan iemand die Johannes heette.",
            ].joined(separator: "\n")
        ),
    ]

    static let overzichtBoekenPrompt: String = "**Noem de opbouw van het Nieuwe Testament met alle boeken**"

    static let overzichtBoekenAntwoord: String = opbouwAntwoordPerRegel([
        "**1. De vier Evangeliën**",
        "Matteüs",
        "Marcus",
        "Lucas",
        "Johannes",
        "**2. Handelingen van de Apostelen**",
        "Handelingen",
        "**3. Brieven van Paulus aan gemeenten**",
        "Romeinen",
        "1 Korintiërs",
        "2 Korintiërs",
        "Galaten",
        "Efeziërs",
        "Filippenzen",
        "Kolossenzen",
        "1 Tessalonicenzen",
        "2 Tessalonicenzen",
        "**4. Brieven van Paulus aan individuen**",
        "1 Timoteüs",
        "2 Timoteüs",
        "Titus",
        "Filemon",
        "**5. De brief aan de Hebreeën**",
        "Hebreeën",
        "**6. De Algemene (of Katholieke) brieven**",
        "Jakobus",
        "1 Petrus",
        "2 Petrus",
        "1 Johannes",
        "2 Johannes",
        "3 Johannes",
        "Judas",
        "**7. Het boek Openbaring**",
        "Openbaring",
    ])

    static func opbouwAntwoordPerRegel(_ regels: [String]) -> String {
        regels.joined(separator: "\n\n")
    }

    static func stapSleutel(abstract: Int) -> String {
        if abstract == 0 { return "intro" }
        if abstract == 1 + categorieën.count { return "overzicht-boeken" }
        return "cat-\(abstract)"
    }

    /// Vaste volgorde 0 = intro, 1…7 = categorieën, 8 = volledig overzicht met alle boeken.
    static let volledigeStapReeks: [Int] = Array(0..<(2 + categorieën.count))
}

private struct OpbouwNTMarkdownAntwoord: View {
    let markdown: String
    var gebruikBlokken = false

    var body: some View {
        Group {
            if gebruikBlokken {
                OpbouwNTAntwoordBlokken(markdown: markdown)
            } else {
                Group {
                    if let attributed = try? AttributedString(markdown: markdown) {
                        Text(attributed)
                    } else {
                        Text(markdown)
                    }
                }
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
            }
        }
    }
}

/// Zelfde opmaak als informatieve HS2-antwoorden: genummerde koppen groter/vet, overige regels regulier.
private struct OpbouwNTAntwoordBlokken: View {
    let markdown: String

    private var blokken: [String] {
        markdown
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func isAlleenVet(_ blok: String) -> Bool {
        blok.range(of: #"^\*\*[^*]+\*\*$"#, options: .regularExpression) != nil
    }

    private func isSectieKop(_ blok: String) -> Bool {
        isAlleenVet(blok)
            && blok.range(of: #"^\*\*\d+\."#, options: .regularExpression) != nil
    }

    @ViewBuilder
    private func tekst(_ blok: String, font: Font) -> some View {
        Group {
            if let attributed = try? AttributedString(markdown: blok) {
                Text(attributed)
            } else {
                Text(blok)
            }
        }
        .font(font)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(blokken.enumerated()), id: \.offset) { _, blok in
                if isSectieKop(blok) {
                    tekst(blok, font: .headline.weight(.bold))
                        .padding(.top, 8)
                } else {
                    tekst(blok, font: .body)
                }
            }
        }
    }
}

private struct OpbouwNTTitelMarkdown: View {
    let markdown: String

    var body: some View {
        Group {
            if let attributed = try? AttributedString(markdown: markdown) {
                Text(attributed)
            } else {
                Text(markdown)
            }
        }
        .font(.title2.weight(.bold))
        .foregroundStyle(.primary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct NieuweTestamentOpbouwNTView: View {
    @State private var stapReeks: [Int] = OpbouwNTContent.volledigeStapReeks
    @State private var stapIndex = 0
    @State private var antwoordZichtbaar = false
    @State private var oordelen: [String: Bool] = [:]
    @State private var rondeAf = false
    @State private var toonFoutenBekijken = false

    private var huidigAbstract: Int { stapReeks[stapIndex] }

    private var stapSleutelsInRonde: [String] { stapReeks.map { OpbouwNTContent.stapSleutel(abstract: $0) } }

    private var scoreTekst: String {
        let goed = NieuweTestamentQuizScore.aantalGoed(oordelen: oordelen, totaalIds: stapSleutelsInRonde)
        return "\(goed) van \(stapSleutelsInRonde.count) goed"
    }

    private var foutAbstracts: [Int] {
        stapReeks.filter { oordelen[OpbouwNTContent.stapSleutel(abstract: $0)] == false }
    }

    private var foutTelling: Int { foutAbstracts.count }

    var body: some View {
        Group {
            if rondeAf {
                if toonFoutenBekijken {
                    foutenBekijkenScherm
                } else {
                    afsluitScherm
                }
            } else {
                huidigeStapView
            }
        }
        .navigationTitle("Opbouw/type boeken NT")
        .navigationBarTitleDisplayMode(.inline)
        .nTBevestigingVoorOnderwerpTerug()
    }

    private var huidigeStapView: some View {
        NieuweTestamentOefenDogmatiekLayout(
            voortgangLabel: "Stap \(stapIndex + 1) van \(stapReeks.count)",
            promptInhoud: { promptVoorHuidigeStap },
            tussenPromptEnPlaceholder: {
                Text("Tik op **Laat antwoord zien** om de uitleg te tonen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            },
            antwoordZichtbaar: antwoordZichtbaar,
            antwoordInhoud: { antwoordVoorHuidigeStap },
            toonVorige: stapIndex > 0,
            onLaatAntwoordZien: { antwoordZichtbaar = true },
            onVorige: gaVorige,
            onOordeelDirect: registreerOordeelEnVolgende
        )
    }

    @ViewBuilder
    private var promptVoorHuidigeStap: some View {
        if huidigAbstract == 0 {
            Text(OpbouwNTContent.introEnVraag)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        } else if huidigAbstract == 1 + OpbouwNTContent.categorieën.count {
            OpbouwNTTitelMarkdown(markdown: OpbouwNTContent.overzichtBoekenPrompt)
        } else {
            let cat = OpbouwNTContent.categorieën[huidigAbstract - 1]
            VStack(alignment: .leading, spacing: 8) {
                Text("Categorie \(cat.volgnummer) van \(OpbouwNTContent.categorieën.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                OpbouwNTTitelMarkdown(markdown: cat.titelMarkdown)
            }
        }
    }

    @ViewBuilder
    private var antwoordVoorHuidigeStap: some View {
        if huidigAbstract == 0 {
            OpbouwNTMarkdownAntwoord(markdown: OpbouwNTContent.introAntwoordMarkdown)
                .font(.body.weight(.semibold))
        } else if huidigAbstract == 1 + OpbouwNTContent.categorieën.count {
            ScrollView {
                OpbouwNTMarkdownAntwoord(
                    markdown: OpbouwNTContent.overzichtBoekenAntwoord,
                    gebruikBlokken: true
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 520)
        } else {
            let cat = OpbouwNTContent.categorieën[huidigAbstract - 1]
            OpbouwNTMarkdownAntwoord(markdown: cat.bodyMarkdown)
                .font(.body.weight(.semibold))
        }
    }

    private var afsluitScherm: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                Text("Ronde klaar")
                    .font(.title2.weight(.semibold))
                Text(scoreTekst)
                    .font(.title3)
                Text("Intro, zeven categorieën en volledig overzicht; na elke uitleg kon je Goed of Fout aangeven.")
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

                        Button("Alleen foute stappen opnieuw") {
                            startFoutenRonde()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("Opnieuw (hele ronde)") {
                            startVolledigeRonde()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    } else {
                        Button("Opnieuw (hele ronde)") {
                            startVolledigeRonde()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
    }

    private var foutenBekijkenScherm: some View {
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

                ForEach(foutAbstracts, id: \.self) { abs in
                    foutKaart(abstract: abs)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func foutKaart(abstract: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if abstract == 0 {
                Text(OpbouwNTContent.introEnVraag)
                    .font(.title3.weight(.semibold))
            } else if abstract == 1 + OpbouwNTContent.categorieën.count {
                OpbouwNTTitelMarkdown(markdown: OpbouwNTContent.overzichtBoekenPrompt)
            } else {
                let cat = OpbouwNTContent.categorieën[abstract - 1]
                OpbouwNTTitelMarkdown(markdown: cat.titelMarkdown)
            }
            Text("Antwoord")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            if abstract == 0 {
                OpbouwNTMarkdownAntwoord(markdown: OpbouwNTContent.introAntwoordMarkdown)
            } else if abstract == 1 + OpbouwNTContent.categorieën.count {
                OpbouwNTMarkdownAntwoord(
                    markdown: OpbouwNTContent.overzichtBoekenAntwoord,
                    gebruikBlokken: true
                )
            } else {
                let cat = OpbouwNTContent.categorieën[abstract - 1]
                OpbouwNTMarkdownAntwoord(markdown: cat.bodyMarkdown)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.quaternary.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func gaVorige() {
        guard stapIndex > 0 else { return }
        stapIndex -= 1
        let sleutel = OpbouwNTContent.stapSleutel(abstract: stapReeks[stapIndex])
        antwoordZichtbaar = oordelen[sleutel] != nil
    }

    private func registreerOordeelEnVolgende(goed: Bool) {
        oordelen[OpbouwNTContent.stapSleutel(abstract: huidigAbstract)] = goed
        if stapIndex + 1 >= stapReeks.count {
            rondeAf = true
            antwoordZichtbaar = false
            toonFoutenBekijken = false
            return
        }
        stapIndex += 1
        antwoordZichtbaar = false
    }

    private func startVolledigeRonde() {
        stapReeks = OpbouwNTContent.volledigeStapReeks
        stapIndex = 0
        oordelen = [:]
        rondeAf = false
        toonFoutenBekijken = false
        antwoordZichtbaar = false
    }

    private func startFoutenRonde() {
        let fout = foutAbstracts
        guard !fout.isEmpty else { return }
        stapReeks = fout
        stapIndex = 0
        oordelen = [:]
        rondeAf = false
        toonFoutenBekijken = false
        antwoordZichtbaar = false
    }
}

// MARK: - Gecombineerde oefening

enum NieuweTestamentOpbouwNtOefenAdapter {
    static func kaartenVoorGecombineerd() -> [NieuweTestamentOefenKaart] {
        var kaarten: [NieuweTestamentOefenKaart] = [
            NieuweTestamentOefenKaart(
                id: "nt-opbouw-intro",
                bron: .opbouwNt,
                promptWeergave: .plainTitle3,
                prompt: OpbouwNTContent.introEnVraag,
                antwoordWeergave: .markdown,
                antwoord: OpbouwNTContent.introAntwoordMarkdown,
                secundaireHint: "Zelfde werkwijze als in het onderwerp: eerst Laat antwoord zien, daarna Goed/Fout."
            ),
        ]
        for cat in OpbouwNTContent.categorieën {
            kaarten.append(
                NieuweTestamentOefenKaart(
                    id: "nt-opbouw-cat-\(cat.volgnummer)",
                    bron: .opbouwNt,
                    promptWeergave: .markdownStromingNaamTitle2Bold,
                    prompt: cat.titelMarkdown,
                    antwoordWeergave: .markdown,
                    antwoord: cat.bodyMarkdown,
                    secundaireHint: "Categorie \(cat.volgnummer) van \(OpbouwNTContent.categorieën.count)"
                )
            )
        }
        kaarten.append(
            NieuweTestamentOefenKaart(
                id: "nt-opbouw-overzicht-boeken",
                bron: .opbouwNt,
                promptWeergave: .markdownStromingNaamTitle2Bold,
                prompt: OpbouwNTContent.overzichtBoekenPrompt,
                antwoordWeergave: .markdown,
                antwoord: OpbouwNTContent.overzichtBoekenAntwoord,
                secundaireHint: "Alle zeven categorieën met elk boek apart"
            )
        )
        return kaarten
    }
}

#Preview {
    NavigationStack {
        NieuweTestamentOpbouwNTView()
    }
}
