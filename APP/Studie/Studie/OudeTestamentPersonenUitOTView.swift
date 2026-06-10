//
//  OudeTestamentPersonenUitOTView.swift
//  Studie
//

import SwiftUI

private struct OTPersoonVraag: Identifiable {
    let id: String
    let promptMarkdown: String
    let antwoordMarkdown: String
}

/// Prompt: naam (groot) + drie rubrieken om zelf in te vullen.
private enum OTPersoonPromptBuilder {
    static func persoonPrompt(naam: String) -> String {
        """
        **\(naam)**

        **Gebied en Archeologische periode**

        **Politiek**

        **Typering**
        """
    }
}

private enum OudeTestamentPersonenData {
    static let items: [OTPersoonVraag] = [
        .init(
            id: "ot-persoon-abraham",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Abraham"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - Midden bronstijd (2000 – 1550 v.Chr.)
            - Abraham en aartsvaders hadden half nomadisch bestaan
            - Mesopotamië in Ur, huidige Irak
            - Via Haran naar Sichem in Kanaän omdat dat de vruchtbare halve maan volgt

            **Politiek**

            - Machtsverschuiving
              - De gevestigde dynastieën waren ingestort
              - Half nomadische stammen (Amorieten) de macht in Mesopotamië
              - Dit is de optrap naar het Oud-Babylonische rijk (Hammurabi) als belangrijke koning. (Hammurabi codex, verzameling wetten)

            **Typering**

            - Explosieve stedelijke ontwikkeling en gigantische bureaucratie
            - Tijd van uitvinding en spreiding van het schrift
              - Mesopotamië spijkerschrift
              - Egypte hiërogliefen op papyrus
            """
        ),
        .init(
            id: "ot-persoon-mozes",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Mozes"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - Late bronstijd (1550 – 1200 v.Chr.)
            - Slavernij in Egypte, uittocht (Exodus), 40 jaar tochten door de woestijn.

            **Politiek**

            - Balance of powers
              - In Mesopotamië (Kasieten heerst)
              - Egypte nieuwe rijk (Kanaän en Egypte)
            - Akkadisch (Internationale diplomatieke taal)
            - Amarna brieven (Contact over Egypte en andere machten)

            **Typering**

            - Plagen waren geen willekeurige rampen maar theologische oorlogsvoering
              - Hagel was een aanval op Horus (god van de lucht) of op Osiris (god van de landbouw)
              - Ze lieten zien: Onze God breekt de macht van jullie goden.
            """
        ),
        .init(
            id: "ot-persoon-jozua",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Jozua"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - Late bronstijd (1550 – 1200 v.Chr.)
            - Kanaän / Israël

            **Politiek**

            - Israël was in deze tijd een stammenfederatie (een confederatie van 12 stammen) en nog geen centraal koninkrijk
            - Interne zwakte bij de wereldrijken

            **Typering**

            - Tijden van droogte, hongersnoden en migraties laat de grote rijken instorten
              - Hierdoor konden zeevolken ontwikkelen (Filistijnen)
            """
        ),
        .init(
            id: "ot-persoon-david",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "David"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 1 (1200 - 930 v.Chr.)
            - Datering David 1000 v.Chr.

            **Politiek**

            - Geopolitiek machtsvacuüm (Egypte en de rijken in Mesopotamië waren tijdelijk zwak waren of waren ingestort)
            - Interne zwakte van Egypte: Het Egyptische Nieuwe Rijk kampte met interne verdeeldheid en wanorde, waardoor zij de controle over Kanaän verloren
            - Filistijnen al vijand
              - Pentapolis: Ekron – Asdod – Ashkelon – Gath – Gaza

            **Typering**

            - Verenigde monarchie (Hoofdstad Jeruzalem)
            - Overgang bronstijd naar ijzertijd
            """
        ),
        .init(
            id: "ot-persoon-salomo",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Salomo"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 1 (1200 - 930 v.Chr.)
            - Verenigde Koninkrijk Israël

            **Politiek**

            - Machtsvacuüm (Egypte en de rijken in Mesopotamië waren tijdelijk zwak waren of waren ingestort)
            - Beheerde handelsroutes (Egypte, Arabische woestijn en Syrië)
            - Vazallen: Andere volken in de regio moesten hem eer bewijzen en schattingen betalen

            **Typering**

            - Gouden eeuw - Een tijd van grote internationale prestige en economische voorspoed
            - Bouw van de eerste tempel in Jeruzalem
            - Dictatuur (Hoge belastingen en herendiensten. (Tijdelijke slavernij voor eigen inwoners))
            """
        ),
        .init(
            id: "ot-persoon-jerobeam-i",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Jerobeam I"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 2 (930–539 v.Chr.)
            - Scheuring rijk (930 v.Chr.)
            - Koning Noordrijk

            **Politiek**

            - Veel oorlog tussen Juda, Israël en Aram
            - Egypte speelde minder direct een rol; Assyrië begon op afstand weer sterker te worden.

            **Typering**

            - Een tijd van interne politieke onrust en wisselende dynastieën in het noorden
            - Begin van "kwaad doen in de ogen van God,"
            - Tempel staat in zuiden. Om te voorkomen dat het volk naar het zuiden reist:
              - Creëert 2 heiligdommen (Dan en Bethel)
              - Gouden kalveren
              - Religieuze instabiliteit (Ook i.v.m. Baal diensten).
            """
        ),
        .init(
            id: "ot-persoon-jerobeam-ii",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Jerobeam II"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 2 (930–539 v.Chr.)
            - Noordrijk Israël - hoofdstad Samaria

            **Politiek**

            - Machtsvacuüm (De expansie van Israël was mogelijk omdat het Nieuw-Assyrische Rijk op dat moment kampte met interne problemen en tijdelijk zwak was)
            - Na de dood van Jerobeam II herpakten de Assyriërs zich. Israël werd eerst een vazalstaat en werd uiteindelijk in 722 v.Chr. definitief van de kaart geveegd na de val van Samaria

            **Typering**

            - Laatste bloei voor de val (Economische bloei en uitbreiding grondgebied)
              - Oude grenzen van David hersteld
            - Sociale corruptie: De profeet Amos klaagde de elite aan vanwege hun luxe (zoals "ivoren bedden") en de uitbuiting van de armen
            - Profetie: Amos voorspelde dat de paleizen in puin zouden vallen als straf voor deze corruptie
            """
        ),
        .init(
            id: "ot-persoon-hiskia",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Hiskia"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 2 (930–539 v.Chr.)
            - Juda (Jeruzalem)

            **Politiek**

            - Het Nieuw-Assyrische Rijk was op het hoogtepunt van zijn macht
            - Juda was in deze periode een vazalstaat
            - Machtverschuiving: Terwijl Assyrië domineerde, begon Babylon aan de macht te komen als de volgende grote speler
            - Jesaja was adviseur van de Koning

            **Typering**

            - Wordt gezien als "goede koning"
            - Regeerde in de schaduw van de ondergang van het Noordrijk (722 v.Chr.) en moest Jeruzalem behoeden voor eenzelfde lot
            - Religieuze centralisatie
              - Sloopt lokale heiligdommen
              - Aanbidding in exclusief Jeruzalem
            """
        ),
        .init(
            id: "ot-persoon-josia",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Josia"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd 2 (930–539 v.Chr.)
            - (regeerde ca. 640–609 v.Chr.).
            - Gebied: Het Zuidrijk (Juda).

            **Politiek**

            - Assyrië stort in door druk van Babylonische rebellen (Ninevé valt)
            - Machtsvacuüm ontstaat Josia pakt zijn kans
            - Egypte grijpt in, Josia dacht de Farao tegen te kunnen houden
            - Josia sterft in strijd met Egypte bij Megido
            - Einde van een tijdperk: Hij was de laatste goede koning vóór de verwoesting van Jeruzalem en de daaropvolgende ballingschap

            **Typering**

            - Hervormingskoning: Josia wordt getypeerd als een hervormingsgezinde en de laatste "goede" koning van Juda. Zorgt voor zuivering van Assyrische en vreemde/heiden cultische invloeden
            - Vondst van de Wet: Tijdens herstelwerkzaamheden in de tempel werd het "boek van de wet" (waarschijnlijk een vroege vorm van Deuteronomium) teruggevonden, wat leidde tot een grote religieuze ommekeer
            - Herstel: Hij probeerde de corruptie van zijn voorgangers ongedaan te maken en de exclusieve aanbidding van God te herstellen
            """
        ),
        .init(
            id: "ot-persoon-jeremia",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Jeremia"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd II (930 – 539 v.Chr.)
            - **Zuidrijk (Juda)**

            **Politiek**

            - Jeremia leefde tijdens de absolute overmacht van het **Neo-Babylonische Rijk**.
            - Ondanks zijn waarschuwingen kwam Juda in opstand tegen Babylon,
            - Wat leidde tot de totale verwoesting van Jeruzalem en de tempel in 587 v.Chr.

            **Typering**

            - **Profeet van de ondergang:** Hij kondigde de straf van God aan en maakte de verschrikkingen van de belegering (uithongering) en de deportaties zelf mee.
            - **Conflict met de macht:** Een bekend moment is dat koning **Jojakim** de boekrol met profetieën van Jeremia in het vuur gooide omdat de boodschap hem niet beviel.
            """
        ),
        .init(
            id: "ot-persoon-zerubbabel",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Zerubbabel"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd III (539–332 v.Chr.)
            - Perzisch rijk → provincie Jehud (Jeruzalem)

            **Politiek**

            - Het Perzische Rijk nam de macht over van Babylon
            - Koning Cyrus de Grote vaardigde in 539 v.Chr. een decreet uit (de eerste terugkeer), waarbij bannelingen toestemming kregen om naar huis te gaan en hun tempels te herbouwen

            **Typering**

            - Leider van de eerste groep ballingen die terugkeerde uit Perzië naar Jeruzalem.
            - Hij was verantwoordelijk voor de herbouw van de Tempel op de fundamenten van de oude tempel van Salomo
            """
        ),
        .init(
            id: "ot-persoon-ezra",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Ezra"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd III (539–332 v.Chr.)
            - Perzisch rijk → provincie Jehud (Jeruzalem)

            **Politiek**

            - Ezra als officieel van het Perzische hof
            - Autonomie van Jehud onder Perzen
              - Hij leidde de "tweede terugkeer" van ballingen in 458 v.Chr., met toestemming van de Perzische koning Artaxerxes

            **Typering**

            - Schriftgeleerde
            - Geestelijk hervormer: Hij herstelde het priesterschap en de religieuze voorschriften in Jeruzalem
            - Verlegde focus van tempel naar Thora
              - Nadruk op de geschriften in plaats van alleen de tempel
              - Centrale rol van de wet in het gemeenschapsleven
            """
        ),
        .init(
            id: "ot-persoon-nehemia",
            promptMarkdown: OTPersoonPromptBuilder.persoonPrompt(naam: "Nehemia"),
            antwoordMarkdown: """
            **Gebied en Archeologische periode**

            - IJzertijd III (539–332 v.Chr.)
            - Gebied: reisde vanuit Perzisch rijk naar Jehud (Jeruzalem)

            **Politiek**

            - **gouverneur** om de "derde terugkeer" van ballingen te leiden
            - **Perzische absoluut wereldrijk**, lokale autonomie voor Jehud

            **Typering**

            - **De herbouwer:** Nehemia was verantwoordelijk voor de herbouw van de stadsmuren
            - **Restauratie:** herstel van Jeruzalem als religieus en politiek centrum
            - **Strikte sociale grenzen**
              - Gedwongen scheidingen van buitenlandse vrouwen
              - Overleven door isolatie
            - **Organisatorisch leider:** Terwijl Ezra de geestelijke hervormingen leidde, richtte Nehemia zich op het bestuur en de verdediging van Jeruzalem.
            """
        )
    ]

    static func maakVolgordeVoorRonde() -> [OTPersoonVraag] {
        items
    }

    static func volgordeFouten(oordelen: [String: Bool]) -> [OTPersoonVraag]? {
        let fout = items.filter { oordelen[$0.id] == false }
        guard !fout.isEmpty else { return nil }
        return fout
    }
}

private enum OTPersoonMarkdownRegel: Identifiable {
    case kop(String)
    case streepje(inspring: Int, tekst: String)
    case alinea(String)

    var id: String {
        switch self {
        case .kop(let t): return "k:\(t)"
        case .streepje(let i, let t): return "s:\(i):\(t)"
        case .alinea(let t): return "a:\(t)"
        }
    }
}

private enum OTPersoonMarkdownParser {
    private static let streepjePatroon = /^(\s*)-\s+(.+)$/

    static func regels(in markdown: String) -> [OTPersoonMarkdownRegel] {
        let ruweRegels = markdown
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .newlines) }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        guard !ruweRegels.isEmpty else { return [] }

        if ruweRegels.allSatisfy(isStreepjeRegel) {
            return ruweRegels.compactMap(streepjeRegel)
        }

        if ruweRegels.count == 1, let kop = kopTekst(ruweRegels[0]) {
            return [.kop(kop)]
        }

        return [.alinea(ruweRegels.joined(separator: "\n"))]
    }

    private static func isStreepjeRegel(_ regel: String) -> Bool {
        regel.firstMatch(of: streepjePatroon) != nil
    }

    private static func streepjeRegel(_ regel: String) -> OTPersoonMarkdownRegel? {
        guard let match = regel.firstMatch(of: streepjePatroon) else { return nil }
        let spaties = match.1.count
        let inspring = spaties / 2
        let tekst = String(match.2)
        return .streepje(inspring: inspring, tekst: tekst)
    }

    private static func kopTekst(_ regel: String) -> String? {
        let t = regel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.hasPrefix("**"), t.hasSuffix("**") else { return nil }
        let inner = String(t.dropFirst(2).dropLast(2))
        guard !inner.contains("**") else { return nil }
        return inner
    }
}

private struct OTPersoonMarkdown: View {
    let markdown: String
    /// Streepjes en gewone tekst.
    var inhoudFont: Font = .body
    /// Rubrieken zoals «Gebied en Archeologische periode» — kleiner dan de naam, groter dan inhoud.
    var rubriekFont: Font = .subheadline.weight(.semibold)

    var body: some View {
        let regels = OTPersoonMarkdownParser.regels(in: markdown)
        if regels.isEmpty {
            platteTekst
        } else {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(regels) { regel in
                    switch regel {
                    case .kop(let tekst):
                        Text(tekst)
                            .font(rubriekFont)
                    case .streepje(let inspring, let tekst):
                        HStack(alignment: .top, spacing: 6) {
                            Text(streepjeTeken(voorInspring: inspring))
                                .font(inhoudFont)
                            OTPersoonInlineMarkdown(tekst: tekst, font: inhoudFont)
                        }
                        .padding(.leading, streepjeInspringing(inspring))
                    case .alinea(let tekst):
                        OTPersoonInlineMarkdown(tekst: tekst, font: inhoudFont)
                    }
                }
            }
        }
    }

    /// Hoofdniveau: streepje; subniveau: ander teken (zoals in je aantekeningen).
    private func streepjeTeken(voorInspring niveau: Int) -> String {
        niveau > 0 ? "·" : "–"
    }

    private func streepjeInspringing(_ niveau: Int) -> CGFloat {
        guard niveau > 0 else { return 0 }
        return 28 + CGFloat(niveau - 1) * 24
    }

    @ViewBuilder
    private var platteTekst: some View {
        if let attributed = try? AttributedString(markdown: markdown) {
            Text(attributed)
                .font(inhoudFont)
        } else {
            Text(markdown)
                .font(inhoudFont)
        }
    }
}

/// **vet** in één regel.
private struct OTPersoonInlineMarkdown: View {
    let tekst: String
    var font: Font = .body

    var body: some View {
        Group {
            if let attributed = try? AttributedString(markdown: tekst) {
                Text(attributed)
            } else {
                Text(tekst)
            }
        }
        .font(font)
        .foregroundStyle(.primary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// Dubbele newlines in de bron (`\\n\\n`) worden als witregels tussen blokken getoond — één `Text`/AttributedString plakt alles vaak aan elkaar.
private struct OTPersoonMarkdownGestapeld: View {
    let markdown: String
    var blokSpacing: CGFloat = 16
    /// Alleen bij de vraag: eerste blok is de persoonsnaam (Abraham), niet een rubriek.
    var eersteBlokIsPersoonsnaam: Bool = false
    var naamFont: Font = .title.weight(.bold)
    /// Gelijk voor Gebied, Politiek en Typering (prompt én antwoord).
    var rubriekFont: Font = .subheadline.weight(.semibold)
    var inhoudFont: Font = .body

    private var blokken: [String] {
        markdown
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func isAlleenPersoonsnaam(_ blok: String) -> Bool {
        let t = blok.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.hasPrefix("**"), t.hasSuffix("**") else { return false }
        let inner = String(t.dropFirst(2).dropLast(2))
        return !inner.contains("**")
    }

    @ViewBuilder
    private func markdownVoorBlok(_ blok: String, at index: Int) -> some View {
        if eersteBlokIsPersoonsnaam, index == 0, isAlleenPersoonsnaam(blok) {
            let naam = blok.trimmingCharacters(in: .whitespacesAndNewlines)
                .dropFirst(2).dropLast(2)
            Text(String(naam))
                .font(naamFont)
        } else {
            OTPersoonMarkdown(
                markdown: blok,
                inhoudFont: inhoudFont,
                rubriekFont: rubriekFont
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: blokSpacing) {
            ForEach(Array(blokken.enumerated()), id: \.offset) { idx, blok in
                markdownVoorBlok(blok, at: idx)
            }
        }
    }
}

struct OudeTestamentPersonenUitOTView: View {
    @State private var volgorde: [OTPersoonVraag] = []
    @State private var index = 0
    @State private var antwoordZichtbaar = false
    @State private var oordelen: [String: Bool] = [:]
    @State private var rondeAf = false
    @State private var toonFoutenBekijken = false

    private var huidige: OTPersoonVraag? {
        guard index < volgorde.count else { return nil }
        return volgorde[index]
    }

    private var foutItems: [OTPersoonVraag] {
        volgorde.filter { oordelen[$0.id] == false }
    }

    private var foutTelling: Int { foutItems.count }

    private var scoreTekst: String {
        let ids = volgorde.map(\.id)
        let goed = NieuweTestamentQuizScore.aantalGoed(oordelen: oordelen, totaalIds: ids)
        return "\(goed) van \(ids.count) goed"
    }

    var body: some View {
        Group {
            if rondeAf {
                if toonFoutenBekijken {
                    foutenBekijkenScherm
                } else {
                    afsluitView
                }
            } else if let v = huidige {
                vraagView(v)
            } else {
                ContentUnavailableView("Geen personen", systemImage: "book.closed")
            }
        }
        .navigationTitle("Oefenen · zelf invullen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if volgorde.isEmpty {
                startNieuweRonde(met: OudeTestamentPersonenData.maakVolgordeVoorRonde())
            }
        }
        .nTBevestigingVoorQuizTerug()
    }

    private func startNieuweRonde(met items: [OTPersoonVraag]) {
        volgorde = items
        index = 0
        rondeAf = false
        antwoordZichtbaar = false
        oordelen = [:]
        toonFoutenBekijken = false
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

                ForEach(foutItems) { v in
                    VStack(alignment: .leading, spacing: 12) {
                        OTPersoonMarkdownGestapeld(
                            markdown: v.promptMarkdown,
                            blokSpacing: 12,
                            eersteBlokIsPersoonsnaam: true
                        )
                        Text("Antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        OTPersoonMarkdownGestapeld(
                            markdown: v.antwoordMarkdown,
                            blokSpacing: 16
                        )
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
                Text("Per persoon geoefend met reveal en eigen beoordeling.")
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
                            if let fout = OudeTestamentPersonenData.volgordeFouten(oordelen: oordelen) {
                                startNieuweRonde(met: fout)
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .disabled(OudeTestamentPersonenData.volgordeFouten(oordelen: oordelen) == nil)

                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: OudeTestamentPersonenData.maakVolgordeVoorRonde())
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    } else {
                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: OudeTestamentPersonenData.maakVolgordeVoorRonde())
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

    private func vraagView(_ v: OTPersoonVraag) -> some View {
        NieuweTestamentOefenDogmatiekLayout(
            voortgangLabel: "Vraag \(index + 1) van \(volgorde.count)",
            promptInhoud: {
                OTPersoonMarkdownGestapeld(
                    markdown: v.promptMarkdown,
                    blokSpacing: 12,
                    eersteBlokIsPersoonsnaam: true
                )
            },
            tussenPromptEnPlaceholder: {
                Text("Wat weet je hier zelf al van? Tik op Laat antwoord zien om de informatie te zien.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            },
            antwoordZichtbaar: antwoordZichtbaar,
            antwoordInhoud: {
                OTPersoonMarkdownGestapeld(
                    markdown: v.antwoordMarkdown,
                    blokSpacing: 16
                )
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

#Preview {
    NavigationStack {
        OudeTestamentPersonenUitOTView()
    }
}
