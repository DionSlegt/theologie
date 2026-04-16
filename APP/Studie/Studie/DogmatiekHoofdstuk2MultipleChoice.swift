//
//  DogmatiekHoofdstuk2MultipleChoice.swift
//  Studie
//

import Foundation

/// Meerkeuzevragen voor Hoofdstuk 2 — juiste regels en afleiders zoals in je studiemateriaal.
enum DogmatiekHoofdstuk2MultipleChoice {
    static let chapterTitle = "Hoofdstuk 2"

    /// Bij meerkeuze ‘definitie → term’: eigen stelling i.p.v. de korte antwoordregel.
    static func definitionFirstStemIfNeeded(for card: DogmatiekCard) -> String? {
        switch normalizedTerm(card.term) {
        case "tweede vaticaans concilie":
            return "Welk concilie herbevestigde dat Schrift en traditie samen gezag hebben"
        case "bijbelse foutloosheid":
            return "De overtuiging dat de Bijbel geen fouten bevat in wat zij leert en stelt"
        case "bijbelse onfeilbaarheid":
            return "De overtuiging dat de Bijbel betrouwbaar is in geloof en redding, ook als niet alles letterlijk wordt opgevat"
        case "marcion (historische figuur)":
            return "Wie maakte een eigen canon en verwierp het Oude Testament?"
        default:
            return nil
        }
    }

    /// Vaste concilie-namen voor Tweede Vaticaans Concilie (definitie → term), zelfde stijl als H3-Nicea.
    static func fixedCouncilTermOptionPool(for card: DogmatiekCard) -> [String]? {
        guard normalizedTerm(card.term) == "tweede vaticaans concilie" else { return nil }
        return [
            "Concilie van Nicea",
            "Concilie van Chalcedon",
            "Concilie van Efeze",
            "Tweede Vaticaans Concilie",
        ]
    }

    /// Vaste termen voor foutloosheid / onfeilbaarheid (definitie → term), zoals in je werkblad.
    static func fixedBijbelGezagTermOptionPool(for card: DogmatiekCard) -> [String]? {
        switch normalizedTerm(card.term) {
        case "bijbelse foutloosheid":
            return [
                "Bijbelse onfeilbaarheid",
                "Inspiratie (canon)",
                "Canon",
                "Bijbelse foutloosheid",
            ]
        case "bijbelse onfeilbaarheid":
            return [
                "Bijbelse foutloosheid",
                "Hermeneutiek",
                "Inspiratie (canon)",
                "Bijbelse onfeilbaarheid",
            ]
        default:
            return nil
        }
    }

    /// Vaste namen bij de Marcion-stelling (definitie → term), zoals in je werkblad.
    static func fixedMarcionSchismaTermOptionPool(for card: DogmatiekCard) -> [String]? {
        guard normalizedTerm(card.term) == "marcion (historische figuur)" else { return nil }
        return [
            "Marcion",
            "Pelagius",
            "Augustinus van Hippo",
            "Arius",
        ]
    }

    /// Verwacht antwoord bij korte werkbladnamen i.p.v. de volledige kaartterm.
    static func expectedAnswerWhenPickingTermIfNeeded(for card: DogmatiekCard) -> String? {
        guard normalizedTerm(card.term) == "marcion (historische figuur)" else { return nil }
        return "Marcion"
    }

    static func correctAnswerLine(for card: DogmatiekCard) -> String {
        switch normalizedTerm(card.term) {
        case "algemene openbaring":
            return "Gods zelfopenbaring in natuur en menselijk geweten"
        case "speciale openbaring":
            return "Gods openbaring in specifieke gebeurtenissen zoals Jezus en Schrift"
        case "natuurlijke theologie":
            return "Kennis van God op basis van rede en schepping"
        case "voortgaande continuïteit (algemene/speciale openbaring)":
            return "De gedachte dat speciale openbaring voortbouwt op algemene openbaring"
        case "apologetiek":
            return "Het rationeel verdedigen van het christelijk geloof"
        case "natuurlijke wet":
            return "Moreel besef dat in de schepping en mens is ingebouwd"
        case "geopenbaarde continuïteit":
            return "De gedachte dat speciale openbaring onze kijk herstelt door zonde"
        case "inspiratie (canon)":
            return "De Heilige Geest werkt in de schrijvers van de Bijbel"
        case "illuminatie":
            return "De Heilige Geest helpt gelovigen de Bijbel te begrijpen"
        case "hermeneutiek":
            return "De studie van het correct interpreteren van de Bijbel"
        case "canon":
            return "De verzameling boeken die als gezaghebbend worden gezien"
        case "marcion (historische figuur)":
            return "Persoon die een eigen canon maakte en het OT verwierp"
        case "montanistische controverse":
            return "Discussie over nieuwe openbaring na de apostelen"
        case "concilie van trente":
            return "Concilie dat Schrift en traditie als bronnen van openbaring gelijkwaardig stelde"
        case "tweede vaticaans concilie":
            return "Concilie dat Schrift en traditie samen gezag hebben gelijkwaardig herbevestigde"
        case "apostolische successie":
            return "Doorlopende lijn van apostelen naar kerkelijk gezag"
        case "bijbelse foutloosheid":
            return "De overtuiging dat de Bijbel geen fouten bevat in wat zij leert en stelt"
        case "bijbelse onfeilbaarheid":
            return "De overtuiging dat de Bijbel betrouwbaar is in geloof en redding, ook als niet alles letterlijk wordt opgevat"
        default:
            return card.definition.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    static func distractors(for card: DogmatiekCard) -> [String] {
        switch normalizedTerm(card.term) {
        case "algemene openbaring":
            return [
                "Gods openbaring in specifieke gebeurtenissen zoals Jezus en Schrift",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "De Heilige Geest helpt gelovigen de Bijbel te begrijpen",
            ]
        case "speciale openbaring":
            return [
                "Gods zelfopenbaring in natuur en menselijk geweten",
                "De studie van het correct interpreteren van de Bijbel",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
            ]
        case "natuurlijke theologie":
            return [
                "Gods openbaring in specifieke gebeurtenissen zoals Jezus en Schrift",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "Het rationeel verdedigen van het christelijk geloof",
            ]
        case "voortgaande continuïteit (algemene/speciale openbaring)":
            return [
                "De gedachte dat speciale openbaring onze kijk herstelt door zonde",
                "Theorie over hoe openbaring in fasen binnen de kerk verliep",
                "Leer over inspiratie van auteurs van heilige boeken",
            ]
        case "apologetiek":
            return [
                "De studie van het correct interpreteren van de Bijbel",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "De verzameling boeken die als gezaghebbend worden gezien",
            ]
        case "natuurlijke wet":
            return [
                "Wetten die Mozes op schrift kreeg op de Sinai",
                "Overdracht van geloofsvoorstellingen binnen de kerk",
                "Openbaring van God buiten de schepping om",
            ]
        case "geopenbaarde continuïteit":
            return [
                "De gedachte dat speciale openbaring voortbouwt op algemene openbaring",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "Theorie over inspiratie en canonvorming na de apostelen",
            ]
        case "inspiratie (canon)":
            return [
                "De Heilige Geest helpt gelovigen de Bijbel te begrijpen",
                "De verzameling boeken die als gezaghebbend worden gezien",
                "Openbaring van God in geschiedenis en traditie",
            ]
        case "illuminatie":
            return [
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "De studie van het correct interpreteren van de Bijbel",
                "Openbaring van God in geschiedenis en traditie",
            ]
        case "hermeneutiek":
            return [
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "De verzameling boeken die als gezaghebbend worden gezien",
                "Openbaring van God in geschiedenis en traditie",
            ]
        case "canon":
            return [
                "Overdracht van geloofsvoorstellingen binnen de kerk",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "Openbaring van God in geschiedenis en traditie",
            ]
        case "marcion (historische figuur)":
            return [
                "Leerde dat de mens zich zonder fundamentele genade kan redden (Pelagius)",
                "Kerkvader van Hippo; benadrukte genade, erfzonde en voorbestemming",
                "Leerde dat de Zoon een schepsel is, niet één in wezen met de Vader (Arius)",
            ]
        case "montanistische controverse":
            return [
                "Discussie over welke boeken tot de Bijbel gingen behoren",
                "Conflict tussen kerk en vorsten over kerkelijke goederen",
                "Strijd over de plaats van traditie naast de Schrift",
            ]
        case "concilie van trente":
            return [
                "Concilie dat vooral de Zoon één in wezen met de Vader stelde",
                "Concilie dat de twee naturen van Christus in één persoon definieerde",
                "Concilie dat Schrift en traditie samen gezag hebben gelijkwaardig herbevestigde",
            ]
        case "tweede vaticaans concilie":
            return [
                "Concilie dat Schrift en traditie als bronnen van openbaring gelijkwaardig stelde",
                "Concilie dat vooral de Zoon één in wezen met de Vader stelde",
                "Concilie dat de twee naturen van Christus in één persoon definieerde",
            ]
        case "apostolische successie":
            return [
                "Overdracht van geloofsvoorstellingen binnen de kerk",
                "De verzameling boeken die als gezaghebbend worden gezien",
                "Openbaring van God in geschiedenis en traditie",
            ]
        case "bijbelse foutloosheid":
            return [
                "De overtuiging dat de Bijbel betrouwbaar is in geloof en redding, ook als niet alles letterlijk wordt opgevat",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
                "De verzameling boeken die als gezaghebbend worden gezien",
            ]
        case "bijbelse onfeilbaarheid":
            return [
                "De overtuiging dat de Bijbel geen fouten bevat in wat zij leert en stelt",
                "De studie van het correct interpreteren van de Bijbel",
                "De Heilige Geest werkt in de schrijvers van de Bijbel",
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
