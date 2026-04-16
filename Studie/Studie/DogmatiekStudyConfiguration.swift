//
//  DogmatiekStudyConfiguration.swift
//  Studie
//

import Foundation

/// Welke kant van de kaart je eerst ziet: geldt voor **typen** (wat je intypt) en voor **meerkeuze** (wat je kiest).
/// Vaste antwoordregels voor meerkeuze blijven per hoofdstuk gelden.
enum DogmatiekPracticePromptStyle: String, CaseIterable, Hashable, Sendable {
    /// Term eerst: typ of kies de definitie (antwoordregel).
    case termThenPickDefinition
    /// Definitie eerst: typ of kies het begrip (term).
    case definitionThenPickTerm
    /// Per vraag willekeurig term→definitie of definitie→term (typen en meerkeuze elk apart willekeurig).
    case mixed
}

/// Instellingen voor één oefensessie: vrij typen, meerkeuze, leeg vlak (zelf checken), of beide door elkaar.
/// Meerkeuze gebruikt dezelfde kaarten als typen (alle hoofdstukken of je vinkjes); per kaart bepaalt het hoofdstuk welke meerkeuze-set geldt.
struct DogmatiekStudyConfiguration: Hashable {
    /// Term of definitie intypen.
    var includeTyping: Bool
    /// Meerkeuze (alleen voor kaarten uit hoofdstukken waarvoor meerkeuze is ingericht).
    var includeMultipleChoice: Bool
    /// Alleen prompt tonen; daarna zelf het antwoord laten verschijnen (geen invoer).
    var includeRevealBlank: Bool
    /// Richting van de vraag: term of definitie eerst — voor typen, meerkeuze én leeg vlak.
    var practicePromptStyle: DogmatiekPracticePromptStyle

    /// Minstens één manier moet aan staan om te kunnen starten.
    var canStart: Bool { includeTyping || includeMultipleChoice || includeRevealBlank }

    /// Standaard: alleen typen.
    static let `default` = DogmatiekStudyConfiguration(
        includeTyping: true,
        includeMultipleChoice: false,
        includeRevealBlank: false,
        practicePromptStyle: .termThenPickDefinition
    )
}
