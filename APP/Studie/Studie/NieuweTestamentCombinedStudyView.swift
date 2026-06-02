//
//  NieuweTestamentCombinedStudyView.swift
//  Studie
//
//  Eén doorloop voor meerdere gekozen NT-onderdelen — lay-out en bediening gelijk aan Dogmatiek zelf invullen.
//

import SwiftUI

private struct NTGecombineerdMarkdown: View {
    let markdown: String
    var font: Font = .body

    var body: some View {
        Group {
            if let attributed = try? AttributedString(markdown: markdown) {
                Text(attributed)
            } else {
                Text(markdown)
            }
        }
        .font(font)
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NieuweTestamentCombinedStudyView: View {
    @Environment(\.dismiss) private var dismiss

    private let eersteRonde: [NieuweTestamentOefenKaart]

    @State private var volgorde: [NieuweTestamentOefenKaart]
    @State private var index = 0
    @State private var antwoordZichtbaar = false
    @State private var oordelen: [String: Bool] = [:]
    @State private var rondeAf = false
    @State private var toonFoutenBekijken = false

    init(selectie: Set<NieuweTestamentOefenOnderdeel>) {
        let gebouwd = NieuweTestamentOefenOnderdeel.bouwRonde(selectie: selectie)
        eersteRonde = gebouwd
        _volgorde = State(initialValue: gebouwd)
    }

    private var huidige: NieuweTestamentOefenKaart? {
        guard index < volgorde.count else { return nil }
        return volgorde[index]
    }

    private var goedTelling: Int {
        volgorde.filter { oordelen[$0.id] == true }.count
    }

    private var foutTelling: Int {
        volgorde.filter { oordelen[$0.id] == false }.count
    }

    private var foutKaarten: [NieuweTestamentOefenKaart] {
        volgorde.filter { oordelen[$0.id] == false }
    }

    var body: some View {
        Group {
            if rondeAf {
                if toonFoutenBekijken {
                    foutenBekijkenScherm
                } else {
                    rondeSamenvattingScherm
                }
            } else if let v = huidige {
                vraagView(v)
            } else {
                ContentUnavailableView("Geen vragen", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("Oefenen · zelf invullen")
        .navigationBarTitleDisplayMode(.inline)
        .nTBevestigingVoorQuizTerug()
    }

    private func startNieuweRonde(met items: [NieuweTestamentOefenKaart]) {
        volgorde = items
        index = 0
        rondeAf = false
        antwoordZichtbaar = false
        oordelen = [:]
        toonFoutenBekijken = false
    }

    private var rondeSamenvattingScherm: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Ronde afgerond")
                    .font(.title2.weight(.bold))

                VStack(spacing: 12) {
                    HStack {
                        Label("\(goedTelling) goed", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Spacer()
                    }
                    .font(.body.weight(.medium))

                    HStack {
                        Label("\(foutTelling) fout", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                    .font(.body.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.quaternary.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text("Volgorde: Hs 1–2 Powell, daarna Hs 3 Powell, tenslotte Achtenmeier als je dat onderdeel had aangevinkt.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

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

                    Button {
                        if let fout = NieuweTestamentOefenOnderdeel.foutenRonde(oorspronkelijk: volgorde, oordelen: oordelen) {
                            startNieuweRonde(met: fout)
                        }
                    } label: {
                        Text("Alleen foute opnieuw")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .disabled(NieuweTestamentOefenOnderdeel.foutenRonde(oorspronkelijk: volgorde, oordelen: oordelen) == nil)

                    Button {
                        startNieuweRonde(met: eersteRonde)
                    } label: {
                        Text("Opnieuw (zelfde selectie)")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        dismiss()
                    } label: {
                        Text("Terug naar Nieuwe Testament")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        startNieuweRonde(met: eersteRonde)
                    } label: {
                        Text("Opnieuw (zelfde selectie)")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        dismiss()
                    } label: {
                        Text("Klaar")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
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

                Text("Fout gemarkeerd (\(foutKaarten.count))")
                    .font(.title3.weight(.semibold))

                ForEach(foutKaarten) { kaart in
                    VStack(alignment: .leading, spacing: 12) {
                        promptBlok(kaart)
                        Text("Antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        antwoordBlok(kaart)
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

    private func vraagView(_ k: NieuweTestamentOefenKaart) -> some View {
        NieuweTestamentOefenDogmatiekLayout(
            voortgangLabel: "Vraag \(index + 1) van \(volgorde.count)",
            promptInhoud: { promptBlok(k) },
            tussenPromptEnPlaceholder: {
                if let hint = k.secundaireHint, !hint.isEmpty {
                    Text(hint)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            },
            antwoordZichtbaar: antwoordZichtbaar,
            antwoordInhoud: { antwoordBlok(k) },
            toonVorige: index > 0,
            onLaatAntwoordZien: { antwoordZichtbaar = true },
            onVorige: gaNaarVorigeVraag,
            onOordeelDirect: registreerOordeelEnVolgende
        )
    }

    @ViewBuilder
    private func promptBlok(_ k: NieuweTestamentOefenKaart) -> some View {
        switch k.promptWeergave {
        case .plainTitle3:
            Text(k.prompt)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        case .markdownTitle3Semibold:
            NTGecombineerdMarkdown(markdown: k.prompt, font: .title3.weight(.semibold))
        case .markdownStromingNaamTitle2Bold:
            if k.bron == .stromingen {
                Text("Stroming")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                NTStromingPromptView(prompt: k.prompt)
            } else {
                NTGecombineerdMarkdown(markdown: k.prompt, font: .title2.weight(.bold))
            }
        }
    }

    @ViewBuilder
    private func antwoordBlok(_ k: NieuweTestamentOefenKaart) -> some View {
        switch k.antwoordWeergave {
        case .plain:
            Text(k.antwoord)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        case .markdown:
            if k.bron == .stromingen {
                NTStromingAntwoordView(markdown: k.antwoord)
            } else if k.bron == .achtenmeierCanon && !k.id.contains("toets") {
                AchtenmeierGestapeldeInformatiefMarkdown(markdown: k.antwoord)
                    .font(.body.weight(.semibold))
                    .lineSpacing(4)
            } else {
                NTGecombineerdMarkdown(markdown: k.antwoord, font: .body.weight(.semibold))
                    .lineSpacing(4)
            }
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

#Preview {
    NavigationStack {
        NieuweTestamentCombinedStudyView(selectie: Set([.tijdsperiode, .begrippenHs12]))
    }
}
