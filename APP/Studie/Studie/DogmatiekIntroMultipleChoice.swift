//
//  DogmatiekIntroMultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor het hoofdstuk Inleiding (één juiste definitie + drie afleiders).
enum DogmatiekIntroMultipleChoice {
    static let inleidingChapter = "Inleiding"

    /// Juiste antwoordregel zoals in je studiemateriaal / screenshot (meerkeuze), niet per se gelijk aan de volledige opgeslagen definitie.
    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        let t = card.term.trimmingCharacters(in: .whitespacesAndNewlines)
        switch t {
        case "Doctrine":
            return "Christelijke leerstelling binnen de kerk"
        case "Oecumenisch":
            return "Interkerkelijk verbonden, gericht op eenheid van alle gelovigen"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// Drie plausibele foute antwoorden bij de term.
    static func distractors(for card: DogmatiekCard) -> [String] {
        let t = card.term.trimmingCharacters(in: .whitespacesAndNewlines)
        switch t {
        case "Doctrine":
            return [
                "Een kerkelijk ritueel of sacrament",
                "Een persoonlijke geloofsovertuiging van een individu",
                "Een historische gebeurtenis uit de vroege kerk",
            ]
        case "Oecumenisch":
            return [
                "Een term voor missionair werk buiten Europa",
                "Gericht op één specifieke denominatie",
                "Een leer over de schepping van de aarde",
            ]
        default:
            return [
                "Een andere betekenis die niet bij deze term hoort.",
                "Een begrip uit een ander hoofdstuk van je materiaal.",
                "Geen van deze beschrijvingen is de bedoelde definitie.",
            ]
        }
    }

    /// Vier opties: juiste regel (screenshot) plus distractors, voor shuffling door de oefenweergave.
    static func optionPool(for card: DogmatiekCard) -> [String] {
        [correctAnswerLine(for: card)] + distractors(for: card)
    }
}
