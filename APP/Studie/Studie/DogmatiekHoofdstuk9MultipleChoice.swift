//
//  DogmatiekHoofdstuk9MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 9 (ecclesiologie e.a.) — zoals in je studiemateriaal.
enum DogmatiekHoofdstuk9MultipleChoice {
    static let chapterTitle = "Hoofdstuk 9"

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "ecclesiologie":
            return "De theologische studie van de aard, identiteit en roeping van de kerk"
        case "kenmerken van de kerk":
            return "Eén, heilig, katholiek en apostolisch"
        case "katholiciteit":
            return "De overtuiging dat de kerk wereldwijd en universeel is"
        case "apostoliciteit":
            return "De overtuiging dat de kerk trouw blijft aan de leer van de apostelen"
        case "donatistische controverse":
            return "De discussie of sacramenten geldig zijn wanneer de bedienaar zondig is"
        case "gemixt lichaam", "gemengd lichaam":
            return "De opvatting dat de kerk bestaat uit zowel gelovigen als zondaars"
        case "constantinianisme":
            return "De nauwe verwevenheid tussen kerk en politieke macht"
        case "sacramenten":
            return "Door God ingestelde tekenen waardoor genade wordt beloofd en ontvangen"
        case "sacramenteel":
            return "Iets heeft religieuze betekenis zonder de status van sacrament te hebben"
        case "eucharistie":
            return "De Rooms-Katholieke viering van het avondmaal"
        case "het priesterschap van alle gelovigen":
            return "De overtuiging dat elke gelovige direct toegang heeft tot God"
        case "consubstantiatie":
            return "De opvatting dat Christus werkelijk aanwezig is in brood en wijn"
        case "werkelijke aanwezigheid":
            return "De overtuiging dat Christus daadwerkelijk aanwezig is in het avondmaal"
        case "verordeningen":
            return "Handelingen zoals doop en avondmaal zonder dat ze genade op zichzelf overdragen"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// Stelling bij ‘definitie → term’ wanneer die afwijkt van `correctAnswerLine` (zoals bij de vier kenmerken).
    static func definitionFirstStemIfNeeded(for card: DogmatiekCard) -> String? {
        if normalizedTerm(card.term) == "kenmerken van de kerk" {
            return "De vier klassieke kenmerken die de kerk typeren"
        }
        return nil
    }

    /// Vaste opties voor de vier-kenmerken-vraag (definitie → term).
    static func fixedFourMarksTermPool(for card: DogmatiekCard) -> [String]? {
        guard normalizedTerm(card.term) == "kenmerken van de kerk" else { return nil }
        return [
            "Schrift, traditie, rede en ervaring",
            "Geloof, hoop, liefde en genade",
            "Doop, avondmaal, gebed en prediking",
            "Eén, heilig, katholiek en apostolisch",
        ]
    }

    /// Verwachte keuze bij definitie → term als die niet de kaartterm is.
    static func expectedAnswerWhenPickingTermIfNeeded(for card: DogmatiekCard) -> String? {
        if normalizedTerm(card.term) == "kenmerken van de kerk" {
            return "Eén, heilig, katholiek en apostolisch"
        }
        return nil
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "ecclesiologie":
            return [
                "De theologische leer over redding en verlossing",
                "De studie van de zending en de opdracht van de kerk in de wereld",
                "De systematische ordening van christelijke geloofswaarheden",
            ]
        case "kenmerken van de kerk":
            return [
                "Schrift, traditie, rede en ervaring",
                "Geloof, hoop, liefde en genade",
                "Doop, avondmaal, gebed en prediking",
            ]
        case "katholiciteit":
            return [
                "De overtuiging dat de kerk trouw blijft aan de leer van de apostelen",
                "De eenheid van de kerk in geloof en liefde",
                "De heiligheid van de kerk als gemeenschap van heiligen",
            ]
        case "apostoliciteit":
            return [
                "De overtuiging dat de kerk wereldwijd en universeel is",
                "De eenheid van de kerk in geloof en liefde",
                "De heiligheid van de kerk als gemeenschap van heiligen",
            ]
        case "donatistische controverse":
            return [
                "Discussie over de godheid van Christus ten opzichte van de Vader",
                "Discussie over de rol van genade en vrije wil in het menselijk handelen",
                "Het vaststellen welke geschriften tot de canon van de Bijbel behoren",
            ]
        case "gemixt lichaam", "gemengd lichaam":
            return [
                "De opvatting dat de kerk uitsluitend uit heiligen bestaat",
                "De gemeenschap die volledig zuiver is in leer en leven",
                "De gemeente die uitsluitend uit uitverkorenen bestaat",
            ]
        case "constantinianisme":
            return [
                "Het terugtreden van religie uit de openbare ruimte",
                "De juridische en institutionele scheiding van kerk en staat",
                "De zelfstandigheid van religieuze gemeenschappen ten opzichte van de overheid",
            ]
        case "sacramenten":
            return [
                "Handelingen zoals doop en avondmaal zonder dat ze genade op zichzelf overdragen",
                "Middelen waarmee God genade aan gelovigen bekendmaakt",
                "Vaste rituele vormen binnen eredienst en kerkelijk leven",
            ]
        case "sacramenteel":
            return [
                "Door God ingestelde tekenen waardoor genade wordt beloofd en ontvangen",
                "Middelen waarmee God genade aan gelovigen bekendmaakt",
                "De gestructureerde eredienst van de christelijke gemeenschap",
            ]
        case "eucharistie":
            return [
                "De ceremoniële opname in het verbond door water",
                "De geordende viering van gebed en gezang in de eredienst",
                "Handelingen zoals doop en avondmaal zonder dat ze genade op zichzelf overdragen",
            ]
        case "het priesterschap van alle gelovigen":
            return [
                "De ononderbroken lijn van gezag van apostelen tot kerkleiders",
                "Het denken waarbij vooral zichtbare tekens genade dragen",
                "De gestructureerde rangorde van ambten in de kerk",
            ]
        case "consubstantiatie":
            return [
                "De leer dat brood en wijn volledig worden in lichaam en bloed van Christus",
                "De opvatting dat Christus alleen symbolisch in het avondmaal aanwezig is",
                "De leer dat het avondmaal vooral een herinnering aan Christus’ offer is",
            ]
        case "werkelijke aanwezigheid":
            return [
                "De opvatting dat Christus alleen symbolisch in het avondmaal aanwezig is",
                "De overtuiging dat Christus vooral innerlijk in het geloof aanwezig is",
                "Het denken waarbij vooral zichtbare tekens genade dragen",
            ]
        case "verordeningen":
            return [
                "Door God ingestelde tekenen waardoor genade wordt beloofd en ontvangen",
                "Middelen waarmee God genade aan gelovigen bekendmaakt",
                "Vaste rituele handelingen binnen de liturgische orde",
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
