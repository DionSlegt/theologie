//
//  OudeTestamentHs2JacobsonChanViews.swift
//  Studie
//
//  Hs 2 Jacobson & Chan
//

import SwiftUI

// MARK: - Gedeelde markdown (witregels = `\\n\\n` tussen blokken)

private struct Hs2MarkdownBlokken: View {
    let markdown: String
    var blokSpacing: CGFloat = 14
    var baseFont: Font = .body

    private var blokken: [String] {
        markdown
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: blokSpacing) {
            ForEach(Array(blokken.enumerated()), id: \.offset) { _, blok in
                Group {
                    if let attributed = try? AttributedString(markdown: blok) {
                        Text(attributed)
                    } else {
                        Text(blok)
                    }
                }
                .font(baseFont)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

/// Antwoord in een eigen scrollveld: lange lijsten blijven leesbaar op kleine schermen.
private enum Hs2AntwoordOpmaak {
    case standaard
    case canon
    case informatief
}

private struct Hs2JacobsonChanOefenAntwoordScroll: View {
    let markdown: String
    var opmaak: Hs2AntwoordOpmaak = .standaard

    var body: some View {
        ScrollView {
            Group {
                switch opmaak {
                case .canon:
                    Hs2CanonAntwoordBlokken(markdown: markdown)
                case .informatief:
                    Hs2InformatiefAntwoordBlokken(markdown: markdown)
                case .standaard:
                    Hs2MarkdownBlokken(
                        markdown: markdown,
                        blokSpacing: 10,
                        baseFont: .body.weight(.semibold)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: opmaak == .standaard ? 380 : 520)
    }
}

/// Oefenen: term → Laat antwoord zien → Goed/Fout (meerdere vragen).
struct StudieBegrippenTyperenVraag: Identifiable {
    let id: String
    let termMarkdown: String
    let antwoordMarkdown: String
}

private typealias Hs2JacobsonChanOefenVraag = StudieBegrippenTyperenVraag

/// Elk onderdeel als eigen markdown-blok (`\\n\\n`).
private enum Hs2JacobsonChanOpmaak {
    static func antwoordPerRegel(_ regels: [String]) -> String {
        regels.joined(separator: "\n\n")
    }

    static func canonBoek(_ n: Int, _ naam: String) -> String {
        "**\(n).** \(naam)"
    }
}

/// Canon-antwoorden: titels en secties groter/vet; nummers vet via markdown, boeknamen regulier.
private struct Hs2CanonAntwoordBlokken: View {
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

    private func isHoofdtitel(_ blok: String) -> Bool {
        let l = blok.lowercased()
        return l.contains("canon") || l.contains("tenach")
    }

    private func isSubsectie(_ blok: String) -> Bool {
        ["**Vroege Profeten**", "**Late Profeten**"].contains(blok)
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
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(blokken.enumerated()), id: \.offset) { _, blok in
                if isAlleenVet(blok) {
                    if isHoofdtitel(blok) {
                        tekst(blok, font: .title2.weight(.bold))
                            .padding(.bottom, 4)
                    } else if isSubsectie(blok) {
                        tekst(blok, font: .subheadline.weight(.semibold))
                            .padding(.top, 2)
                    } else {
                        tekst(blok, font: .headline.weight(.bold))
                            .padding(.top, 6)
                    }
                } else {
                    tekst(blok, font: .body)
                }
            }
        }
    }
}

/// Informatieve antwoorden (Septuagint e.d.): lopende tekst en bullets regulier; koppen groter/vet.
private struct Hs2InformatiefAntwoordBlokken: View {
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

    private func isKopRegel(_ blok: String) -> Bool {
        if isAlleenVet(blok) && blok.contains(":") {
            return true
        }
        return isAlleenVet(blok)
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
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blokken.enumerated()), id: \.offset) { _, blok in
                if isKopRegel(blok) {
                    tekst(blok, font: .headline.weight(.bold))
                        .padding(.top, 4)
                } else {
                    tekst(blok, font: .body)
                }
            }
        }
    }
}

private enum Hs2CanonOTInhoud {
    static let joods = Hs2JacobsonChanOpmaak.antwoordPerRegel([
        "**Joodse canon (Tenach)**",
        "**Tora**",
        Hs2JacobsonChanOpmaak.canonBoek(1, "Genesis"),
        Hs2JacobsonChanOpmaak.canonBoek(2, "Exodus"),
        Hs2JacobsonChanOpmaak.canonBoek(3, "Leviticus"),
        Hs2JacobsonChanOpmaak.canonBoek(4, "Numeri"),
        Hs2JacobsonChanOpmaak.canonBoek(5, "Deuteronomium"),
        "**Profeten**",
        "**Vroege Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(6, "Jozua"),
        Hs2JacobsonChanOpmaak.canonBoek(7, "Rechters"),
        Hs2JacobsonChanOpmaak.canonBoek(8, "Samuël"),
        Hs2JacobsonChanOpmaak.canonBoek(9, "Koningen"),
        "**Late Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(10, "Jesaja"),
        Hs2JacobsonChanOpmaak.canonBoek(11, "Jeremia"),
        Hs2JacobsonChanOpmaak.canonBoek(12, "Ezechiël"),
        """
        **13.** De Twaalf Profeten

        - Hosea
        - Joël
        - Amos
        - Obadja
        - Jona
        - Micha
        - Nahum
        - Habakuk
        - Zefanja
        - Haggai
        - Zacharia
        - Maleachi
        """,
        "**Geschriften**",
        Hs2JacobsonChanOpmaak.canonBoek(14, "Psalmen"),
        Hs2JacobsonChanOpmaak.canonBoek(15, "Job"),
        Hs2JacobsonChanOpmaak.canonBoek(16, "Spreuken"),
        Hs2JacobsonChanOpmaak.canonBoek(17, "Ruth"),
        Hs2JacobsonChanOpmaak.canonBoek(18, "Hooglied"),
        Hs2JacobsonChanOpmaak.canonBoek(19, "Prediker"),
        Hs2JacobsonChanOpmaak.canonBoek(20, "Klaagliederen"),
        Hs2JacobsonChanOpmaak.canonBoek(21, "Esther"),
        Hs2JacobsonChanOpmaak.canonBoek(22, "Daniël"),
        Hs2JacobsonChanOpmaak.canonBoek(23, "Ezra-Nehemia"),
        Hs2JacobsonChanOpmaak.canonBoek(24, "Kronieken"),
    ])

    static let protestants = Hs2JacobsonChanOpmaak.antwoordPerRegel([
        "**Protestantse canon**",
        "**Wet (Pentateuch)**",
        Hs2JacobsonChanOpmaak.canonBoek(1, "Genesis"),
        Hs2JacobsonChanOpmaak.canonBoek(2, "Exodus"),
        Hs2JacobsonChanOpmaak.canonBoek(3, "Leviticus"),
        Hs2JacobsonChanOpmaak.canonBoek(4, "Numeri"),
        Hs2JacobsonChanOpmaak.canonBoek(5, "Deuteronomium"),
        "**Historische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(6, "Jozua"),
        Hs2JacobsonChanOpmaak.canonBoek(7, "Rechters"),
        Hs2JacobsonChanOpmaak.canonBoek(8, "Ruth"),
        Hs2JacobsonChanOpmaak.canonBoek(9, "1 Samuël"),
        Hs2JacobsonChanOpmaak.canonBoek(10, "2 Samuël"),
        Hs2JacobsonChanOpmaak.canonBoek(11, "1 Koningen"),
        Hs2JacobsonChanOpmaak.canonBoek(12, "2 Koningen"),
        Hs2JacobsonChanOpmaak.canonBoek(13, "1 Kronieken"),
        Hs2JacobsonChanOpmaak.canonBoek(14, "2 Kronieken"),
        Hs2JacobsonChanOpmaak.canonBoek(15, "Ezra"),
        Hs2JacobsonChanOpmaak.canonBoek(16, "Nehemia"),
        Hs2JacobsonChanOpmaak.canonBoek(17, "Esther"),
        "**Poëtische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(18, "Job"),
        Hs2JacobsonChanOpmaak.canonBoek(19, "Psalmen"),
        Hs2JacobsonChanOpmaak.canonBoek(20, "Spreuken"),
        Hs2JacobsonChanOpmaak.canonBoek(21, "Prediker"),
        Hs2JacobsonChanOpmaak.canonBoek(22, "Hooglied"),
        "**Grote Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(23, "Jesaja"),
        Hs2JacobsonChanOpmaak.canonBoek(24, "Jeremia"),
        Hs2JacobsonChanOpmaak.canonBoek(25, "Klaagliederen"),
        Hs2JacobsonChanOpmaak.canonBoek(26, "Ezechiël"),
        Hs2JacobsonChanOpmaak.canonBoek(27, "Daniël"),
        "**Kleine Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(28, "Hosea"),
        Hs2JacobsonChanOpmaak.canonBoek(29, "Joël"),
        Hs2JacobsonChanOpmaak.canonBoek(30, "Amos"),
        Hs2JacobsonChanOpmaak.canonBoek(31, "Obadja"),
        Hs2JacobsonChanOpmaak.canonBoek(32, "Jona"),
        Hs2JacobsonChanOpmaak.canonBoek(33, "Micha"),
        Hs2JacobsonChanOpmaak.canonBoek(34, "Nahum"),
        Hs2JacobsonChanOpmaak.canonBoek(35, "Habakuk"),
        Hs2JacobsonChanOpmaak.canonBoek(36, "Zefanja"),
        Hs2JacobsonChanOpmaak.canonBoek(37, "Haggai"),
        Hs2JacobsonChanOpmaak.canonBoek(38, "Zacharia"),
        Hs2JacobsonChanOpmaak.canonBoek(39, "Maleachi"),
    ])

    static let roomsKatholiek = Hs2JacobsonChanOpmaak.antwoordPerRegel([
        "**Rooms-katholieke canon**",
        "**Wet (Pentateuch)**",
        Hs2JacobsonChanOpmaak.canonBoek(1, "Genesis"),
        Hs2JacobsonChanOpmaak.canonBoek(2, "Exodus"),
        Hs2JacobsonChanOpmaak.canonBoek(3, "Leviticus"),
        Hs2JacobsonChanOpmaak.canonBoek(4, "Numeri"),
        Hs2JacobsonChanOpmaak.canonBoek(5, "Deuteronomium"),
        "**Historische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(6, "Jozua"),
        Hs2JacobsonChanOpmaak.canonBoek(7, "Rechters"),
        Hs2JacobsonChanOpmaak.canonBoek(8, "Ruth"),
        Hs2JacobsonChanOpmaak.canonBoek(9, "1 Samuël"),
        Hs2JacobsonChanOpmaak.canonBoek(10, "2 Samuël"),
        Hs2JacobsonChanOpmaak.canonBoek(11, "1 Koningen"),
        Hs2JacobsonChanOpmaak.canonBoek(12, "2 Koningen"),
        Hs2JacobsonChanOpmaak.canonBoek(13, "1 Kronieken"),
        Hs2JacobsonChanOpmaak.canonBoek(14, "2 Kronieken"),
        Hs2JacobsonChanOpmaak.canonBoek(15, "Ezra"),
        Hs2JacobsonChanOpmaak.canonBoek(16, "Nehemia"),
        Hs2JacobsonChanOpmaak.canonBoek(17, "Tobit **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(18, "Judit **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(19, "Esther **(toevoeging DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(20, "1 Makkabeeën **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(21, "2 Makkabeeën **(DC)**"),
        "**Wijsheids- en poëtische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(22, "Job"),
        Hs2JacobsonChanOpmaak.canonBoek(23, "Psalmen"),
        Hs2JacobsonChanOpmaak.canonBoek(24, "Spreuken"),
        Hs2JacobsonChanOpmaak.canonBoek(25, "Prediker"),
        Hs2JacobsonChanOpmaak.canonBoek(26, "Hooglied"),
        Hs2JacobsonChanOpmaak.canonBoek(27, "Wijsheid van Salomo **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(28, "Jezus Sirach / Ecclesiasticus **(DC)**"),
        "**Grote Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(29, "Jesaja"),
        Hs2JacobsonChanOpmaak.canonBoek(30, "Jeremia"),
        Hs2JacobsonChanOpmaak.canonBoek(31, "Klaagliederen"),
        Hs2JacobsonChanOpmaak.canonBoek(32, "Baruch (inclusief Brief van Jeremia) **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(33, "Ezechiël"),
        Hs2JacobsonChanOpmaak.canonBoek(34, "Daniël **(toevoeging DC)**"),
        "**Kleine Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(35, "Hosea"),
        Hs2JacobsonChanOpmaak.canonBoek(36, "Joël"),
        Hs2JacobsonChanOpmaak.canonBoek(37, "Amos"),
        Hs2JacobsonChanOpmaak.canonBoek(38, "Obadja"),
        Hs2JacobsonChanOpmaak.canonBoek(39, "Jona"),
        Hs2JacobsonChanOpmaak.canonBoek(40, "Micha"),
        Hs2JacobsonChanOpmaak.canonBoek(41, "Nahum"),
        Hs2JacobsonChanOpmaak.canonBoek(42, "Habakuk"),
        Hs2JacobsonChanOpmaak.canonBoek(43, "Zefanja"),
        Hs2JacobsonChanOpmaak.canonBoek(44, "Haggai"),
        Hs2JacobsonChanOpmaak.canonBoek(45, "Zacharia"),
        Hs2JacobsonChanOpmaak.canonBoek(46, "Maleachi"),
    ])

    static let oostersOrthodox = Hs2JacobsonChanOpmaak.antwoordPerRegel([
        "**Oosters-orthodoxe canon**",
        "**Wet (Pentateuch)**",
        Hs2JacobsonChanOpmaak.canonBoek(1, "Genesis"),
        Hs2JacobsonChanOpmaak.canonBoek(2, "Exodus"),
        Hs2JacobsonChanOpmaak.canonBoek(3, "Leviticus"),
        Hs2JacobsonChanOpmaak.canonBoek(4, "Numeri"),
        Hs2JacobsonChanOpmaak.canonBoek(5, "Deuteronomium"),
        "**Historische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(6, "Jozua"),
        Hs2JacobsonChanOpmaak.canonBoek(7, "Rechters"),
        Hs2JacobsonChanOpmaak.canonBoek(8, "Ruth"),
        Hs2JacobsonChanOpmaak.canonBoek(9, "1 Koninkrijken (= 1 Samuël)"),
        Hs2JacobsonChanOpmaak.canonBoek(10, "2 Koninkrijken (= 2 Samuël)"),
        Hs2JacobsonChanOpmaak.canonBoek(11, "3 Koninkrijken (= 1 Koningen)"),
        Hs2JacobsonChanOpmaak.canonBoek(12, "4 Koninkrijken (= 2 Koningen)"),
        Hs2JacobsonChanOpmaak.canonBoek(13, "1 Paralipomenon (= 1 Kronieken)"),
        Hs2JacobsonChanOpmaak.canonBoek(14, "2 Paralipomenon (= 2 Kronieken)"),
        Hs2JacobsonChanOpmaak.canonBoek(15, "1 Esdras **(extra orthodox)**"),
        Hs2JacobsonChanOpmaak.canonBoek(16, "2 Esdras (= Ezra-Nehemia)"),
        Hs2JacobsonChanOpmaak.canonBoek(17, "Tobit **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(18, "Judit **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(19, "Esther **(toevoeging DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(20, "1 Makkabeeën **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(21, "2 Makkabeeën **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(22, "3 Makkabeeën **(extra orthodox)**"),
        "**Wijsheids- en poëtische boeken**",
        Hs2JacobsonChanOpmaak.canonBoek(23, "Psalmen"),
        Hs2JacobsonChanOpmaak.canonBoek(24, "Psalm 151 **(extra orthodox)**"),
        Hs2JacobsonChanOpmaak.canonBoek(25, "Job"),
        Hs2JacobsonChanOpmaak.canonBoek(26, "Oden (Gebed van Manasse) **(extra orthodox)**"),
        Hs2JacobsonChanOpmaak.canonBoek(27, "Spreuken"),
        Hs2JacobsonChanOpmaak.canonBoek(28, "Prediker"),
        Hs2JacobsonChanOpmaak.canonBoek(29, "Hooglied"),
        Hs2JacobsonChanOpmaak.canonBoek(30, "Wijsheid van Salomo **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(31, "Jezus Sirach / Ecclesiasticus **(DC)**"),
        "**Kleine Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(32, "Hosea"),
        Hs2JacobsonChanOpmaak.canonBoek(33, "Joël"),
        Hs2JacobsonChanOpmaak.canonBoek(34, "Amos"),
        Hs2JacobsonChanOpmaak.canonBoek(35, "Obadja"),
        Hs2JacobsonChanOpmaak.canonBoek(36, "Jona"),
        Hs2JacobsonChanOpmaak.canonBoek(37, "Micha"),
        Hs2JacobsonChanOpmaak.canonBoek(38, "Nahum"),
        Hs2JacobsonChanOpmaak.canonBoek(39, "Habakuk"),
        Hs2JacobsonChanOpmaak.canonBoek(40, "Zefanja"),
        Hs2JacobsonChanOpmaak.canonBoek(41, "Haggai"),
        Hs2JacobsonChanOpmaak.canonBoek(42, "Zacharia"),
        Hs2JacobsonChanOpmaak.canonBoek(43, "Maleachi"),
        "**Grote Profeten**",
        Hs2JacobsonChanOpmaak.canonBoek(44, "Jesaja"),
        Hs2JacobsonChanOpmaak.canonBoek(45, "Jeremia"),
        Hs2JacobsonChanOpmaak.canonBoek(46, "Baruch **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(47, "Klaagliederen"),
        Hs2JacobsonChanOpmaak.canonBoek(48, "Brief van Jeremia **(DC)**"),
        Hs2JacobsonChanOpmaak.canonBoek(49, "Ezechiël"),
        Hs2JacobsonChanOpmaak.canonBoek(50, "Daniël **(toevoeging DC)**"),
        "**Appendix**",
        Hs2JacobsonChanOpmaak.canonBoek(51, "4 Makkabeeën **(appendix)**"),
    ])
}

private enum Hs2OntwikkelingOTVragenData {
    /// Vraag 1 = overzicht; daarna 6 losse vragen met toelichting.
    static let alle: [Hs2JacobsonChanOefenVraag] = [
        .init(
            id: "ontwikkeling-ot-zes-stappen",
            termMarkdown: "**Geef de 6 stappen waarin de ontwikkeling van het OT kan worden omschreven.**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "**1. Mondelinge overlevering**",
                "**2. Kern Joodse canon (De Pentateuch)**",
                "**3. Uitbreiding en graduele vaststelling**",
                "**4. Septuaginta (LXX)**",
                "**5. Bevestiging op concilie van Jamnia**",
                "**6. Reformatie**",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-1-mondeling",
            termMarkdown: "**1. Mondelinge overlevering**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "In de vroegste fase werden tradities, verhalen en liederen mondeling doorgegeven. Voorbeelden hiervan zijn zeer oude teksten zoals het lied van Mozes en Mirjam en het lied van Debora.",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-2-pentateuch",
            termMarkdown: "**2. Kern Joodse canon (De Pentateuch)**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "De eerste vijf boeken van de Bijbel vormden de eerste vaste kern. Dit deel was als eerste voltooid en genoot binnen de Joodse gemeenschap het meeste gezag.",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-3-uitbreiding",
            termMarkdown: "**3. Uitbreiding en graduele vaststelling**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Na de Pentateuch volgde de verzameling van de Profeten en uiteindelijk de overige Geschriften. Dit was een langdurig proces waarbij boeken geleidelijk als gezaghebbend werden aanvaard.",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-4-lxx",
            termMarkdown: "**4. Septuaginta (LXX)**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Tussen 300 en 200 v.Chr. ontstond een Griekse vertaling voor Joden in de diaspora. Deze versie bevatte vijftien extra boeken (de apocriefen of deuterocanonieke boeken) die niet in de Hebreeuwse lijst stonden.",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-5-jamnia",
            termMarkdown: "**5. Bevestiging op concilie van Jamnia**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Rond 90 n.Chr. kwamen Joodse geleerden in Jamnia (Yabneh) samen. Hier stelden zij de officiële lijst van heilige boeken vast voor het Rabbijnse Jodendom, waarbij zij alleen de Hebreeuwse teksten erkenden.",
            ])
        ),
        .init(
            id: "ontwikkeling-ot-stap-6-reformatie",
            termMarkdown: "**6. Reformatie**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Tijdens de Reformatie keerden protestanten terug naar deze kortere Hebreeuwse lijst (zonder de extra Griekse boeken). Ze behielden echter de indeling en volgorde van de Septuaginta (Wet, Geschiedenis, Poëzie, Profeten).",
            ])
        ),
    ]
}

private enum Hs2SeptuagintVragenData {
    static let alle: [Hs2JacobsonChanOefenVraag] = [
        .init(
            id: "septuagint-kenmerken",
            termMarkdown: "**Septuagint**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "De **Septuaginta** (vaak afgekort als **LXX**) is de Griekse vertaling van het Hebreeuwse Oude Testament, die tussen ongeveer 300 en 200 v.Chr. tot stand kwam in Alexandrië.",
                "De belangrijkste kenmerken zijn:",
                """
                - **Doelgroep:** De vertaling werd gemaakt voor Joden in de diaspora die door de hellenisering Grieks spraken als hun dagelijkse taal.
                - **Inhoud:** De Septuaginta is uitgebreider dan de Hebreeuwse canon en bevat extra boeken, die we nu kennen als de **deuterocanonieke** of apocriefe boeken.
                - **Structuur:** De volgorde van de boeken in moderne Nederlandse en Engelse vertalingen volgt de indeling van de Septuaginta (Wet, Geschiedenis, Poëzie, Profeten) in plaats van de Joodse indeling (Wet, Profeten, Geschriften).
                - **Betekenis:** Het was de Bijbel die door de vroege christelijke kerk en de auteurs van het Nieuwe Testament het meest werd gebruikt.
                """,
                "Wist je dat de naam '70' (LXX) verwijst naar de legende dat zeventig (of 72) geleerden de tekst onafhankelijk van elkaar vertaalden en tot exact hetzelfde resultaat kwamen?",
            ])
        ),
        .init(
            id: "vulgata-kenmerken",
            termMarkdown: "**Vulgata**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "De **Vulgata** is de Latijnse \"volksvertaling\" van de Bijbel, die aan het eind van de 4e eeuw werd voltooid door Hiëronymus (Jerome).",
                "Hier zijn de belangrijkste redenen waarom deze vertaling zo belangrijk is voor de Katholieke Kerk:",
                """
                - **Terug naar de bron:** In tegenstelling tot eerdere vertalingen, vertaalde Hiëronymus het Oude Testament rechtstreeks vanuit het Hebreeuws en Aramees ("Hebraica Veritas") in plaats van uit het Grieks.
                - **Gezaghebbende status:** De Vulgata was gedurende meer dan duizend jaar vrijwel de enige Bijbel die in het westerse christendom werd gebruikt en groeide zo uit tot de officiële tekst van de Rooms-Katholieke Kerk.
                - **Volledige canon:** De Vulgata bevat de deuterocanonieke boeken (zoals Tobit en Judith). Hoewel Hiëronymus zelf de voorkeur gaf aan de kortere Hebreeuwse lijst, voegde hij deze boeken toe omdat de vroege kerk ze als heilig beschouwde.
                """,
                "Tegenwoordig gebruiken katholieke vertalingen vaker de originele Hebreeuwse en Griekse teksten, maar de Vulgata blijft een fundamentele tekst in hun traditie.",
            ])
        ),
        .init(
            id: "traditie-bijbelbron",
            termMarkdown: "**Traditie en Bijbelbron**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "**Oosters-Orthodox: De Septuaginta (LXX)**",
                "- **Waarom:** Dit was de Bijbel van de vroege christelijke kerk en de auteurs van het Nieuwe Testament. De Orthodoxe Kerk zet deze traditie voort en beschouwt de Griekse tekst als gezaghebbender dan de Hebreeuwse bronteksten.",
                "**Rooms-Katholiek: De Vulgata**",
                "- **Waarom:** Hiëronymus maakte deze Latijnse vertaling eind 4e eeuw om de Bijbel voor het gewone volk (*vulgus*) toegankelijk te maken. Het werd de officiële tekst van de kerk en bleef in het Westen meer dan duizend jaar de enige standaard.",
                "**Protestants: De Hebreeuwse canon (Tanach) met Griekse indeling**",
                "- **Waarom:** Tijdens de Reformatie greep men terug op de boeken die in de oorspronkelijke Hebreeuwse brontekst stonden, omdat men die als meest gezaghebbend beschouwde. Men behield wel de indeling van de Septuaginta (Wet, Geschiedenis, Poëzie, Profeten) omdat deze volgorde inmiddels vertrouwd was.",
            ])
        ),
    ]
}

private enum Hs2CanonOTVragenData {
    static let alle: [Hs2JacobsonChanOefenVraag] = [
        .init(
            id: "canon-protestants",
            termMarkdown: "**Protestantse canon**",
            antwoordMarkdown: Hs2CanonOTInhoud.protestants
        ),
        .init(
            id: "canon-joods",
            termMarkdown: "**Joodse canon (Tenach)**",
            antwoordMarkdown: Hs2CanonOTInhoud.joods
        ),
        .init(
            id: "canon-rooms-katholiek",
            termMarkdown: "**Rooms-katholieke canon**",
            antwoordMarkdown: Hs2CanonOTInhoud.roomsKatholiek
        ),
        .init(
            id: "canon-oosters-orthodox",
            termMarkdown: "**Oosters-orthodoxe canon**",
            antwoordMarkdown: Hs2CanonOTInhoud.oostersOrthodox
        ),
        .init(
            id: "canon-verschillen",
            termMarkdown: "**Verklaar de verschillen in canons**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "**Joodse canon (Tenach):** Bevat alleen de boeken die oorspronkelijk in het Hebreeuws en Aramees zijn geschreven. De Vulgata speelt hier geen rol, omdat deze canon de Joodse brontekst zelf is waaruit later vertaald werd.",
                "**Protestantse canon:** Bevat precies dezelfde boeken als de Tenach, maar volgt de Griekse volgorde. Protestanten verwierpen de extra boeken uit de Vulgata als \"apocrief\" omdat ze terug wilden naar de oorspronkelijke Hebreeuwse bron.",
                "**Rooms-katholieke canon:** Bevat de Hebreeuwse boeken plus een selectie Griekse boeken, de deuterocanonieke boeken. Deze lijst is gebaseerd op de **Vulgata** (eind van de 4e eeuw n.Chr.), de Latijnse vertaling van Hiëronymus die eeuwenlang de officiële tekst van de katholieke kerk was en een specifieke selectie uit de Griekse bronnen bevatte.",
                "**Orthodoxe canon:** De meest uitgebreide canon, gebaseerd op de volledige Griekse Septuaginta (tussen 300 en 200 v.Chr. ontstaan). Omdat de Orthodoxe kerken de Griekse traditie bleven volgen en niet overstapten op de Latijnse Vulgata, behielden zij extra boeken (zoals 3 Makkabeeën) die in de Vulgata ontbraken.",
            ])
        ),
    ]
}

private enum Hs2VerschilAchterInTekstVragenData {
    static let alle: [Hs2JacobsonChanOefenVraag] = [
        .init(
            id: "verschil-achter-tekst",
            termMarkdown: "**De wereld ‘achter’ de tekst**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Dit is de historische context van de auteur. Het gaat om de specifieke tijd, sociale gebruiken, religieuze praktijken en politieke gebeurtenissen waarin de tekst is ontstaan en die bepaalden wat de tekst oorspronkelijk betekende.",
            ])
        ),
        .init(
            id: "verschil-in-tekst",
            termMarkdown: "**De wereld ‘in’ de tekst**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "Dit is de geschiedenis zoals die in het verhaal zelf wordt verteld. Dit zijn de historische claims of verhalen die de tekst presenteert over het verleden.",
            ])
        ),
        .init(
            id: "verschil-voorbeelden",
            termMarkdown: "**Voorbeelden: achter en in de tekst**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "**Voorbeeld 1: Exodus**",
                "**Wereld achter de tekst:**",
                "Je onderzoekt de historische achtergrond: slavernij in Egypte, de macht van Egypte, de positie van kleine volken in het Nabije Oosten en de vraag hoe Israël als volk is ontstaan.",
                "**Wereld in de tekst:**",
                "Je kijkt naar het verhaal zelf: Mozes, farao, de plagen, de doortocht door de zee, de woestijnreis en hoe God wordt voorgesteld als bevrijder.",
                "**Kort:** Achter de tekst = historische Egypte-context. In de tekst = het verhaal van Mozes en de bevrijding.",
                "**Voorbeeld 2: Daniël**",
                "**Wereld achter de tekst:**",
                "Je kijkt naar de Hellenistische periode, vooral de druk op Joden onder Antiochus IV Epiphanes en de spanning rond hellenisering.",
                "**Wereld in de tekst:**",
                "Je kijkt naar Daniël aan het hof, dromen, visioenen, koningen, beesten en de boodschap dat God uiteindelijk sterker is dan aardse rijken.",
                "**Kort:** Achter de tekst = Joodse onderdrukking in de Hellenistische tijd. In de tekst = Daniël, visioenen en Gods koningschap.",
                "**Voorbeeld 3: 1 en 2 Koningen**",
                "**Wereld achter de tekst:**",
                "Je onderzoekt de historische situatie van Israël en Juda, de Assyrische dreiging, de Babylonische verovering en de ballingschap.",
                "**Wereld in de tekst:**",
                "Je kijkt naar hoe de boeken het verhaal vertellen: goede en slechte koningen, afval van God, profeten zoals Elia en Elisa, en uiteindelijk de val van Israël en Juda.",
                "**Kort:** Achter de tekst = Assyrië, Babylon en politieke geschiedenis. In de tekst = koningen, profeten en trouw/ontrouw aan God.",
                "**Voorbeeld 4: Genesis**",
                "**Wereld achter de tekst:**",
                "Je kijkt naar oude tradities uit het Nabije Oosten, mondelinge overlevering en de wereld van familiegroepen, migratie en stammen.",
                "**Wereld in de tekst:**",
                "Je kijkt naar Adam en Eva, Noach, Abraham, Sara, Isaak, Jakob, Jozef en de thema’s schepping, verbond, belofte en familie.",
                "**Kort:** Achter de tekst = oude Nabije Oosten en overlevering. In de tekst = de verhalen van schepping, aartsvaders en Gods belofte.",
            ])
        ),
    ]
}

// MARK: - Gedeelde oefenflow (Canon OT, …)

struct StudieInformatiefTyperenOefenView: View {
    let navigatieTitel: String
    let voettekstAfsluiting: String
    let vragen: [StudieBegrippenTyperenVraag]

    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: navigatieTitel,
            voettekstAfsluiting: voettekstAfsluiting,
            vragen: vragen,
            antwoordOpmaak: .informatief
        )
    }
}

private struct Hs2JacobsonChanOefenLijstView: View {
    let navigatieTitel: String
    let voettekstAfsluiting: String
    var antwoordOpmaak: Hs2AntwoordOpmaak = .standaard
    private let alleVragen: [Hs2JacobsonChanOefenVraag]

    @State private var actieveVolgorde: [Hs2JacobsonChanOefenVraag]
    @State private var index = 0
    @State private var antwoordZichtbaar = false
    @State private var rondeAf = false
    @State private var oordelen: [String: Bool] = [:]

    init(
        navigatieTitel: String,
        voettekstAfsluiting: String,
        vragen: [Hs2JacobsonChanOefenVraag],
        antwoordOpmaak: Hs2AntwoordOpmaak = .standaard
    ) {
        self.navigatieTitel = navigatieTitel
        self.voettekstAfsluiting = voettekstAfsluiting
        self.antwoordOpmaak = antwoordOpmaak
        self.alleVragen = vragen
        _actieveVolgorde = State(initialValue: vragen)
    }

    private var huidige: Hs2JacobsonChanOefenVraag? {
        guard index < actieveVolgorde.count else { return nil }
        return actieveVolgorde[index]
    }

    private var foutTelling: Int {
        actieveVolgorde.filter { oordelen[$0.id] == false }.count
    }

    private var scoreTekst: String {
        let ids = actieveVolgorde.map(\.id)
        let goed = ids.filter { oordelen[$0] == true }.count
        return "\(goed) van \(ids.count) goed"
    }

    var body: some View {
        Group {
            if rondeAf {
                afsluitView
            } else if let v = huidige {
                NieuweTestamentOefenDogmatiekLayout(
                    voortgangLabel: "Vraag \(index + 1) van \(actieveVolgorde.count)",
                    promptInhoud: {
                        Hs2MarkdownBlokken(
                            markdown: v.termMarkdown,
                            blokSpacing: 12,
                            baseFont: .title3.weight(.semibold)
                        )
                    },
                    tussenPromptEnPlaceholder: {
                        Text("Wat weet je hier zelf al van? Tik op Laat antwoord zien om de informatie te zien.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    },
                    antwoordZichtbaar: antwoordZichtbaar,
                    antwoordInhoud: {
                        Hs2JacobsonChanOefenAntwoordScroll(
                            markdown: v.antwoordMarkdown,
                            opmaak: antwoordOpmaak
                        )
                    },
                    toonVorige: index > 0,
                    onLaatAntwoordZien: { antwoordZichtbaar = true },
                    onVorige: gaNaarVorige,
                    onOordeelDirect: registreerOordeelEnVolgende
                )
            } else {
                ContentUnavailableView("Geen vragen", systemImage: "book.closed")
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(navigatieTitel)
        .navigationBarTitleDisplayMode(.inline)
        .nTBevestigingVoorQuizTerug()
    }

    private func gaNaarVorige() {
        guard index > 0 else { return }
        index -= 1
        antwoordZichtbaar = false
    }

    private func registreerOordeelEnVolgende(goed: Bool) {
        guard let v = huidige else { return }
        oordelen[v.id] = goed
        if index + 1 >= actieveVolgorde.count {
            rondeAf = true
            antwoordZichtbaar = false
            return
        }
        index += 1
        antwoordZichtbaar = false
    }

    /// Volledige lijst opnieuw (alle onderdelen).
    private func startHeleRonde() {
        actieveVolgorde = alleVragen
        index = 0
        antwoordZichtbaar = false
        rondeAf = false
        oordelen = [:]
    }

    /// Alleen vragen die in deze ronde op **Fout** stonden.
    private func startAlleenFoutenOpnieuw() {
        let fout = actieveVolgorde.filter { oordelen[$0.id] == false }
        guard !fout.isEmpty else { return }
        actieveVolgorde = fout
        index = 0
        antwoordZichtbaar = false
        rondeAf = false
        oordelen = [:]
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

                Text(voettekstAfsluiting)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    if foutTelling > 0 {
                        Button("Alleen fouten opnieuw", action: startAlleenFoutenOpnieuw)
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)

                        Button("Opnieuw (hele ronde)", action: startHeleRonde)
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    } else {
                        Button(action: startHeleRonde) {
                            Text("Opnieuw")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Canon OT

struct OudeTestamentHs2CanonOTView: View {
    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: "Canon OT",
            voettekstAfsluiting: "Je kunt Canon OT zo vaak opnieuw oefenen als je wilt.",
            vragen: Hs2CanonOTVragenData.alle,
            antwoordOpmaak: .canon
        )
    }
}

// MARK: - Septuagint

struct OudeTestamentHs2SeptuagintView: View {
    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: "Septuagint",
            voettekstAfsluiting: "Je kunt Septuagint zo vaak opnieuw oefenen als je wilt.",
            vragen: Hs2SeptuagintVragenData.alle,
            antwoordOpmaak: .informatief
        )
    }
}

// MARK: - Ontwikkeling OT

struct OudeTestamentHs2OntwikkelingOTView: View {
    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: "Ontwikkeling OT",
            voettekstAfsluiting: "Je kunt Ontwikkeling OT zo vaak opnieuw oefenen als je wilt.",
            vragen: Hs2OntwikkelingOTVragenData.alle,
            antwoordOpmaak: .informatief
        )
    }
}

// MARK: - Deuterocanonieke boeken

private enum Hs2DeuterocanoniekeBoekenVragenData {
    static let alle: [Hs2JacobsonChanOefenVraag] = [
        .init(
            id: "deuterocanoniek-alle",
            termMarkdown: "**Noem alle deuterocanonieke boeken**",
            antwoordMarkdown: Hs2JacobsonChanOpmaak.antwoordPerRegel([
                "**1. Historische boeken**",
                "**Tobit** en **Judith**",
                "**1 en 2 Makkabeeën**",
                "**1 Esdras** (alleen orthodox)",
                "**3 Makkabeeën** (alleen orthodox)",
                "**2. Wijsheidsliteratuur en poëzie**",
                "**Wijsheid van Salomo** en **Jezus Sirach** (Ecclesiasticus)",
                "**Psalm 151** (alleen orthodox)",
                "**Gebed van Manasse** (alleen orthodox)",
                "**3. Profeten (en toevoegingen)**",
                "**Baruch** en de **Brief van Jeremia**",
                "**Toevoegingen aan Esther**",
                "**Toevoegingen aan Daniël** (Susanna, Bel en de Draak)",
            ])
        ),
    ]
}

struct OudeTestamentHs2DeuterocanoniekeBoekenView: View {
    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: "Deuterocanonieke boeken",
            voettekstAfsluiting: "Je kunt dit onderdeel zo vaak opnieuw oefenen als je wilt.",
            vragen: Hs2DeuterocanoniekeBoekenVragenData.alle
        )
    }
}

// MARK: - Verschil achter en in de tekst

struct OudeTestamentHs2VerschilAchterEnInDeTekstView: View {
    var body: some View {
        Hs2JacobsonChanOefenLijstView(
            navigatieTitel: "Achter en in de tekst",
            voettekstAfsluiting: "Je kunt dit onderdeel zo vaak opnieuw oefenen als je wilt.",
            vragen: Hs2VerschilAchterInTekstVragenData.alle
        )
    }
}

#Preview("Hs 2 — overzicht") {
    NavigationStack {
        List {
            Section {
                NavigationLink("Canon OT") { OudeTestamentHs2CanonOTView() }
                NavigationLink("Septuagint") { OudeTestamentHs2SeptuagintView() }
                NavigationLink("Ontwikkeling OT") { OudeTestamentHs2OntwikkelingOTView() }
                NavigationLink("Deuterocanonieke boeken") { OudeTestamentHs2DeuterocanoniekeBoekenView() }
                NavigationLink("Verschil achter/in tekst") { OudeTestamentHs2VerschilAchterEnInDeTekstView() }
                NavigationLink("Begrippen") { OudeTestamentHs2BegrippenView() }
            } header: {
                Text("Hs 2 Jacobson & Chan")
            }
        }
    }
}
