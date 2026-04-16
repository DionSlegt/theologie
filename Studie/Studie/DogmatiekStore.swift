//
//  DogmatiekStore.swift
//  Studie
//

import Foundation
import SwiftUI

struct DogmatiekNestedChapter: Identifiable {
    let id: String
    let chapter: String
    let subgroups: [DogmatiekNestedSubgroup]
}

struct DogmatiekNestedSubgroup: Identifiable {
    let id: String
    let title: String?
    let cards: [DogmatiekCard]
}

@MainActor
@Observable
final class DogmatiekStore {
    private static let storageKey = "dogmatiek_cards_v1"
    private static let bundledTermsResource = "PracticingChristianDoctrineTerms"

    private struct BundledTermRow: Decodable {
        let term: String
        let definition: String
        let chapter: String?
        let subgroup: String?
        let contextNote: String?
        let sourcePage: Int?
    }

    private struct BundledTermMeta {
        let chapter: String
        let subgroup: String?
        let contextNote: String?
        let documentIndex: Int
        let sourcePage: Int?
    }

    enum BundledTermsImportResult: Equatable {
        case added(Int)
        case noneNew
        case bundleMissing
    }

    var cards: [DogmatiekCard] = []

    init() {
        load()
        removeObsoleteCardsIfNeeded()
        applyBundleMetadataFromJSON()
        // Altijd bundel mergen: nieuwe termen in de app-JSON (bijv. extra hoofdstukken) toevoegen zonder bestaande kaarten te wissen.
        _ = importPracticingChristianDoctrineTermsFromBundle()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else {
            cards = []
            return
        }
        do {
            cards = try JSONDecoder().decode([DogmatiekCard].self, from: data)
        } catch {
            cards = []
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(cards)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
            // Persistence failure is rare; state remains in memory for this session.
        }
    }

    /// Groepeert per hoofdstuk; binnen een hoofdstuk op documentvolgorde.
    func groupedCards() -> [(title: String, cards: [DogmatiekCard])] {
        let byChapter = Dictionary(grouping: cards) { $0.chapter }
        let titles = byChapter.keys.sorted { a, b in
            let ra = DogmatiekChapterCatalog.rank(for: a)
            let rb = DogmatiekChapterCatalog.rank(for: b)
            if ra != rb { return ra < rb }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
        return titles.map { title in
            let sorted = (byChapter[title] ?? []).sorted { a, b in
                let ia = a.documentIndex ?? Int.max
                let ib = b.documentIndex ?? Int.max
                if ia != ib { return ia < ib }
                return a.term.localizedCaseInsensitiveCompare(b.term) == .orderedAscending
            }
            return (title: title, cards: sorted)
        }
    }

    /// Zelfde als `groupedCards`, met subsecties voor subgroepen (o.a. Imago Dei, instandhouding).
    func nestedChapters() -> [DogmatiekNestedChapter] {
        groupedCards().map { chapterTitle, chapterCards in
            let subgroups = Self.splitIntoSubgroups(chapterCards).enumerated().map { idx, pair in
                let (subTitle, subCards) = pair
                return DogmatiekNestedSubgroup(
                    id: "\(chapterTitle)_\(idx)_\(subTitle ?? "los")",
                    title: subTitle,
                    cards: subCards
                )
            }
            return DogmatiekNestedChapter(
                id: chapterTitle,
                chapter: chapterTitle,
                subgroups: subgroups
            )
        }
    }

    private static func splitIntoSubgroups(_ cards: [DogmatiekCard]) -> [(String?, [DogmatiekCard])] {
        guard !cards.isEmpty else { return [] }
        var blocks: [(String?, [DogmatiekCard])] = []
        var currentKey = cards[0].subgroup
        var bucket: [DogmatiekCard] = [cards[0]]
        for card in cards.dropFirst() {
            if card.subgroup == currentKey {
                bucket.append(card)
            } else {
                blocks.append((currentKey, bucket))
                currentKey = card.subgroup
                bucket = [card]
            }
        }
        blocks.append((currentKey, bucket))
        return blocks
    }

    func cards(forChapter title: String) -> [DogmatiekCard] {
        cards.filter { $0.chapter == title }
    }

    func add(
        term: String,
        definition: String,
        chapter: String = DogmatiekCard.fallbackChapter,
        subgroup: String? = nil,
        contextNote: String? = nil
    ) {
        let t = term.trimmingCharacters(in: .whitespacesAndNewlines)
        let d = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !d.isEmpty else { return }
        cards.append(
            DogmatiekCard(
                term: t,
                definition: d,
                chapter: chapter,
                documentIndex: nil,
                subgroup: subgroup,
                contextNote: contextNote
            )
        )
        save()
    }

    func update(
        _ card: DogmatiekCard,
        term: String,
        definition: String,
        chapter: String,
        subgroup: String?,
        contextNote: String?
    ) {
        let t = term.trimmingCharacters(in: .whitespacesAndNewlines)
        let d = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !d.isEmpty else { return }
        guard let i = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[i].term = t
        cards[i].definition = d
        cards[i].chapter = chapter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? DogmatiekCard.fallbackChapter
            : chapter.trimmingCharacters(in: .whitespacesAndNewlines)
        let sg = subgroup?.trimmingCharacters(in: .whitespacesAndNewlines)
        cards[i].subgroup = (sg == nil || sg?.isEmpty == true) ? nil : sg
        let cn = contextNote?.trimmingCharacters(in: .whitespacesAndNewlines)
        cards[i].contextNote = (cn == nil || cn?.isEmpty == true) ? nil : cn
        save()
    }

    func delete(_ card: DogmatiekCard) {
        cards.removeAll { $0.id == card.id }
        save()
    }

    @discardableResult
    func importPracticingChristianDoctrineTermsFromBundle() -> BundledTermsImportResult {
        guard let url = Bundle.main.url(forResource: Self.bundledTermsResource, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return .bundleMissing
        }
        do {
            let rows = try JSONDecoder().decode([BundledTermRow].self, from: data)
            var existing = Set(cards.map { DogmatiekAnswerCheck.normalizedKey($0.term) })
            var added = 0
            for (documentIndex, row) in rows.enumerated() {
                let t = row.term.trimmingCharacters(in: .whitespacesAndNewlines)
                let d = row.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty, !d.isEmpty else { continue }
                let key = DogmatiekAnswerCheck.normalizedKey(t)
                guard !existing.contains(key) else { continue }
                existing.insert(key)
                let ch = Self.bundledChapter(from: row.chapter)
                let sg = Self.bundledOptionalString(row.subgroup)
                let note = Self.bundledOptionalString(row.contextNote)
                cards.append(
                    DogmatiekCard(
                        term: t,
                        definition: d,
                        chapter: ch,
                        documentIndex: documentIndex,
                        subgroup: sg,
                        contextNote: note,
                        sourcePage: row.sourcePage
                    )
                )
                added += 1
            }
            if added > 0 {
                save()
                return .added(added)
            }
            return .noneNew
        } catch {
            return .bundleMissing
        }
    }

    private func removeObsoleteCardsIfNeeded() {
        let obsoleteTerms: Set<String> = [
            DogmatiekAnswerCheck.normalizedKey("Drie visies op Imago Dei en zonde"),
        ]
        let before = cards.count
        cards.removeAll { obsoleteTerms.contains(DogmatiekAnswerCheck.normalizedKey($0.term)) }
        if cards.count != before {
            save()
        }
    }

    private func applyBundleMetadataFromJSON() {
        guard let url = Bundle.main.url(forResource: Self.bundledTermsResource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONDecoder().decode([BundledTermRow].self, from: data)
        else {
            return
        }
        var map: [String: BundledTermMeta] = [:]
        for (index, row) in rows.enumerated() {
            let t = row.term.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { continue }
            let key = DogmatiekAnswerCheck.normalizedKey(t)
            map[key] = BundledTermMeta(
                chapter: Self.bundledChapter(from: row.chapter),
                subgroup: Self.bundledOptionalString(row.subgroup),
                contextNote: Self.bundledOptionalString(row.contextNote),
                documentIndex: index,
                sourcePage: row.sourcePage
            )
        }
        var changed = false
        for i in cards.indices {
            let key = DogmatiekAnswerCheck.normalizedKey(cards[i].term)
            guard let meta = map[key] else { continue }
            if cards[i].chapter != meta.chapter {
                cards[i].chapter = meta.chapter
                changed = true
            }
            if cards[i].documentIndex != meta.documentIndex {
                cards[i].documentIndex = meta.documentIndex
                changed = true
            }
            if cards[i].subgroup != meta.subgroup {
                cards[i].subgroup = meta.subgroup
                changed = true
            }
            if cards[i].contextNote != meta.contextNote {
                cards[i].contextNote = meta.contextNote
                changed = true
            }
            if cards[i].sourcePage != meta.sourcePage {
                cards[i].sourcePage = meta.sourcePage
                changed = true
            }
        }
        if changed {
            save()
        }
    }

    private static func bundledChapter(from raw: String?) -> String {
        guard let s = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else {
            return DogmatiekCard.fallbackChapter
        }
        return s
    }

    private static func bundledOptionalString(_ raw: String?) -> String? {
        guard let s = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else {
            return nil
        }
        return s
    }
}
