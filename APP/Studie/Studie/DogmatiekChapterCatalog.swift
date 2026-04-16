//
//  DogmatiekChapterCatalog.swift
//  Studie
//

import Foundation

enum DogmatiekChapterCatalog {
    /// Vaste volgorde voor secties en kiezers (zoals in het studiemateriaal).
    static let orderedTitles: [String] = [
        "Inleiding",
        "Hoofdstuk 1",
        "Hoofdstuk 2",
        "Hoofdstuk 3",
        "Hoofdstuk 4",
        "Hoofdstuk 5",
        "Hoofdstuk 6",
        "Hoofdstuk 7",
        "Hoofdstuk 8",
        "Hoofdstuk 9",
        "Overig",
    ]

    static let sortRank: [String: Int] = Dictionary(
        uniqueKeysWithValues: orderedTitles.enumerated().map { ($0.element, $0.offset) }
    )

    static func rank(for chapter: String) -> Int {
        sortRank[chapter] ?? 500
    }

    /// Suggesties voor subgroep (termen beheren).
    static let subgroupSuggestions: [String] = [
        "Imago Dei",
        "Instandhouding, medewerking en bestuur",
    ]
}
