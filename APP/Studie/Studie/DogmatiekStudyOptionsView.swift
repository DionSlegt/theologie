//
//  DogmatiekStudyOptionsView.swift
//  Studie
//

import SwiftUI

private enum PracticeInputMix: Hashable {
    case typingOnly
    case multipleChoiceOnly
    case mixed
    case revealBlankOnly
}

struct DogmatiekStudyOptionsView: View {
    @Environment(DogmatiekStore.self) private var store
    @State private var selectedChapters: Set<String> = []
    @State private var includeTyping = true
    @State private var includeMultipleChoice = false
    @State private var includeRevealBlank = false
    @State private var practicePromptStyle: DogmatiekPracticePromptStyle = .termThenPickDefinition
    @State private var chaptersExpanded = false
    @State private var practiceModeSheetPresented = false
    @State private var inputMixPicker: PracticeInputMix = .typingOnly

    private var groups: [(title: String, cards: [DogmatiekCard])] {
        store.groupedCards()
    }

    private var selectedTermCount: Int {
        store.cards.filter { selectedChapters.contains($0.chapter) }.count
    }

    private var practiceConfiguration: DogmatiekStudyConfiguration {
        DogmatiekStudyConfiguration(
            includeTyping: includeTyping,
            includeMultipleChoice: includeMultipleChoice,
            includeRevealBlank: includeRevealBlank,
            practicePromptStyle: practicePromptStyle
        )
    }

    private var canStartPractice: Bool {
        practiceConfiguration.canStart
    }

    /// Er is ergens in de bibliotheek minstens één kaart uit een hoofdstuk met meerkeuze-sets.
    private var anyMcqChapterAvailable: Bool {
        store.cards.contains { DogmatiekPracticeInputMode.multipleChoiceMode(forChapter: $0.chapter) != nil }
    }

    private func uniqueCards(_ cards: [DogmatiekCard]) -> [DogmatiekCard] {
        Array(Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) }).values)
    }

    private func mcqCapableCount(in cards: [DogmatiekCard]) -> Int {
        uniqueCards(cards).filter { DogmatiekPracticeInputMode.multipleChoiceMode(forChapter: $0.chapter) != nil }.count
    }

    private var allChapterTitles: Set<String> {
        Set(groups.map(\.title))
    }

    private var isEveryChapterSelected: Bool {
        !groups.isEmpty && selectedChapters == allChapterTitles
    }

    private var totalTermsInLibrary: Int {
        groups.reduce(0) { $0 + $1.cards.count }
    }

    private var promptDirectionSummaryShort: String {
        switch practicePromptStyle {
        case .termThenPickDefinition: return "term → definitie"
        case .definitionThenPickTerm: return "definitie → term"
        case .mixed: return "richting gemengd"
        }
    }

    private var practiceModeSummary: String {
        let dir = " · \(promptDirectionSummaryShort)"
        if includeRevealBlank, !includeTyping, !includeMultipleChoice {
            return "Leeg vlak\(dir)"
        }
        if includeTyping, includeMultipleChoice {
            return "Typen + meerkeuze\(dir)"
        }
        if includeMultipleChoice {
            return "Alleen meerkeuze\(dir)"
        }
        return "Alleen typen\(dir)"
    }

    var body: some View {
        List {
            Section {
                Button {
                    syncInputMixFromBools()
                    practiceModeSheetPresented = true
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 28, alignment: .center)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Oefenmodus")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(practiceModeSummary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                    .frame(minHeight: 48)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Stel in of je typt, meerkeuze doet, leeg vlak gebruikt, of gemengd, en of je term of definitie eerst ziet.")
            } footer: {
                Text("Meerkeuze met vaste antwoorden: Inleiding en hoofdstuk 1 t/m 7 en 9. Andere hoofdstukken alleen via typen.")
                    .font(.footnote)
            }
            .onAppear {
                syncPracticeOptions()
            }
            .onChange(of: store.cards.count) { _, _ in
                syncPracticeOptions()
            }

            Section {
                DisclosureGroup(isExpanded: $chaptersExpanded) {
                    Button {
                        if isEveryChapterSelected {
                            selectedChapters.removeAll()
                        } else {
                            selectedChapters = allChapterTitles
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: isEveryChapterSelected ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(isEveryChapterSelected ? Color.accentColor : .secondary)
                                .frame(width: 28, alignment: .center)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Alle hoofdstukken")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("\(totalTermsInLibrary) termen")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isEveryChapterSelected ? "Alle hoofdstukken deselecteren" : "Alle hoofdstukken selecteren")
                    .accessibilityAddTraits(isEveryChapterSelected ? .isSelected : [])

                    ForEach(groups, id: \.title) { group in
                        Button {
                            if selectedChapters.contains(group.title) {
                                selectedChapters.remove(group.title)
                            } else {
                                selectedChapters.insert(group.title)
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: selectedChapters.contains(group.title) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(selectedChapters.contains(group.title) ? Color.accentColor : .secondary)
                                    .frame(width: 28, alignment: .center)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text("\(group.cards.count) termen")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 0)
                            }
                            .contentShape(Rectangle())
                            .frame(minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedChapters.contains(group.title) ? .isSelected : [])
                    }
                } label: {
                    HStack {
                        Text("Hoofdstukken")
                        Spacer()
                        Text(chaptersSelectionSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .accessibilityHint("Tik om hoofdstukken te tonen of te verbergen.")
            } footer: {
                Text("‘Alle hoofdstukken’ selecteert alles tegelijk; nog een tik deselecteert alles weer. Start met de knop onderaan.")
                    .font(.footnote)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                VStack(alignment: .center, spacing: 10) {
                    Group {
                        if !canStartPractice {
                            Text("Tik op Oefenmodus en kies typen, meerkeuze, leeg vlak of gemengd.")
                        } else if selectedChapters.isEmpty {
                            Text("Kies minstens één hoofdstuk in het menu hierboven.")
                        } else {
                            Text(selectionLinkSubtitle)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    NavigationLink {
                        DogmatiekStudyView(route: .chapters(selectedChapters), configuration: practiceConfiguration)
                    } label: {
                        Label("Start met selectie", systemImage: "play.circle.fill")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canStartPractice || selectedChapters.isEmpty)
                    .opacity((!canStartPractice || selectedChapters.isEmpty) ? 0.45 : 1)
                    .accessibilityHint(
                        !canStartPractice
                            ? "Stel eerst Oefenmodus in."
                            : selectedChapters.isEmpty
                                ? "Selecteer eerst hoofdstukken in het uitklapmenu."
                                : "Start met de gekozen hoofdstukken."
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.bar)
            }
        }
        .navigationTitle("Oefenen")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Wis selectie") {
                    selectedChapters.removeAll()
                }
                .disabled(selectedChapters.isEmpty)
                .accessibilityLabel("Alle gekozen hoofdstukken wissen")
            }
        }
        .sheet(isPresented: $practiceModeSheetPresented) {
            practiceModeSheet
        }
    }

    @ViewBuilder
    private var practiceModeSheet: some View {
        NavigationStack {
            Form {
                Section {
                    if anyMcqChapterAvailable {
                        Picker(selection: $inputMixPicker) {
                            Text("Typen").tag(PracticeInputMix.typingOnly)
                            Text("Meerkeuze").tag(PracticeInputMix.multipleChoiceOnly)
                            Text("Typen en meerkeuze door elkaar").tag(PracticeInputMix.mixed)
                            Text("Leeg vlak").tag(PracticeInputMix.revealBlankOnly)
                        } label: {
                            EmptyView()
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                        .accessibilityLabel("Soort oefening")
                        .onChange(of: inputMixPicker) { _, new in
                            applyPracticeInputMix(new)
                        }
                    } else {
                        Picker(selection: $inputMixPicker) {
                            Text("Typen").tag(PracticeInputMix.typingOnly)
                            Text("Leeg vlak").tag(PracticeInputMix.revealBlankOnly)
                        } label: {
                            EmptyView()
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                        .accessibilityLabel("Soort oefening")
                        .onChange(of: inputMixPicker) { _, new in
                            applyPracticeInputMix(new)
                        }
                    }
                } header: {
                    Text("Soort oefening")
                } footer: {
                    if anyMcqChapterAvailable {
                        Text("Typen en meerkeuze: per term hoogstens één vraag in dezelfde ronde — óf typen óf meerkeuze. Leeg vlak: alleen prompt, daarna zelf het antwoord tonen.")
                    } else {
                        Text("Meerkeuze is er nog niet voor je huidige kaarten. Je kunt wel typen of Leeg vlak gebruiken. Voeg termen toe aan Inleiding of hoofdstuk 1 t/m 7 of 9 voor meerkeuze.")
                    }
                }

                if includeTyping || includeMultipleChoice || includeRevealBlank {
                    Section {
                        Picker(selection: $practicePromptStyle) {
                            Text("Term → definitie").tag(DogmatiekPracticePromptStyle.termThenPickDefinition)
                            Text("Definitie → term").tag(DogmatiekPracticePromptStyle.definitionThenPickTerm)
                            Text("Gemengd (wisselend per vraag)").tag(DogmatiekPracticePromptStyle.mixed)
                        } label: {
                            EmptyView()
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                        .accessibilityLabel("Richting: term of definitie eerst")
                    } header: {
                        Text("Richting")
                    } footer: {
                        Text("Geldt voor typen, meerkeuze en leeg vlak. Bij gemengd kiest elke typ- en elke meerkeuzevraag apart willekeurig welke kant eerst komt.")
                    }
                }
            }
            .navigationTitle("Oefenmodus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gereed") {
                        practiceModeSheetPresented = false
                    }
                }
            }
            .onAppear {
                syncInputMixFromBools()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func syncInputMixFromBools() {
        if includeRevealBlank, !includeTyping, !includeMultipleChoice {
            inputMixPicker = .revealBlankOnly
        } else if includeTyping, includeMultipleChoice {
            inputMixPicker = .mixed
        } else if includeMultipleChoice {
            inputMixPicker = .multipleChoiceOnly
        } else {
            inputMixPicker = .typingOnly
        }
    }

    private func applyPracticeInputMix(_ mix: PracticeInputMix) {
        switch mix {
        case .typingOnly:
            includeTyping = true
            includeMultipleChoice = false
            includeRevealBlank = false
        case .multipleChoiceOnly:
            includeTyping = false
            includeRevealBlank = false
            includeMultipleChoice = anyMcqChapterAvailable
        case .mixed:
            includeTyping = true
            includeRevealBlank = false
            includeMultipleChoice = anyMcqChapterAvailable
        case .revealBlankOnly:
            includeTyping = false
            includeMultipleChoice = false
            includeRevealBlank = true
        }
        syncPracticeOptions()
    }

    private var chaptersSelectionSummary: String {
        if selectedChapters.isEmpty {
            return "geen gekozen"
        }
        if isEveryChapterSelected {
            return "alles"
        }
        return "\(selectedChapters.count) van \(groups.count)"
    }

    private var selectionLinkSubtitle: String {
        let c = practiceConfiguration
        let sel = store.cards.filter { selectedChapters.contains($0.chapter) }
        let cards = uniqueCards(sel)
        let nMcq = mcqCapableCount(in: sel)
        if c.includeRevealBlank, !c.includeTyping, !c.includeMultipleChoice {
            let dirReveal = c.practicePromptStyle == .mixed ? " — richting per vraag gemengd" : ""
            return "\(cards.count) vragen — leeg vlak\(dirReveal)"
        }
        if c.includeTyping && c.includeMultipleChoice {
            let dir = c.practicePromptStyle == .mixed ? " — typen en meerkeuze elk richting gemengd" : ""
            return "\(cards.count) vragen — per term óf typen óf meerkeuze\(dir)"
        }
        if c.includeMultipleChoice {
            let dir = c.practicePromptStyle == .mixed ? " — richting per vraag gemengd" : ""
            return "\(nMcq) vragen — alleen meerkeuze\(dir)"
        }
        let dirTyping = c.practicePromptStyle == .mixed ? " — richting per vraag gemengd" : ""
        return "\(selectedTermCount) termen uit \(selectedChapters.count) hoofdstuk\(selectedChapters.count == 1 ? "" : "ken")\(dirTyping)"
    }

    private func syncPracticeOptions() {
        if !includeTyping && !includeMultipleChoice && !includeRevealBlank {
            includeTyping = true
            includeRevealBlank = false
        }
        if includeMultipleChoice && !anyMcqChapterAvailable {
            includeMultipleChoice = false
        }
        if includeRevealBlank {
            includeTyping = false
            includeMultipleChoice = false
        }
        syncInputMixFromBools()
    }
}

#Preview {
    NavigationStack {
        DogmatiekStudyOptionsView()
    }
    .environment(DogmatiekStore())
}
