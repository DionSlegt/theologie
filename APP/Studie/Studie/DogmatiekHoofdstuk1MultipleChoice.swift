//
//  DogmatiekHoofdstuk1MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 1 — juiste regels en afleiders zoals in je studiemateriaal.
enum DogmatiekHoofdstuk1MultipleChoice {
    static let chapterTitle = "Hoofdstuk 1"

    /// Extra regel onder de term (bijv. Wesleyaans kwadrilateraal).
    static func supplementaryPrompt(for card: DogmatiekCard) -> String? {
        switch normalizedTerm(card.term) {
        case "wesleyaans kwadrilateraal":
            return "Vraag: Waar bestaat het uit?"
        default:
            return nil
        }
    }

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "theologie":
            return "De studie van de dingen van God"
        case "dogma":
            return "Christelijke leer met hoogste autoriteit"
        case "wesleyaans kwadrilateraal":
            return "Schrift – Traditie – Verstand – Ervaring"
        case "sola scriptura":
            return "Alleen de Schrift heeft gezag"
        case "geloofsregel":
            return "Algemeen aanvaarde kern van de leer"
        case "geloofsbelijdenissen":
            return "Uitgewerkte formuleringen van geloof"
        case "orthodoxie":
            return "Overeenstemming met klassieke leer"
        case "ketterij":
            return "Afgewezen geloofsopvattingen"
        case "geestelijke disciplines/handelingen":
            return "Praktijken voor geestelijke groei"
        case "genademiddelen":
            return "Middelen waardoor God genade geeft"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "theologie":
            return [
                "De studie van religies wereldwijd",
                "Een persoonlijk geloofssysteem",
                "De leer van de kerkelijke tradities",
            ]
        case "dogma":
            return [
                "Kerkelijke gewoonten en gebruiken",
                "Persoonlijke interpretatie van geloof",
                "Oude verhalen uit de Bijbel",
            ]
        case "wesleyaans kwadrilateraal":
            return [
                "Wet – Profeten – Psalmen – Evangelie",
                "Geloof – Hoop – Liefde – Werken",
                "Kerk – Bijbel – Gebed – Sacrament",
            ]
        case "sola scriptura":
            return [
                "Traditie staat boven de Bijbel",
                "Kerkleiders bepalen de waarheid",
                "Geloof komt uit ervaring",
            ]
        case "geloofsregel":
            return [
                "Lijst van bijbelboeken",
                "Kerkelijke rituelen en feesten",
                "Persoonlijke geloofsopvattingen",
            ]
        case "geloofsbelijdenissen":
            return [
                "Verhalen over heiligen",
                "Regels voor kerkelijk gedrag",
                "Persoonlijke gebeden",
            ]
        case "orthodoxie":
            return [
                "Nieuwe interpretaties van geloof",
                "Persoonlijke religieuze ervaring",
                "Afwijking van traditie",
            ]
        case "ketterij":
            return [
                "Officiële kerkelijke leer",
                "Traditionele geloofsregels",
                "Algemene bijbeluitleg",
            ]
        case "geestelijke disciplines/handelingen":
            return [
                "Kerkelijke wetten en regels",
                "Historische gebeurtenissen",
                "Dogmatische uitspraken",
            ]
        case "genademiddelen":
            return [
                "Persoonlijke geloofservaring",
                "Morele leefregels",
                "Theologische ideeën",
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
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " / ", with: "/")
            .replacingOccurrences(of: " /", with: "/")
            .replacingOccurrences(of: "/ ", with: "/")
    }
}
