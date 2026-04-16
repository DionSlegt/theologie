//
//  DogmatiekHoofdstuk3MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 3 — juiste regels en afleiders zoals in je studiemateriaal.
enum DogmatiekHoofdstuk3MultipleChoice {
    static let chapterTitle = "Hoofdstuk 3"

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "subordinatianisme/onderschikkingsleer":
            return "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen"
        case "adoptianisme":
            return "De opvatting dat Jezus op een bepaald moment door God als Zoon werd aangenomen"
        case "modalisme":
            return "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart"
        case "patripassianisme":
            return "De opvatting dat de Vader zelf geleden heeft aan het kruis"
        case "arianisme":
            return "De leer dat de Zoon het eerste en hoogste schepsel van God is"
        case "geloofsbelijdenis van nicea":
            return "De overtuiging dat Jezus volledig God is en één in wezen met de Vader"
        case "tritheïsme":
            return "De overtuiging dat Vader, Zoon en Geest drie afzonderlijke goden zijn"
        case "perichorese":
            return "De wederzijdse inwoning van Vader, Zoon en Geest als één God"
        case "doctrine van toe-eigening":
            return "Het toeschrijven van specifieke werken aan één Persoon binnen de Drie-eenheid"
        case "concilie van nicea":
            return "Bij welk concilie werd vastgesteld dat de Zoon één in wezen is met de Vader"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// Vaste set concilie-namen voor de Nicea-variant (definitie → term); wordt door de studieweergave geschud.
    static func fixedCouncilTermOptionPool(for card: DogmatiekCard) -> [String]? {
        guard normalizedTerm(card.term) == "concilie van nicea" else { return nil }
        return [
            "Tweede Vaticaans Concilie",
            "Concilie van Chalcedon",
            "Concilie van Efeze",
            "Concilie van Nicea",
        ]
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "subordinatianisme/onderschikkingsleer":
            return [
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
                "De opvatting dat Jezus op een bepaald moment door God als Zoon werd aangenomen",
                "De leer dat de Zoon het eerste en hoogste schepsel van God is",
            ]
        case "adoptianisme":
            return [
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
                "De leer dat de Zoon het eerste en hoogste schepsel van God is",
            ]
        case "modalisme":
            return [
                "De overtuiging dat Vader, Zoon en Geest drie afzonderlijke goden zijn",
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
                "De opvatting dat de Vader zelf geleden heeft aan het kruis",
            ]
        case "patripassianisme":
            return [
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
                "De leer dat de Zoon het eerste en hoogste schepsel van God is",
                "De opvatting dat Jezus op een bepaald moment door God als Zoon werd aangenomen",
            ]
        case "arianisme":
            return [
                "De opvatting dat Jezus op een bepaald moment door God als Zoon werd aangenomen",
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
            ]
        case "geloofsbelijdenis van nicea":
            return [
                "De leer dat de Zoon het eerste en hoogste schepsel van God is",
                "De opvatting dat Jezus op een bepaald moment door God als Zoon werd aangenomen",
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
            ]
        case "tritheïsme":
            return [
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
                "De wederzijdse inwoning van Vader, Zoon en Geest als één God",
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
            ]
        case "perichorese":
            return [
                "De overtuiging dat Vader, Zoon en Geest drie afzonderlijke goden zijn",
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
                "De leer dat de Zoon en Geest ondergeschikt zijn aan de Vader in rang en wezen",
            ]
        case "doctrine van toe-eigening":
            return [
                "De wederzijdse inwoning van Vader, Zoon en Geest als één God",
                "De overtuiging dat Vader, Zoon en Geest drie afzonderlijke goden zijn",
                "De leer dat God zich afwisselend als Vader, Zoon en Geest openbaart",
            ]
        case "concilie van nicea":
            return [
                "Bij welk concilie werden de twee naturen van Christus precies omschreven",
                "Bij welk concilie werd Maria als Theotokos bevestigd",
                "Bij welk concilie werd kerk en wereld in de twintigste eeuw hervormd",
            ]
        default:
            return [
                "Een andere betekenis die niet bij deze term hoort.",
                "Een begrip uit een ander hoofdstuk van je materiaal.",
                "Geen van deze beschrijvingen is de bedoelde definitie.",
            ]
        }
    }

    static func optionPool(for card: DogmatiekCard) -> [String] {
        [correctAnswerLine(for: card)] + distractors(for: card)
    }

    private static func normalizedTerm(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        s = s.replacingOccurrences(of: " / ", with: "/")
        s = s.replacingOccurrences(of: " /", with: "/")
        s = s.replacingOccurrences(of: "/ ", with: "/")
        return s
    }
}
