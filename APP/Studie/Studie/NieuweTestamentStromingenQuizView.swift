//
//  NieuweTestamentStromingenQuizView.swift
//  Studie
//
//  Intro → 7 stromingen (willekeurige volgorde, elk apart) → slot alleen namen.
//

import SwiftUI

private struct NTStromingVraag: Identifiable {
    let id: String
    let prompt: String
    let antwoordMarkdown: String
}

// Prompt builder: naam + drie vaste rubrieken om zelf in te vullen.
private enum NTStromingPromptBuilder {
    static func prompt(naam: String) -> String {
        """
        **\(naam)**

        **Belangrijkste overtuigingen**

        **Culturele context**

        **Verhouding tot Jezus en/of het vroege christendom**
        """
    }
}

fileprivate enum NieuweTestamentStromingenData {
    static let introVraag = NTStromingVraag(
        id: "intro-typering",
        prompt: """
        Tijdens de periode van het Nieuwe Testament was de religieuze wereld zeer divers. \
        Geef een typering van de 7 belangrijkste religieuze en sociale stromingen.

        (Bedenk de stromingen; ze zullen hierna in beeld komen.)
        """,
        antwoordMarkdown: """
        Noteer voor jezelf welke zeven je kunt bedenken. Hierna volgt **elke stroming afzonderlijk** \
        met overtuigingen, culturele context en verhouding tot Jezus en het vroege christendom.
        """
    )

    static let kernVragen: [NTStromingVraag] = [
        NTStromingVraag(
            id: "farizeeen",
            prompt: NTStromingPromptBuilder.prompt(naam: "Farizeeën"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Streefden naar een heilig leven door navolging van de Thora.
            - Kenden gezag toe aan de mondelinge wet als aanvulling op de geschreven wet.
            - Geloofden in de opstanding van de doden, engelen en demonen en in de komst van een Messias.
            - Vonden dat het hele volk de reinheidswetten van de priester diende te houden: elk huis = tempel, elke tafel = altaar.

            **Culturele context**

            - Vrome leken en schriftgeleerden uit de middenklasse.
            - Drijvende kracht achter de lokale synagoges, waar zij onderwezen in de Thora.
            - Hun machtsbasis lag buiten Jeruzalem.

            **Verhouding tot Jezus en/of het vroege christendom**

            - In de evangeliën staan zij vaak tegenover Jezus, vooral in discussies over de juiste uitleg van de wet.
            - Jezus en de Farizeeën hadden ook theologische overeenkomsten, wat debat mogelijk maakte; Paulus was bijvoorbeeld een Farizeeër.
            """
        ),
        NTStromingVraag(
            id: "sadduceeen",
            prompt: NTStromingPromptBuilder.prompt(naam: "Sadduceeën"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Theologisch conservatief: accepteerden alleen de Pentateuch als gezaghebbende Schrift.
            - Verwierpen de opstanding, het laatste oordeel, engelen en geestelijke machten.
            - Religieuze focus lag volledig op het offerstelsel en de ceremoniële cultus in de tempel.

            **Culturele context**

            - Rijke, priesterlijke elite van Jeruzalem.
            - Hadden veel invloed in het Sanhedrin, de Joodse hoge raad.
            - Werkten politiek samen met de Romeinse bezetter om hun positie en de tempelorde te behouden.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Zagen Jezus als bedreiging, omdat zijn optreden onrust rond de tempel en Rome kon veroorzaken.
            - Waren betrokken bij het verzet tegen Jezus en later ook tegen de apostelen.
            - Na de verwoesting van de tempel in 70 n.Chr. verdwenen zij als groep uit de geschiedenis.
            """
        ),
        NTStromingVraag(
            id: "essenen",
            prompt: NTStromingPromptBuilder.prompt(naam: "Essenen"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Ascetische afscheidingsbeweging die de tempelcultus in Jeruzalem als corrupt en onrein zag.
            - Hielden zich aan strenge reinheidswetten, rituele baden en gezamenlijke maaltijden.
            - Zagen zichzelf als de "kinderen van het licht" en verwachtten een eindstrijd tussen goed en kwaad.

            **Culturele context**

            - Leefden vaak in afgezonderde, kloosterachtige gemeenschappen in de woestijn.
            - Hielden zich verre van de mainstream samenleving en wijdden zich aan arbeid en bestudering van de Schriften.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Worden niet direct genoemd in het Nieuwe Testament.
            - Er zijn parallellen met Johannes de Doper: bekering, doop en leven in de woestijn.
            - Ook lijken sommige praktijken op die van de vroege christelijke gemeenschap, zoals eenvoud, gezamenlijke maaltijden en sterk gemeenschapsleven.
            """
        ),
        NTStromingVraag(
            id: "samaritanen",
            prompt: NTStromingPromptBuilder.prompt(naam: "Samaritanen"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Zagen zichzelf als afstammelingen van het noordelijke rijk Israël.
            - Accepteerden alleen hun eigen versie van de Pentateuch en verwierpen de overige Joodse geschriften.
            - Geloofden dat de berg Gerizim, en niet de tempel in Jeruzalem, de ware plaats van aanbidding was.

            **Culturele context**

            - Woonden in Samaria, tussen Judea en Galilea.
            - Joden zagen hen als religieuze afvalligen of ketters; er bestond diepe vijandschap en religieus contact was strikt verboden.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Jezus doorbrak de sociale en religieuze grens door openlijk met Samaritanen om te gaan.
            - Voorbeelden: de Samaritaanse vrouw bij de bron en de gelijkenis van de barmhartige Samaritaan.
            - Na de opstanding werd Samaria een van de eerste gebieden waar het evangelie zich buiten Judea verspreidde.
            """
        ),
        NTStromingVraag(
            id: "opkomende-gnostiek",
            prompt: NTStromingPromptBuilder.prompt(naam: "Opkomende gnostiek"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Ging uit van een sterk dualisme: de geestelijke wereld was goed, de materiële wereld slecht.
            - De mens had een goddelijke vonk die gevangen zat in het lichaam.
            - Verlossing kwam door geheime goddelijke kennis (gnosis) die de mens bevrijdde.
            - Geloofden dat de materiële wereld was geschapen door een lagere, dwalende godheid, de Demiurg.

            **Culturele context**

            - De gnostiek kwam als volledige beweging vooral in de tweede eeuw n.Chr. tot bloei.
            - In de eerste eeuw waren er al vroege "proto-gnostische" ideeën aanwezig in de Grieks-Romeinse wereld.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Gnostici zagen Jezus vaak als geestelijke brenger van kennis.
            - Zij ontkenden of verzwakten dat Jezus werkelijk mens van vlees en bloed was.
            - Sommige nieuwtestamentische geschriften, zoals de brieven van Johannes, lijken te waarschuwen tegen zulke vroege ideeën.
            """
        ),
        NTStromingVraag(
            id: "polytheisme-grieks-romeins",
            prompt: NTStromingPromptBuilder.prompt(naam: "Polytheïsme van de Grieks-Romeinse godsdienst"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Kende veel goden (Zeus, Apollo, Aphrodite, Artemis) die verschillende aspecten van het leven beheersten.
            - Religie draaide om orthopraxis (juist handelen): rituelen, offers en publieke eerbied, minder om persoonlijke geloofsovertuiging.
            - Keizerverering werd toegevoegd als uiting van loyaliteit en patriottisme aan de staat.

            **Culturele context**

            - De godsdienst was overal aanwezig in de publieke ruimte via tempels, festivals en rituelen.
            - Het was diep verweven met de sociale en politieke structuren van het Romeinse Rijk.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Christenen weigerden andere goden en de keizer als god te vereren.
            - Daardoor werden zij soms gezien als atheïsten, omdat zij de traditionele goden afwezen.
            - Hun exclusieve geloof in één God botste met de religieuze en politieke verwachtingen van de Grieks-Romeinse samenleving.
            """
        ),
        NTStromingVraag(
            id: "mysteriegodsdiensten",
            prompt: NTStromingPromptBuilder.prompt(naam: "Mysteriegodsdiensten"),
            antwoordMarkdown: """
            **Belangrijkste overtuigingen**

            - Meer persoonlijke vorm van religie dan de publieke staatsgodsdienst.
            - Georganiseerd rond geheime mythen van godheden zoals Isis, Mithras of Dionysus.
            - Via geheime inwijdingsriten zocht de gelovige verbondenheid met een godheid, met de belofte van bescherming en een gezegend leven na de dood.

            **Culturele context**

            - Deze cultussen waren wijdverspreid.
            - Boden mensen in de anonimiteit van het Romeinse Rijk een gevoel van identiteit en behoren bij een besloten groep.

            **Verhouding tot Jezus en/of het vroege christendom**

            - Sommige Romeinen zagen het vroege christendom als een nieuwe mysteriegodsdienst vanwege eigen inwijdingsrituelen (doop) en geheime maaltijden (eucharistie).
            - Vroege berichten bevatten beschuldigingen van orgieën en kannibalisme, waarschijnlijk omdat christenen hun eucharistie een "liefdesmaaltijd" noemden en spraken over "het lichaam van Christus eten".
            """
        ),
    ]

    static let slotVraagAlleNamen = NTStromingVraag(
        id: "alle-stromingen-achter-elkaar",
        prompt: "Noem de zeven stromingen nu allemaal achter elkaar op.",
        antwoordMarkdown: """
        **Farizeeën**, **Sadduceeën**, **Essenen**, **Samaritanen**, \
        **Opkomende gnostiek**, **Polytheïsme van de Grieks-Romeinse godsdienst**, **Mysteriegodsdiensten**
        """
    )

    static func maakVolgordeVoorRonde() -> [NTStromingVraag] {
        [introVraag] + kernVragen.shuffled() + [slotVraagAlleNamen]
    }

    static func volgordeFouten(oordelen: [String: Bool]) -> [NTStromingVraag]? {
        let foutIds = Set(oordelen.filter { !$0.value }.map(\.key))
        guard !foutIds.isEmpty else { return nil }
        var out: [NTStromingVraag] = []
        if foutIds.contains(introVraag.id) { out.append(introVraag) }
        out += kernVragen.filter { foutIds.contains($0.id) }.shuffled()
        if foutIds.contains(slotVraagAlleNamen.id) { out.append(slotVraagAlleNamen) }
        guard !out.isEmpty else { return nil }
        return out
    }
}

private struct StromingenMarkdownAntwoord: View {
    let markdown: String

    var body: some View {
        Group {
            if let attributed = try? AttributedString(markdown: markdown) {
                Text(attributed)
            } else {
                Text(markdown)
            }
        }
        .font(.body)
        .foregroundStyle(.primary)
    }
}

struct NieuweTestamentStromingenQuizView: View {
    @State private var volgorde: [NTStromingVraag] = []
    @State private var index = 0
    @State private var antwoordZichtbaar = false
    @State private var oordelen: [String: Bool] = [:]
    @State private var rondeAf = false
    @State private var toonFoutenBekijken = false

    private var huidige: NTStromingVraag? {
        guard index < volgorde.count else { return nil }
        return volgorde[index]
    }

    private var scoreTekst: String {
        let ids = volgorde.map(\.id)
        let goed = NieuweTestamentQuizScore.aantalGoed(oordelen: oordelen, totaalIds: ids)
        return "\(goed) van \(ids.count) goed"
    }

    private var foutVragen: [NTStromingVraag] {
        volgorde.filter { oordelen[$0.id] == false }
    }

    private var foutTelling: Int { foutVragen.count }

    var body: some View {
        Group {
            if rondeAf {
                if toonFoutenBekijken {
                    stromingenFoutenBekijkenScherm
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
                startNieuweRonde(met: NieuweTestamentStromingenData.maakVolgordeVoorRonde())
            }
        }
        .nTBevestigingVoorQuizTerug()
    }

    private func startNieuweRonde(met items: [NTStromingVraag]) {
        volgorde = items
        index = 0
        rondeAf = false
        antwoordZichtbaar = false
        oordelen = [:]
        toonFoutenBekijken = false
    }

    private var stromingenFoutenBekijkenScherm: some View {
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
                        stromingenPromptInhoud(v)
                        Text("Antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        StromingenMarkdownAntwoord(markdown: v.antwoordMarkdown)
                            .font(.body.weight(.semibold))
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
                Text("Intro en slot blijven vooraan en achteraan; de zeven stromingen stonden door elkaar.")
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
                            if let fout = NieuweTestamentStromingenData.volgordeFouten(oordelen: oordelen) {
                                startNieuweRonde(met: fout)
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .disabled(NieuweTestamentStromingenData.volgordeFouten(oordelen: oordelen) == nil)

                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: NieuweTestamentStromingenData.maakVolgordeVoorRonde())
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    } else {
                        Button("Opnieuw (hele ronde)") {
                            startNieuweRonde(met: NieuweTestamentStromingenData.maakVolgordeVoorRonde())
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

    private func vraagView(_ v: NTStromingVraag) -> some View {
        NieuweTestamentOefenDogmatiekLayout(
            voortgangLabel: "Vraag \(index + 1) van \(volgorde.count)",
            promptInhoud: { stromingenPromptInhoud(v) },
            tussenPromptEnPlaceholder: {
                if v.id != NieuweTestamentStromingenData.introVraag.id,
                   v.id != NieuweTestamentStromingenData.slotVraagAlleNamen.id {
                    Text("Tik op Laat antwoord zien voor de typering.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            },
            antwoordZichtbaar: antwoordZichtbaar,
            antwoordInhoud: {
                StromingenMarkdownAntwoord(markdown: v.antwoordMarkdown)
                    .font(.body.weight(.semibold))
            },
            toonVorige: index > 0,
            onLaatAntwoordZien: { antwoordZichtbaar = true },
            onVorige: gaNaarVorigeVraag,
            onOordeelDirect: registreerOordeelEnVolgende
        )
    }

    @ViewBuilder
    private func stromingenPromptInhoud(_ v: NTStromingVraag) -> some View {
        if v.id == NieuweTestamentStromingenData.introVraag.id {
            Text(v.prompt)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        } else if v.id == NieuweTestamentStromingenData.slotVraagAlleNamen.id {
            Text(v.prompt)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text("Stroming")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            MarkdownAntwoordInlineTitle(markdown: v.prompt)
        }
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

/// Alleen voor korte promptregels met vet (stromingsnaam).
private struct MarkdownAntwoordInlineTitle: View {
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
    }
}

// MARK: - Gecombineerde oefening

enum NieuweTestamentStromingenOefenAdapter {
    static func kaartenVoorGecombineerd() -> [NieuweTestamentOefenKaart] {
        NieuweTestamentStromingenData.maakVolgordeVoorRonde().map { v in
            let isIntro = v.id == NieuweTestamentStromingenData.introVraag.id
            let isSlot = v.id == NieuweTestamentStromingenData.slotVraagAlleNamen.id
            let kern = !isIntro && !isSlot
            return NieuweTestamentOefenKaart(
                id: "nt-strom-\(v.id)",
                bron: .stromingen,
                promptWeergave: kern ? .markdownStromingNaamTitle2Bold : .plainTitle3,
                prompt: v.prompt,
                antwoordWeergave: .markdown,
                antwoord: v.antwoordMarkdown,
                secundaireHint: kern ? "Tik op Laat antwoord zien voor de typering." : nil
            )
        }
    }
}

#Preview {
    NavigationStack {
        NieuweTestamentStromingenQuizView()
    }
}
