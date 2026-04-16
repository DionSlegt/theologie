//
//  DogmatiekPracticeInputMode.swift
//  Studie
//

import Foundation

/// Hoe antwoorden worden ingevoerd tijdens Dogmatiek-oefenen.
enum DogmatiekPracticeInputMode: Equatable, Hashable {
    /// Meerkeuze met vaste antwoordregels is ingericht voor deze hoofdstuktitels (`DogmatiekCard.chapter`).
    static func multipleChoiceMode(forChapter chapter: String) -> DogmatiekPracticeInputMode? {
        switch chapter {
        case DogmatiekIntroMultipleChoice.inleidingChapter:
            return .multipleChoiceInleiding
        case DogmatiekHoofdstuk1MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk1
        case DogmatiekHoofdstuk2MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk2
        case DogmatiekHoofdstuk3MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk3
        case DogmatiekHoofdstuk4MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk4
        case DogmatiekHoofdstuk5MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk5
        case DogmatiekHoofdstuk6MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk6
        case DogmatiekHoofdstuk7MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk7
        case DogmatiekHoofdstuk9MultipleChoice.chapterTitle:
            return .multipleChoiceHoofdstuk9
        default:
            return nil
        }
    }

    /// Vrij typen (term of definitie).
    case typed
    /// Vier meerkeuze-opties; alleen kaarten uit de Inleiding.
    case multipleChoiceInleiding
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 1.
    case multipleChoiceHoofdstuk1
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 2.
    case multipleChoiceHoofdstuk2
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 3.
    case multipleChoiceHoofdstuk3
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 4.
    case multipleChoiceHoofdstuk4
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 5.
    case multipleChoiceHoofdstuk5
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 6.
    case multipleChoiceHoofdstuk6
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 7.
    case multipleChoiceHoofdstuk7
    /// Vier meerkeuze-opties; alleen kaarten uit Hoofdstuk 9.
    case multipleChoiceHoofdstuk9

    var usesMultipleChoice: Bool {
        switch self {
        case .typed: false
        case .multipleChoiceInleiding, .multipleChoiceHoofdstuk1, .multipleChoiceHoofdstuk2,
                .multipleChoiceHoofdstuk3, .multipleChoiceHoofdstuk4, .multipleChoiceHoofdstuk5,
                .multipleChoiceHoofdstuk6, .multipleChoiceHoofdstuk7, .multipleChoiceHoofdstuk9:
            true
        }
    }

    /// Hoofdstuk waarvan alle termen worden geoefend bij deze meerkeuzemodus; `nil` bij typen.
    var mcqChapterFilter: String? {
        switch self {
        case .typed:
            return nil
        case .multipleChoiceInleiding:
            return DogmatiekIntroMultipleChoice.inleidingChapter
        case .multipleChoiceHoofdstuk1:
            return DogmatiekHoofdstuk1MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk2:
            return DogmatiekHoofdstuk2MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk3:
            return DogmatiekHoofdstuk3MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk4:
            return DogmatiekHoofdstuk4MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk5:
            return DogmatiekHoofdstuk5MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk6:
            return DogmatiekHoofdstuk6MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk7:
            return DogmatiekHoofdstuk7MultipleChoice.chapterTitle
        case .multipleChoiceHoofdstuk9:
            return DogmatiekHoofdstuk9MultipleChoice.chapterTitle
        }
    }

    func mcqOptionPool(for card: DogmatiekCard) -> [String] {
        switch self {
        case .typed:
            return []
        case .multipleChoiceInleiding:
            return DogmatiekIntroMultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk1:
            return DogmatiekHoofdstuk1MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk2:
            return DogmatiekHoofdstuk2MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk3:
            return DogmatiekHoofdstuk3MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk4:
            return DogmatiekHoofdstuk4MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk5:
            return DogmatiekHoofdstuk5MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk6:
            return DogmatiekHoofdstuk6MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk7:
            return DogmatiekHoofdstuk7MultipleChoice.optionPool(for: card)
        case .multipleChoiceHoofdstuk9:
            return DogmatiekHoofdstuk9MultipleChoice.optionPool(for: card)
        }
    }

    func mcqCorrectAnswerLine(for card: DogmatiekCard) -> String {
        switch self {
        case .typed:
            return card.definition
        case .multipleChoiceInleiding:
            return DogmatiekIntroMultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk1:
            return DogmatiekHoofdstuk1MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk2:
            return DogmatiekHoofdstuk2MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk3:
            return DogmatiekHoofdstuk3MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk4:
            return DogmatiekHoofdstuk4MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk5:
            return DogmatiekHoofdstuk5MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk6:
            return DogmatiekHoofdstuk6MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk7:
            return DogmatiekHoofdstuk7MultipleChoice.correctAnswerLine(for: card)
        case .multipleChoiceHoofdstuk9:
            return DogmatiekHoofdstuk9MultipleChoice.correctAnswerLine(for: card)
        }
    }

    func mcqSupplementaryPrompt(for card: DogmatiekCard) -> String? {
        switch self {
        case .multipleChoiceHoofdstuk1:
            return DogmatiekHoofdstuk1MultipleChoice.supplementaryPrompt(for: card)
        case .multipleChoiceHoofdstuk4:
            return DogmatiekHoofdstuk4MultipleChoice.supplementaryPrompt(for: card)
        case .typed, .multipleChoiceInleiding, .multipleChoiceHoofdstuk2, .multipleChoiceHoofdstuk3,
                .multipleChoiceHoofdstuk5, .multipleChoiceHoofdstuk6, .multipleChoiceHoofdstuk7, .multipleChoiceHoofdstuk9:
            return nil
        }
    }
}
