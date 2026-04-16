//
//  DogmatiekHoofdstuk5MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 5 — juiste regels en afleiders zoals in je studiemateriaal.
enum DogmatiekHoofdstuk5MultipleChoice {
    static let chapterTitle = "Hoofdstuk 5"

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "theologische antropologie":
            return "De theologische studie van wat de mens is en wat zijn bestemming is"
        case "psychosomatische eenheid":
            return "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen"
        case "materialisme":
            return "De overtuiging dat alleen materie bestaat en de mens volledig fysiek verklaard wordt"
        case "niet-reductionistisch fysicalisme":
            return "De opvatting dat de mens fysiek is, maar niet volledig te reduceren tot materie"
        case "holistisch dualisme":
            return "De overtuiging dat lichaam en geest te onderscheiden zijn maar samen één geheel vormen"
        case "imago dei":
            return "De leer dat de mens geschapen is naar het beeld van God"
        case "substantiële visie (imago dei)":
            return "De opvatting dat het beeld van God ligt in innerlijke eigenschappen zoals rede en moraal"
        case "functionele visie (imago dei)":
            return "De opvatting dat het beeld van God zichtbaar wordt in wat de mens doet"
        case "relationele visie (imago dei)":
            return "De opvatting dat het beeld van God zichtbaar wordt in relaties met anderen"
        case "zondeval":
            return "De gebeurtenis waarin de mens ongehoorzaam werd aan God"
        case "erfzonde":
            return "De overtuiging dat de mens sinds Adam in een staat van zonde leeft"
        case "pelagianisme":
            return "De opvatting dat de mens zichzelf kan redden zonder genade van God"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "theologische antropologie":
            return [
                "De studie van morele normen en menselijk handelen",
                "De theologische leer over redding en verlossing",
                "De leer over de aard, eenheid en roeping van de kerk",
            ]
        case "psychosomatische eenheid":
            return [
                "De overtuiging dat lichaam en geest te onderscheiden zijn maar samen één geheel vormen",
                "De overtuiging dat alleen materie bestaat en de mens volledig fysiek verklaard wordt",
                "De opvatting dat de mens fysiek is, maar niet volledig te reduceren tot materie",
            ]
        case "materialisme":
            return [
                "De overtuiging dat lichaam en geest te onderscheiden zijn maar samen één geheel vormen",
                "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen",
                "De opvatting dat de mens fysiek is, maar niet volledig te reduceren tot materie",
            ]
        case "niet-reductionistisch fysicalisme":
            return [
                "De overtuiging dat alleen materie bestaat en de mens volledig fysiek verklaard wordt",
                "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen",
                "De overtuiging dat lichaam en geest te onderscheiden zijn maar samen één geheel vormen",
            ]
        case "holistisch dualisme":
            return [
                "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen",
                "De overtuiging dat alleen materie bestaat en de mens volledig fysiek verklaard wordt",
                "De opvatting dat de mens uitsluitend uit materie bestaat zonder geest",
            ]
        case "imago dei":
            return [
                "De overtuiging dat de mens sinds Adam in een staat van zonde leeft",
                "De theologische leer over Gods genade en menselijke afhankelijkheid",
                "De opvatting dat de mens zichzelf kan redden zonder genade van God",
            ]
        case "substantiële visie (imago dei)":
            return [
                "De opvatting dat het beeld van God zichtbaar wordt in wat de mens doet",
                "De opvatting dat het beeld van God zichtbaar wordt in relaties met anderen",
                "De studie van morele normen en menselijk handelen",
            ]
        case "functionele visie (imago dei)":
            return [
                "De opvatting dat het beeld van God ligt in innerlijke eigenschappen zoals rede en moraal",
                "De opvatting dat het beeld van God zichtbaar wordt in relaties met anderen",
                "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen",
            ]
        case "relationele visie (imago dei)":
            return [
                "De opvatting dat het beeld van God ligt in innerlijke eigenschappen zoals rede en moraal",
                "De opvatting dat het beeld van God zichtbaar wordt in wat de mens doet",
                "De opvatting dat lichaam en ziel één ondeelbaar geheel vormen",
            ]
        case "zondeval":
            return [
                "De leer dat de mensheid sinds Adam in een staat van zonde en gebrokenheid verkeert",
                "De opvatting dat de mens naar Gods evenbeeld geschapen is",
                "De overtuiging dat de mens zichzelf kan redden zonder genade van God",
            ]
        case "erfzonde":
            return [
                "De theologische leer over Gods genade en menselijke afhankelijkheid",
                "De opvatting dat de mens zichzelf kan redden zonder genade van God",
                "De leer over verzoening tussen God en mens door Christus",
            ]
        case "pelagianisme":
            return [
                "De overtuiging dat de mens sinds Adam in een staat van zonde leeft",
                "De theologische leer over Gods genade en menselijke afhankelijkheid",
                "De leer van Augustinus over erfzonde en genade",
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
