//
//  DogmatiekHoofdstuk6MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 6 — stelling → juiste term én term → juiste definitie (zoals in je studiemateriaal).
enum DogmatiekHoofdstuk6MultipleChoice {
    static let chapterTitle = "Hoofdstuk 6"

    /// Korte stelling bovenaan bij „definitie → term” (afzonderlijk van de antwoordzinnen bij „term → definitie”).
    static func definitionFirstStemIfNeeded(for card: DogmatiekCard) -> String? {
        guard card.chapter == chapterTitle else { return nil }
        switch normalizedTerm(card.term) {
        case "onveranderlijkheid":
            return "De eigenschap dat God niet verandert omdat Hij volmaakt is"
        case "onlijdelijkheid/onaangedaanheid":
            return "De eigenschap dat God niet onderhevig is aan emoties of lijden"
        case "apollinarisme":
            return "De opvatting dat Jezus geen volledige menselijke geest had"
        case "eutychianisme":
            return "De opvatting dat de menselijke natuur van Jezus wordt opgeslokt door de goddelijke"
        case "monofysitisme":
            return "De opvatting dat Jezus na de incarnatie nog maar één natuur heeft"
        case "nestorianisme":
            return "De opvatting dat Jezus uit twee gescheiden personen bestaat"
        case "concilie van chalcedon":
            return "Het concilie dat stelde dat Jezus één persoon is met twee naturen"
        case "persoon en natuur van jezus":
            return "Het onderscheid tussen wie Jezus is en wat Hij is"
        case "hypostatische unie":
            return "De eenheid van goddelijke en menselijke natuur in één persoon"
        case "communicatie van eigenschappen":
            return "Het toeschrijven van goddelijke en menselijke eigenschappen aan één persoon"
        case "particulariteit":
            return "De overtuiging dat Jezus een concreet historisch mens is"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// Promptregel bij „term → definitie”.
    static func termFirstPromptLine(for card: DogmatiekCard) -> String? {
        guard card.chapter == chapterTitle else { return nil }
        let term = card.term.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedTerm(card.term) == "concilie van chalcedon" {
            return "Wat wordt bedoeld met het \(term)"
        }
        return "Wat wordt bedoeld met \(term)"
    }

    /// Juiste meerkeuze-regel bij „term → definitie”.
    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "onveranderlijkheid":
            return "God verandert niet omdat Hij volmaakt is in zijn wezen"
        case "onlijdelijkheid/onaangedaanheid":
            return "God is niet onderhevig aan emoties of lijden van buitenaf"
        case "apollinarisme":
            return "Jezus heeft geen volledige menselijke geest"
        case "eutychianisme":
            return "De menselijke natuur van Jezus wordt opgeslokt door de goddelijke"
        case "monofysitisme":
            return "Jezus heeft uiteindelijk nog maar één natuur na de incarnatie"
        case "nestorianisme":
            return "Jezus bestaat uit twee gescheiden personen"
        case "concilie van chalcedon":
            return "Jezus is één persoon met twee naturen, volledig God en mens"
        case "persoon en natuur van jezus":
            return "Verschil tussen wie Jezus is en wat Hij is (persoon vs natuur)"
        case "hypostatische unie":
            return "De eenheid van goddelijke en menselijke natuur in één persoon"
        case "communicatie van eigenschappen":
            return "Eigenschappen van God en mens worden aan één persoon toegeschreven"
        case "particulariteit":
            return "Jezus is een concreet historisch persoon in tijd en plaats"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        let correct = correctAnswerLine(for: card)
        let others = Self.allTermFirstAnswersOrdered.filter { $0 != correct }
        switch normalizedTerm(card.term) {
        case "onveranderlijkheid":
            return [
                "God wordt niet beïnvloed door emoties of lijden",
                "God is overal tegelijk aanwezig in de schepping",
                "God bestaat buiten de tijd en verandert daardoor niet",
            ]
        case "onlijdelijkheid/onaangedaanheid":
            return [
                "God verandert niet in zijn karakter en wezen",
                "God heeft geen relatie met de wereld of de mens",
                "God handelt alleen via vaste natuurwetten",
            ]
        case "apollinarisme":
            return [
                "Jezus heeft één natuur die volledig goddelijk is",
                "Jezus bestaat uit twee gescheiden personen",
                "De menselijke natuur van Jezus verdwijnt in de goddelijke",
            ]
        case "eutychianisme":
            return [
                "Jezus heeft twee volledig gescheiden naturen",
                "Jezus heeft geen menselijke ziel of geest",
                "Jezus bestaat uit twee personen in één lichaam",
            ]
        case "monofysitisme":
            return [
                "Jezus heeft twee naturen die volledig gescheiden blijven",
                "Jezus bestaat uit een menselijke en een goddelijke persoon",
                "Jezus heeft alleen een menselijke natuur zonder goddelijke",
            ]
        case "nestorianisme":
            return [
                "Jezus heeft één natuur die volledig goddelijk is",
                "Jezus heeft geen menselijke geest of ziel",
                "De menselijke natuur wordt opgenomen in de goddelijke",
            ]
        case "concilie van chalcedon":
            return [
                "Jezus is een geschapen wezen en niet volledig God",
                "Jezus heeft slechts één natuur na zijn geboorte",
                "Jezus bestaat uit twee gescheiden personen",
            ]
        case "persoon en natuur van jezus":
            return [
                "Jezus heeft één natuur die zowel goddelijk als menselijk is",
                "Jezus bestaat uit twee volledig gescheiden personen",
                "Jezus heeft alleen een goddelijke natuur zonder menselijkheid",
            ]
        case "hypostatische unie":
            return [
                "De scheiding tussen goddelijke en menselijke natuur in Jezus",
                "Het bestaan van twee personen binnen Jezus",
                "Het verdwijnen van de menselijke natuur in de goddelijke",
            ]
        case "communicatie van eigenschappen":
            return [
                "De scheiding van goddelijke en menselijke eigenschappen",
                "Het bestaan van twee afzonderlijke naturen zonder overlap",
                "De vermenging van naturen tot één nieuwe natuur",
            ]
        case "particulariteit":
            return [
                "Jezus vertegenwoordigt de mensheid in algemene zin",
                "Jezus is een symbolische figuur zonder historische context",
                "Jezus is alleen goddelijk en niet werkelijk mens",
            ]
        default:
            return Array(others.shuffled().prefix(3))
        }
    }

    static func optionPool(for card: DogmatiekCard) -> [String] {
        [correctAnswerLine(for: card)] + distractors(for: card)
    }

    /// Vaste vier termen (stelling → kies begrip), zoals in het materiaal.
    static func fixedTermOptionPool(for card: DogmatiekCard) -> [String]? {
        guard card.chapter == chapterTitle else { return nil }
        switch normalizedTerm(card.term) {
        case "onveranderlijkheid":
            return ["Onlijdelijkheid", "Goddelijke eenvoud", "Eeuwigheid", "Onveranderlijkheid"]
        case "onlijdelijkheid/onaangedaanheid":
            return ["Onveranderlijkheid", "Goddelijke liefde", "Voorzienigheid", "Onlijdelijkheid/onaangedaanheid"]
        case "apollinarisme":
            return ["Nestorianisme", "Monofysitisme", "Eutychianisme", "Apollinarisme"]
        case "eutychianisme":
            return ["Monofysitisme", "Nestorianisme", "Apollinarisme", "Eutychianisme"]
        case "monofysitisme":
            return ["Eutychianisme", "Nestorianisme", "Apollinarisme", "Monofysitisme"]
        case "nestorianisme":
            return ["Monofysitisme", "Apollinarisme", "Eutychianisme", "Nestorianisme"]
        case "concilie van chalcedon":
            return ["Concilie van Nicea", "Concilie van Efeze", "Concilie van Trente", "Concilie van Chalcedon"]
        case "persoon en natuur van jezus":
            return ["Hypostatische unie", "Communicatie van eigenschappen", "Monofysitisme", "Persoon en natuur van Jezus"]
        case "hypostatische unie":
            return ["Persoon en natuur", "Communicatie van eigenschappen", "Monofysitisme", "Hypostatische unie"]
        case "communicatie van eigenschappen":
            return ["Hypostatische unie", "Persoon en natuur", "Perichorese", "Communicatie van eigenschappen"]
        case "particulariteit":
            return ["Incarnatie", "Hypostatische unie", "Menswording", "Particulariteit"]
        default:
            return nil
        }
    }

    private static let allTermFirstAnswersOrdered: [String] = [
        "God verandert niet omdat Hij volmaakt is in zijn wezen",
        "God is niet onderhevig aan emoties of lijden van buitenaf",
        "Jezus heeft geen volledige menselijke geest",
        "De menselijke natuur van Jezus wordt opgeslokt door de goddelijke",
        "Jezus heeft uiteindelijk nog maar één natuur na de incarnatie",
        "Jezus bestaat uit twee gescheiden personen",
        "Jezus is één persoon met twee naturen, volledig God en mens",
        "Verschil tussen wie Jezus is en wat Hij is (persoon vs natuur)",
        "De eenheid van goddelijke en menselijke natuur in één persoon",
        "Eigenschappen van God en mens worden aan één persoon toegeschreven",
        "Jezus is een concreet historisch persoon in tijd en plaats",
    ]

    private static func normalizedTerm(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " / ", with: "/")
    }
}
