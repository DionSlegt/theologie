//
//  DogmatiekCard.swift
//  Studie
//

import Foundation

struct DogmatiekCard: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var term: String
    var definition: String
    /// Hoofdstuk of sectie (bijv. "Hoofdstuk 2", "Overig").
    var chapter: String
    /// Positie in het brondocument (JSON-volgorde); `nil` = zelf toegevoegd of onbekend — komt onderaan in het hoofdstuk.
    var documentIndex: Int?
    /// Optionele subgroep binnen het hoofdstuk (bijv. "Imago Dei") voor weergave in de lijst.
    var subgroup: String?
    /// Extra uitleg (bijlage); wordt bij oefenen getoond, niet als aparte vraag.
    var contextNote: String?
    /// Brondocument (handboek), voor weergave als „blz …” bij vragen.
    var sourcePage: Int?

    static let fallbackChapter = "Overig"

    init(
        id: UUID = UUID(),
        term: String,
        definition: String,
        chapter: String = Self.fallbackChapter,
        documentIndex: Int? = nil,
        subgroup: String? = nil,
        contextNote: String? = nil,
        sourcePage: Int? = nil
    ) {
        self.id = id
        self.term = term
        self.definition = definition
        self.chapter = chapter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? Self.fallbackChapter
            : chapter.trimmingCharacters(in: .whitespacesAndNewlines)
        self.documentIndex = documentIndex
        if let s = subgroup?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            self.subgroup = s
        } else {
            self.subgroup = nil
        }
        if let n = contextNote?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            self.contextNote = n
        } else {
            self.contextNote = nil
        }
        self.sourcePage = sourcePage
    }

    enum CodingKeys: String, CodingKey {
        case id
        case term
        case definition
        case chapter
        case documentIndex
        case subgroup
        case contextNote
        case sourcePage
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        term = try c.decode(String.self, forKey: .term)
        definition = try c.decode(String.self, forKey: .definition)
        if let ch = try c.decodeIfPresent(String.self, forKey: .chapter),
           !ch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chapter = ch.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            chapter = Self.fallbackChapter
        }
        documentIndex = try c.decodeIfPresent(Int.self, forKey: .documentIndex)
        if let s = try c.decodeIfPresent(String.self, forKey: .subgroup)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            subgroup = s
        } else {
            subgroup = nil
        }
        if let n = try c.decodeIfPresent(String.self, forKey: .contextNote)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            contextNote = n
        } else {
            contextNote = nil
        }
        sourcePage = try c.decodeIfPresent(Int.self, forKey: .sourcePage)
    }
}

enum DogmatiekAnswerCheck {
    private static let nlLocale = Locale(identifier: "nl_NL")

    /// `true` als het antwoord inhoudelijk dicht genoeg bij het model ligt (niet alleen letterlijk gelijk).
    static func matches(_ userInput: String, expected: String) -> Bool {
        let u = normalizeForComparison(userInput)
        let e = normalizeForComparison(expected)
        if u.isEmpty && e.isEmpty { return true }
        if u.isEmpty || e.isEmpty { return false }
        if u == e { return true }

        let charSim = levenshteinSimilarity(u, e)
        let userTok = meaningfulTokens(from: u)
        let expTok = meaningfulTokens(from: e)

        if expTok.isEmpty {
            return charSim >= 0.88
        }

        let jac = jaccard(userTok, expTok)
        let cov = tokenCoverage(userTokens: userTok, expectedTokens: expTok)

        if expTok.count <= 2 {
            return charSim >= 0.82 || cov >= 0.99
        }

        if charSim >= 0.78 { return true }
        if jac >= 0.52 { return true }
        if cov >= 0.68 { return true }
        if charSim >= 0.64 && jac >= 0.38 { return true }

        return false
    }

    /// Zelfde normalisatie als voorheen: alleen voor deduplicatie bij importeren (stabiel, licht).
    static func normalizedKey(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        return lower.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
    }

    // MARK: - Vergelijken

    private static func normalizeForComparison(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        t = t.folding(options: .diacriticInsensitive, locale: nlLocale)
        t = t.lowercased()
        let mapped = t.map { ch -> Character in
            if ch.isLetter || ch.isNumber { return ch }
            return " "
        }
        return String(mapped)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }

    private static let dutchStopwords: Set<String> = [
        "de", "het", "een", "en", "van", "in", "op", "te", "ter", "dat", "die", "dit", "deze", "is", "zijn",
        "was", "waren", "wordt", "worden", "aan", "bij", "als", "voor", "niet", "ook", "naar", "dan", "om",
        "uit", "nog", "over", "zo", "maar", "meer", "al", "alle", "door", "tot", "ze", "zich", "er", "hun",
        "haar", "hem", "wel", "kan", "kunnen", "moet", "moeten", "zal", "zou", "willen", "bijvoorbeeld",
        "iets", "wat", "wie", "waar", "hoe", "daar", "hier", "met", "zonder", "tegen", "tussen",
    ]

    private static func meaningfulTokens(from normalized: String) -> Set<String> {
        normalized.split(separator: " ")
            .map(String.init)
            .filter { $0.count >= 2 && !dutchStopwords.contains($0) }
            .reduce(into: Set()) { $0.insert($1) }
    }

    private static func jaccard(_ a: Set<String>, _ b: Set<String>) -> Double {
        guard !a.isEmpty || !b.isEmpty else { return 1 }
        let inter = a.intersection(b).count
        let union = a.union(b).count
        guard union > 0 else { return 0 }
        return Double(inter) / Double(union)
    }

    private static func tokenCoverage(userTokens: Set<String>, expectedTokens: Set<String>) -> Double {
        guard !expectedTokens.isEmpty else { return 0 }
        let hits = expectedTokens.filter { userTokens.contains($0) }.count
        return Double(hits) / Double(expectedTokens.count)
    }

    /// 1 − genormaliseerde Levenshtein-afstand (0…1).
    private static func levenshteinSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count
        let n = bChars.count
        if m == 0 { return n == 0 ? 1 : 0 }
        if n == 0 { return 0 }
        if m * n > 400_000 { return 0 }

        var prev = Array(0...n)
        var curr = Array(repeating: 0, count: n + 1)
        for i in 1...m {
            curr[0] = i
            let ac = aChars[i - 1]
            for j in 1...n {
                let cost = ac == bChars[j - 1] ? 0 : 1
                curr[j] = min(curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost)
            }
            swap(&prev, &curr)
        }
        let dist = prev[n]
        return 1.0 - Double(dist) / Double(max(m, n))
    }
}
