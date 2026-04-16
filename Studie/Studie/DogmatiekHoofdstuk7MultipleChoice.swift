//
//  DogmatiekHoofdstuk7MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 7 (soteriologie e.a.) — definitie → term én term → definitie.
enum DogmatiekHoofdstuk7MultipleChoice {
    static let chapterTitle = "Hoofdstuk 7"

    /// Stelling bij „definitie → term”.
    static func definitionFirstStemIfNeeded(for card: DogmatiekCard) -> String? {
        guard card.chapter == chapterTitle else { return nil }
        switch normalizedTerm(card.term) {
        case "soteriologie":
            return "De theologische leer over hoe verlossing tot stand komt door Jezus' werk"
        case "berouw":
            return "Innerlijk besef van zonde en verdriet daarover als eerste stap richting redding"
        case "bekering":
            return "Je afkeren van zonde en je richten op God"
        case "rechtvaardiging":
            return "Gods daad waarbij zondaars rechtvaardig worden verklaard door geloof"
        case "aflaten":
            return "Kwijtschelding van tijdelijke straf voor zonden binnen de katholieke leer"
        case "toegerekende gerechtigheid":
            return "De gerechtigheid van Christus die aan gelovigen wordt toegeschreven"
        case "heiliging":
            return "Het proces waarin gelovigen daadwerkelijk veranderd en vernieuwd worden"
        case "werken gerechtigheid":
            return "De opvatting dat iemand door eigen daden rechtvaardig kan worden"
        case "antinomianisme":
            return "De opvatting dat Gods wet geen rol meer speelt in het christelijk leven"
        case "calvinisme":
            return "De opvatting dat God als enige actor handelt in redding"
        case "arminianisme":
            return "De opvatting dat Gods genade ruimte laat voor menselijke reactie"
        case "voorafgaande genade":
            return "De genade die voorafgaat aan menselijk handelen en reactie mogelijk maakt"
        case "monergisme":
            return "De opvatting dat God alleen handelt in het proces van redding"
        case "synergisme":
            return "De opvatting dat God en mens samenwerken in het proces van redding"
        case "verzoening":
            return "Het werk van Christus waardoor de relatie tussen God en mens wordt hersteld"
        case "christus victor":
            return "Verzoeningsmodel waarin Christus de machten van zonde en dood overwint"
        case "plaatsvervanging":
            return "Verzoeningsmodel waarin Christus de straf van zonde op zich neemt"
        case "voldoeningstheorie":
            return "Verzoeningsleer waarin Christus de schuld van de mensheid voldoet"
        case "forensische metafoor":
            return "Juridische manier van spreken over verzoening (schuld, straf, vrijspraak)"
        case "moreel voorbeeld":
            return "Verzoeningsmodel waarin Christus' liefde mensen innerlijk verandert"
        case "vergoddelijking":
            return "Verzoeningsmodel waarin mensen delen in Gods leven en worden getransformeerd"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func termFirstPromptLine(for card: DogmatiekCard) -> String? {
        guard card.chapter == chapterTitle else { return nil }
        let term = card.term.trimmingCharacters(in: .whitespacesAndNewlines)
        return "Wat wordt bedoeld met \(term)"
    }

    /// Juiste antwoord bij „term → definitie”.
    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "soteriologie":
            return "De leer over hoe verlossing tot stand komt door Jezus' werk"
        case "berouw":
            return "Innerlijk besef van zonde en verdriet daarover"
        case "bekering":
            return "Je afkeren van zonde en je richten op God"
        case "rechtvaardiging":
            return "God verklaart zondaars rechtvaardig door geloof"
        case "aflaten":
            return "Kwijtschelding van tijdelijke straf voor zonden"
        case "toegerekende gerechtigheid":
            return "De gerechtigheid van Christus wordt aan gelovigen toegeschreven"
        case "heiliging":
            return "Het proces waarin gelovigen daadwerkelijk veranderen en groeien"
        case "werken gerechtigheid":
            return "De opvatting dat iemand door eigen daden rechtvaardig wordt"
        case "antinomianisme":
            return "De opvatting dat Gods wet geen rol meer speelt"
        case "calvinisme":
            return "God is de enige en beslissende actor in redding"
        case "arminianisme":
            return "Gods genade laat ruimte voor menselijke reactie"
        case "voorafgaande genade":
            return "Genade die voorafgaat en reactie mogelijk maakt"
        case "monergisme":
            return "God handelt alleen in het proces van redding"
        case "synergisme":
            return "God en mens werken samen in redding"
        case "verzoening":
            return "Herstel van de relatie tussen God en mens door Christus"
        case "christus victor":
            return "Christus overwint de machten van zonde en dood"
        case "plaatsvervanging":
            return "Christus draagt de straf van zonde in plaats van mensen"
        case "voldoeningstheorie":
            return "Christus voldoet de schuld van de mensheid"
        case "forensische metafoor":
            return "Een juridische manier van spreken over schuld en vrijspraak"
        case "moreel voorbeeld":
            return "Christus' liefde verandert mensen innerlijk als voorbeeld"
        case "vergoddelijking":
            return "Mensen delen in Gods leven en worden getransformeerd"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        let correct = correctAnswerLine(for: card)
        let others = Self.allTermFirstAnswersOrdered.filter { $0 != correct }
        switch normalizedTerm(card.term) {
        case "soteriologie":
            return [
                "De leer over de persoon en natuur van Christus",
                "De leer over de kerk en haar kenmerken",
                "De leer over de Heilige Geest en zijn werk",
            ]
        case "berouw":
            return [
                "Je actief afkeren van zonde en God volgen",
                "Het ontvangen van vergeving door geloof",
                "Het proces van geestelijke groei in heiligheid",
            ]
        case "bekering":
            return [
                "Innerlijk verdriet over zonde zonder verandering",
                "Het rechtvaardig verklaard worden door God",
                "Het proces van heiliging door de Geest",
            ]
        case "rechtvaardiging":
            return [
                "Het proces waarin gelovigen steeds heiliger worden",
                "Het innerlijk veranderen van de mens door genade",
                "Het ontvangen van genade door goede werken",
            ]
        case "aflaten":
            return [
                "Vergeving van zonden door direct geloof in Christus",
                "Een innerlijke verandering van de gelovige",
                "Een symbolische handeling zonder effect op straf",
            ]
        case "toegerekende gerechtigheid":
            return [
                "Gerechtigheid die ontstaat door goede werken",
                "Een proces van morele groei en heiliging",
                "Het verdienen van rechtvaardigheid door gehoorzaamheid",
            ]
        case "heiliging":
            return [
                "Het rechtvaardig verklaard worden door geloof",
                "Het ontvangen van vergeving zonder verandering",
                "Het moment van bekering tot God",
            ]
        case "werken gerechtigheid":
            return [
                "Gerechtigheid die alleen door Christus gegeven wordt",
                "Het ontvangen van genade zonder menselijke bijdrage",
                "Een proces van innerlijke vernieuwing door de Geest",
            ]
        case "antinomianisme":
            return [
                "Het idee dat de mens zichzelf kan redden",
                "De nadruk op gehoorzaamheid aan Gods wet",
                "Het proces van morele groei en heiliging",
            ]
        case "calvinisme":
            return [
                "De opvatting dat mens en God samenwerken in redding",
                "De overtuiging dat de mens zichzelf kan redden",
                "De nadruk op menselijke keuzevrijheid in redding",
            ]
        case "arminianisme":
            return [
                "De overtuiging dat God alles bepaalt zonder menselijke rol",
                "De leer dat redding volledig onafhankelijk is van de mens",
                "De opvatting dat genade alleen voor uitverkorenen is",
            ]
        case "voorafgaande genade":
            return [
                "Genade die volgt op menselijke keuze en geloof",
                "Genade die alleen aan gelovigen gegeven wordt",
                "Genade die verdiend wordt door gehoorzaamheid",
            ]
        case "monergisme":
            return [
                "De samenwerking tussen God en mens in redding",
                "De nadruk op menselijke keuze in geloof",
                "De mogelijkheid om genade te weerstaan",
            ]
        case "synergisme":
            return [
                "God bepaalt alles zonder menselijke betrokkenheid",
                "De mens redt zichzelf door eigen keuzes",
                "Genade werkt onafhankelijk van de mens",
            ]
        case "verzoening":
            return [
                "Het proces van innerlijke morele verandering",
                "Het moment van bekering tot God",
                "Het ontvangen van gerechtigheid door geloof",
            ]
        case "christus victor":
            return [
                "Christus betaalt de straf voor zonde",
                "Christus geeft een moreel voorbeeld voor mensen",
                "Christus herstelt Gods eer door voldoening",
            ]
        case "plaatsvervanging":
            return [
                "Christus overwint de machten van het kwaad",
                "Christus verandert mensen door zijn voorbeeld",
                "Christus herstelt Gods eer door voldoening",
            ]
        case "voldoeningstheorie":
            return [
                "Christus overwint de machten van het kwaad",
                "Christus dient als voorbeeld voor moreel gedrag",
                "Christus neemt alleen de straf van zonde op zich",
            ]
        case "forensische metafoor":
            return [
                "Een relationele manier van spreken over verzoening",
                "Een symbolische uitleg van Jezus' werk",
                "Een moreel voorbeeld voor gelovigen",
            ]
        case "moreel voorbeeld":
            return [
                "Christus draagt de straf van zonde",
                "Christus overwint de machten van het kwaad",
                "Christus herstelt Gods eer door voldoening",
            ]
        case "vergoddelijking":
            return [
                "Christus neemt de straf van de mens op zich",
                "Christus overwint de machten van zonde en dood",
                "Christus geeft een voorbeeld van moreel leven",
            ]
        default:
            return Array(others.shuffled().prefix(3))
        }
    }

    static func optionPool(for card: DogmatiekCard) -> [String] {
        [correctAnswerLine(for: card)] + distractors(for: card)
    }

    /// Vaste vier termen bij „definitie → term”.
    static func fixedTermOptionPool(for card: DogmatiekCard) -> [String]? {
        guard card.chapter == chapterTitle else { return nil }
        switch normalizedTerm(card.term) {
        case "soteriologie":
            return ["Christologie", "Ecclesiologie", "Pneumatologie", "Soteriologie"]
        case "berouw":
            return ["Bekering", "Rechtvaardiging", "Heiliging", "Berouw"]
        case "bekering":
            return ["Berouw", "Rechtvaardiging", "Heiliging", "Bekering"]
        case "rechtvaardiging":
            return ["Heiliging", "Toegerekende gerechtigheid", "Werken gerechtigheid", "Rechtvaardiging"]
        case "aflaten":
            return ["Verzoening", "Boetedoening", "Heiliging", "Aflaten"]
        case "toegerekende gerechtigheid":
            return ["Rechtvaardiging", "Werken gerechtigheid", "Heiliging", "Toegerekende gerechtigheid"]
        case "heiliging":
            return ["Rechtvaardiging", "Bekering", "Berouw", "Heiliging"]
        case "werken gerechtigheid":
            return ["Toegerekende gerechtigheid", "Rechtvaardiging", "Heiliging", "Werken gerechtigheid"]
        case "antinomianisme":
            return ["Pelagianisme", "Libertinisme", "Heiliging", "Antinomianisme"]
        case "calvinisme":
            return ["Arminianisme", "Synergisme", "Voorafgaande genade", "Calvinisme"]
        case "arminianisme":
            return ["Calvinisme", "Monergisme", "Determinisme", "Arminianisme"]
        case "voorafgaande genade":
            return ["Rechtvaardigende genade", "Heiligende genade", "Verlossende genade", "Voorafgaande genade"]
        case "monergisme":
            return ["Synergisme", "Arminianisme", "Voorafgaande genade", "Monergisme"]
        case "synergisme":
            return ["Monergisme", "Calvinisme", "Determinisme", "Synergisme"]
        case "verzoening":
            return ["Rechtvaardiging", "Heiliging", "Bekering", "Verzoening"]
        case "christus victor":
            return ["Plaatsvervanging", "Moreel voorbeeld", "Voldoeningstheorie", "Christus Victor"]
        case "plaatsvervanging":
            return ["Christus Victor", "Moreel voorbeeld", "Vergoddelijking", "Plaatsvervanging"]
        case "voldoeningstheorie":
            return ["Plaatsvervanging", "Christus Victor", "Moreel voorbeeld", "Voldoeningstheorie"]
        case "forensische metafoor":
            return ["Moreel voorbeeld", "Christus Victor", "Vergoddelijking", "Forensische metafoor"]
        case "moreel voorbeeld":
            return ["Plaatsvervanging", "Christus Victor", "Voldoeningstheorie", "Moreel voorbeeld"]
        case "vergoddelijking":
            return ["Plaatsvervanging", "Moreel voorbeeld", "Christus Victor", "Vergoddelijking"]
        default:
            return nil
        }
    }

    private static let allTermFirstAnswersOrdered: [String] = [
        "De leer over hoe verlossing tot stand komt door Jezus' werk",
        "Innerlijk besef van zonde en verdriet daarover",
        "Je afkeren van zonde en je richten op God",
        "God verklaart zondaars rechtvaardig door geloof",
        "Kwijtschelding van tijdelijke straf voor zonden",
        "De gerechtigheid van Christus wordt aan gelovigen toegeschreven",
        "Het proces waarin gelovigen daadwerkelijk veranderen en groeien",
        "De opvatting dat iemand door eigen daden rechtvaardig wordt",
        "De opvatting dat Gods wet geen rol meer speelt",
        "God is de enige en beslissende actor in redding",
        "Gods genade laat ruimte voor menselijke reactie",
        "Genade die voorafgaat en reactie mogelijk maakt",
        "God handelt alleen in het proces van redding",
        "God en mens werken samen in redding",
        "Herstel van de relatie tussen God en mens door Christus",
        "Christus overwint de machten van zonde en dood",
        "Christus draagt de straf van zonde in plaats van mensen",
        "Christus voldoet de schuld van de mensheid",
        "Een juridische manier van spreken over schuld en vrijspraak",
        "Christus' liefde verandert mensen innerlijk als voorbeeld",
        "Mensen delen in Gods leven en worden getransformeerd",
    ]

    private static func normalizedTerm(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " / ", with: "/")
    }
}
