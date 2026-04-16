//
//  DogmatiekHoofdstuk4MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 4 — juiste regels en afleiders zoals in je studiemateriaal.
enum DogmatiekHoofdstuk4MultipleChoice {
    static let chapterTitle = "Hoofdstuk 4"

    /// Onderdelen van voorzienigheid: zelfde vraag voor de kaarten Instandhouding, Medewerking en Bestuur.
    static func supplementaryPrompt(for card: DogmatiekCard) -> String? {
        switch normalizedTerm(card.term) {
        case "instandhouding", "medewerking", "bestuur":
            return "Vraag: Waaruit bestaat voorzienigheid?"
        default:
            return nil
        }
    }

    /// Bij ‘definitie → term’ mag de stam niet de drie-delige antwoordregel zijn; die staat op je werkblad zo.
    static func definitionFirstStemIfNeeded(for card: DogmatiekCard) -> String? {
        switch normalizedTerm(card.term) {
        case "instandhouding", "medewerking", "bestuur":
            return "De onderdelen van Gods voortdurende handelen in de schepping"
        default:
            return nil
        }
    }

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "creatio ex nihilo":
            return "De overtuiging dat God de wereld uit niets tot bestaan heeft gebracht"
        case "deïsme":
            return "De opvatting dat God de wereld heeft geschapen maar daarna niet meer ingrijpt"
        case "transcendentie":
            return "De overtuiging dat God radicaal boven en buiten de schepping staat"
        case "immanentie":
            return "De overtuiging dat God actief aanwezig is binnen de schepping"
        case "pantheïsme":
            return "De opvatting dat alles wat bestaat uiteindelijk God zelf is"
        case "panentheïsme":
            return "De overtuiging dat God en wereld nauw verbonden zijn maar niet identiek"
        case "gnosticisme":
            return "De opvatting dat materie minderwaardig is en verlossing komt door kennis"
        case "hiërarchisch dualisme":
            return "De overtuiging dat het geestelijke hoger staat dan het materiële"
        case "holisme":
            return "De overtuiging dat alles één samenhangend geheel vormt onder God"
        case "voorzienigheid":
            return "Gods voortdurende zorg en leiding over de schepping"
        case "instandhouding", "medewerking", "bestuur":
            return "Instandhouding, medewerking en bestuur"
        case "theodicee":
            return "De poging om Gods goedheid te verenigen met het bestaan van kwaad"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "creatio ex nihilo":
            return [
                "Schepping uit bestaande materie door goddelijke vorming",
                "Idee dat de wereld altijd naast God heeft bestaan",
                "Opvatting dat de wereld voortkomt uit Gods eigen wezen",
            ]
        case "deïsme":
            return [
                "Geloof dat God voortdurend actief betrokken is bij de wereld",
                "Idee dat God volledig samenvalt met de natuur en alles wat bestaat",
                "Opvatting dat God zich alleen via openbaring kenbaar maakt",
            ]
        case "transcendentie":
            return [
                "Gods aanwezigheid die zichtbaar is binnen de schepping",
                "Idee dat God volledig samenvalt met de wereld",
                "Opvatting dat God alleen via ervaring gekend kan worden",
            ]
        case "immanentie":
            return [
                "Gods afstand en onafhankelijkheid van de wereld",
                "Idee dat God losstaat van alles wat bestaat",
                "Opvatting dat God alleen via openbaring zichtbaar wordt",
            ]
        case "pantheïsme":
            return [
                "Idee dat God en wereld onderscheiden maar verbonden zijn",
                "Geloof dat God buiten de wereld staat en alles bestuurt",
                "Opvatting dat God zich alleen via openbaring bekendmaakt",
            ]
        case "panentheïsme":
            return [
                "Idee dat God volledig samenvalt met het universum",
                "Opvatting dat God losstaat van de schepping zonder betrokkenheid",
                "Geloof dat God alleen via Schrift gekend kan worden",
            ]
        case "gnosticisme":
            return [
                "Idee dat de materiële wereld goed en door God geschapen is",
                "Geloof dat verlossing komt door gehoorzaamheid en goede werken",
                "Opvatting dat lichaam en ziel gelijkwaardig en beide goed zijn",
            ]
        case "hiërarchisch dualisme":
            return [
                "Opvatting dat lichaam en ziel één onlosmakelijk geheel vormen",
                "Idee dat materie en geest volledig gelijkwaardig zijn",
                "Geloof dat alleen het lichaam belangrijk is voor het bestaan",
            ]
        case "holisme":
            return [
                "Idee dat werkelijkheid bestaat uit losse en onafhankelijke delen",
                "Opvatting dat geest en lichaam volledig gescheiden functioneren",
                "Geloof dat alleen het geestelijke van waarde is",
            ]
        case "voorzienigheid":
            return [
                "Idee dat God alleen aan het begin van de schepping handelde",
                "Opvatting dat de wereld volledig autonoom functioneert",
                "Geloof dat God alleen via wonderen ingrijpt",
            ]
        case "instandhouding", "medewerking", "bestuur":
            return [
                "Schepping, openbaring en verlossing als drie fasen",
                "Wet, genade en geloof als basis van het leven",
                "Natuur, Schrift en traditie als bronnen van kennis",
            ]
        case "theodicee":
            return [
                "Studie van hoe God zich openbaart in de natuur",
                "Opvatting dat kwaad noodzakelijk is voor menselijke vrijheid",
                "Analyse van Gods eigenschappen zoals almacht en kennis",
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
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
