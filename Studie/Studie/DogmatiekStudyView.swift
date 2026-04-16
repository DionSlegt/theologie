//
//  DogmatiekStudyView.swift
//  Studie
//

import SwiftUI

/// Bepaalt welke kaarten in een oefenronde zitten.
enum DogmatiekStudyRoute: Hashable {
    case all
    case chapters(Set<String>)
}

private struct DogmatiekRoundAnswerSnapshot: Identifiable {
    let id: UUID
    let card: DogmatiekCard
    /// `true` = er werd een term getoond, antwoord moest de definitie zijn.
    let showedTerm: Bool
    let promptShown: String
    let userAnswer: String
    let expectedAnswer: String
    let wasCorrect: Bool
    /// `true` = meerkeuze; nodig om ‘alleen foute opnieuw’ dezelfde vorm te houden.
    let usedMultipleChoice: Bool
    /// `true` = leeg-vlakmodus (geen getypt antwoord).
    let usedRevealBlank: Bool
    /// Alleen bij meerkeuze: welk antwoordbank-hoofdstuk hoorde bij deze vraag.
    let mcqModeUsed: DogmatiekPracticeInputMode?

    init(
        id: UUID = UUID(),
        card: DogmatiekCard,
        showedTerm: Bool,
        promptShown: String,
        userAnswer: String,
        expectedAnswer: String,
        wasCorrect: Bool,
        usedMultipleChoice: Bool,
        usedRevealBlank: Bool = false,
        mcqModeUsed: DogmatiekPracticeInputMode? = nil
    ) {
        self.id = id
        self.card = card
        self.showedTerm = showedTerm
        self.promptShown = promptShown
        self.userAnswer = userAnswer
        self.expectedAnswer = expectedAnswer
        self.wasCorrect = wasCorrect
        self.usedMultipleChoice = usedMultipleChoice
        self.usedRevealBlank = usedRevealBlank
        self.mcqModeUsed = mcqModeUsed
    }

    func withCorrect(_ newValue: Bool) -> DogmatiekRoundAnswerSnapshot {
        DogmatiekRoundAnswerSnapshot(
            id: id,
            card: card,
            showedTerm: showedTerm,
            promptShown: promptShown,
            userAnswer: userAnswer,
            expectedAnswer: expectedAnswer,
            wasCorrect: newValue,
            usedMultipleChoice: usedMultipleChoice,
            usedRevealBlank: usedRevealBlank,
            mcqModeUsed: mcqModeUsed
        )
    }
}

private enum DogmatiekRoundInputKind: Equatable {
    case typing
    case multipleChoice
    case revealBlank
}

private struct DogmatiekRoundTurn {
    let card: DogmatiekCard
    let inputKind: DogmatiekRoundInputKind
    /// Alleen gezet bij `.multipleChoice` (afgeleid van `card.chapter`).
    let mcqMode: DogmatiekPracticeInputMode?
    /// `true` = term wordt getoond (definitie intypen of uit meerkeuze kiezen). `false` = definitie eerst (term intypen of kiezen).
    let showsTermAsPrompt: Bool

    var useMultipleChoice: Bool { inputKind == .multipleChoice }
    var useRevealBlank: Bool { inputKind == .revealBlank }
}

struct DogmatiekStudyView: View {
    @Environment(DogmatiekStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let route: DogmatiekStudyRoute
    let configuration: DogmatiekStudyConfiguration

    @State private var roundTurns: [DogmatiekRoundTurn] = []
    @State private var showTermPrompt: [Bool] = []
    @State private var currentIndex = 0
    @State private var roundAnswers: [DogmatiekRoundAnswerSnapshot] = []
    @State private var answerText = ""
    /// Geschudde meerkeuze-opties voor de huidige vraag.
    @State private var shuffledMCQOptions: [String] = []
    /// Gekozen optie vóór bevestiging (tap op optie zet dit; daarna bevestigen).
    @State private var mcqPendingSelection: String?
    @State private var revealAnswerVisible = false
    @State private var phase: Phase = .active
    /// Na de ronde: elke fout moet beoordeeld worden (goedkeuren of als fout laten) voordat het overzicht komt.
    @State private var mistakeReviewRequiresAllJudged = false
    /// Fouten die nog een expliciete keuze nodig hebben tijdens verplichte nabespreking.
    @State private var mistakeReviewPendingIds: Set<UUID> = []
    /// Fouten die je bij nabespreking als ‘telt als fout’ hebt bevestigd — verdwijnen uit de lijst (blijven wel fout voor de score).
    @State private var mistakeReviewDismissedIds: Set<UUID> = []
    @State private var exitConfirmationPresented = false
    @FocusState private var answerFocused: Bool

    /// Na een ronde met typ-antwoorden: één voor één nakijken.
    @State private var typingSelfReviewIndex = 0
    /// Typ-antwoorden die je zelf als fout hebt gemarkeerd (meerkeuze-fouten komen automatisch in de foute lijst).
    @State private var typingMarkedFoutIds: Set<UUID> = []
    /// Alleen-lezen doorloop van `finalWrongItems` (geen Goed/Fout meer).
    @State private var wrongBrowseSnapshots: [DogmatiekRoundAnswerSnapshot] = []
    @State private var wrongBrowseIndex = 0

    private enum Phase {
        case active
        case typingSelfReview
        case roundWrapUp
        case wrongBrowseReadOnly
        case summary
        case mistakeReview
        case perfect
    }

    private var totalInRound: Int { roundTurns.count }
    private var progressLabel: String {
        guard totalInRound > 0 else { return "" }
        return "Vraag \(min(currentIndex + 1, totalInRound)) van \(totalInRound)"
    }

    private var currentUsesMultipleChoice: Bool {
        guard currentIndex < roundTurns.count else { return false }
        return roundTurns[currentIndex].useMultipleChoice
    }

    private var currentUsesRevealBlank: Bool {
        guard currentIndex < roundTurns.count else { return false }
        return roundTurns[currentIndex].useRevealBlank
    }

    private var currentCard: DogmatiekCard? {
        guard currentIndex < roundTurns.count else { return nil }
        return roundTurns[currentIndex].card
    }

    private var currentMcqMode: DogmatiekPracticeInputMode? {
        guard currentIndex < roundTurns.count else { return nil }
        return roundTurns[currentIndex].mcqMode
    }

    /// Meerkeuze: definitie tonen en het juiste begrip kiezen (i.p.v. term → definitie).
    private var mcqPicksTerm: Bool {
        guard currentIndex < roundTurns.count, roundTurns[currentIndex].useMultipleChoice else { return false }
        return !roundTurns[currentIndex].showsTermAsPrompt
    }

    private var mcqSupplementaryLine: String? {
        guard currentUsesMultipleChoice, !mcqPicksTerm, let card = currentCard, let mode = currentMcqMode else { return nil }
        return mode.mcqSupplementaryPrompt(for: card)
    }

    /// Zelfde set voor typen en meerkeuze (route = alles of gekozen hoofdstukken).
    private var studyDeck: [DogmatiekCard] {
        switch route {
        case .all:
            return store.cards
        case .chapters(let titles):
            return store.cards.filter { titles.contains($0.chapter) }
        }
    }

    private var mcqCapableCardsInDeck: [DogmatiekCard] {
        studyDeck.filter { DogmatiekPracticeInputMode.multipleChoiceMode(forChapter: $0.chapter) != nil }
    }

    private var emptyDeckMessage: String {
        if !configuration.canStart {
            return "Kies in Oefenmodus typen, meerkeuze of leeg vlak."
        }
        let deckEmpty = studyDeck.isEmpty
        let noMcqInDeck = mcqCapableCardsInDeck.isEmpty

        if configuration.includeRevealBlank,
           !configuration.includeTyping,
           !configuration.includeMultipleChoice,
           deckEmpty {
            return "Er zijn geen termen in deze selectie. Ga terug en kies andere hoofdstukken."
        }

        if configuration.includeTyping && deckEmpty,
           configuration.includeMultipleChoice && noMcqInDeck {
            return "Er zijn geen termen in deze selectie. Ga terug en kies andere hoofdstukken."
        }
        if configuration.includeTyping && deckEmpty {
            return "Er zijn geen termen in deze selectie om te typen. Ga terug en kies andere hoofdstukken."
        }
        if configuration.includeMultipleChoice && noMcqInDeck {
            return "In je selectie zitten geen termen uit hoofdstukken met meerkeuze (Inleiding en hoofdstuk 1 t/m 7 en 9). Kies die hoofdstukken of oefen alleen met typen."
        }
        return "Er zijn geen termen in deze selectie. Ga terug en kies andere hoofdstukken."
    }

    private var mistakeItems: [DogmatiekRoundAnswerSnapshot] {
        roundAnswers.filter { !$0.wasCorrect }
    }

    private var hasTypingAnswersInRound: Bool {
        roundAnswers.contains { !$0.usedMultipleChoice && !$0.usedRevealBlank }
    }

    /// Volgorde van de ronde: alleen getypte antwoorden (voor stapsgewijs nakijken).
    private var typingAnswersInRound: [DogmatiekRoundAnswerSnapshot] {
        roundAnswers.filter { !$0.usedMultipleChoice && !$0.usedRevealBlank }
    }

    /// Fout voor herhaling / bekijken: meerkeuze objectief fout, leeg vlak naar eigen oordeel fout, of typen door jou als fout gemarkeerd.
    private var finalWrongItems: [DogmatiekRoundAnswerSnapshot] {
        roundAnswers.filter { snap in
            if snap.usedMultipleChoice { return !snap.wasCorrect }
            if snap.usedRevealBlank { return !snap.wasCorrect }
            return typingMarkedFoutIds.contains(snap.id)
        }
    }

    private var effectiveGoodCount: Int { roundAnswers.count - finalWrongItems.count }
    private var effectiveWrongCount: Int { finalWrongItems.count }

    /// Fouten die in de nabespreking nog op het scherm staan (goedgekeurd = uit `mistakeItems`; ‘telt als fout’ = uit deze lijst).
    private var mistakeReviewVisibleItems: [DogmatiekRoundAnswerSnapshot] {
        mistakeItems.filter { !mistakeReviewDismissedIds.contains($0.id) }
    }

    /// Terug naar de vorige vraag: alleen tijdens de ronde, vóór je het huidige item hebt bevestigd.
    private var canGoToPreviousQuestion: Bool {
        phase == .active
            && totalInRound > 0
            && currentIndex > 0
            && roundAnswers.count == currentIndex
    }

    private var wrongTurns: [DogmatiekRoundTurn] {
        turns(from: finalWrongItems)
    }

    private func turns(from snapshots: [DogmatiekRoundAnswerSnapshot]) -> [DogmatiekRoundTurn] {
        snapshots.map {
            let kind: DogmatiekRoundInputKind
            if $0.usedMultipleChoice {
                kind = .multipleChoice
            } else if $0.usedRevealBlank {
                kind = .revealBlank
            } else {
                kind = .typing
            }
            return DogmatiekRoundTurn(
                card: $0.card,
                inputKind: kind,
                mcqMode: $0.mcqModeUsed,
                showsTermAsPrompt: $0.showedTerm
            )
        }
    }

    private var correctCount: Int { roundAnswers.filter(\.wasCorrect).count }
    private var wrongCount: Int { roundAnswers.count - correctCount }

    private var navigationTitleText: String {
        switch phase {
        case .mistakeReview:
            return "Fouten"
        case .typingSelfReview:
            return "Nakijken"
        case .roundWrapUp:
            return "Ronde afgerond"
        case .wrongBrowseReadOnly:
            return "Foute antwoorden"
        case .active, .summary, .perfect:
            break
        }
        let typingOn = configuration.includeTyping
        let mcqOn = configuration.includeMultipleChoice
        let revealOn = configuration.includeRevealBlank
        if revealOn && !typingOn && !mcqOn {
            return "Oefenen · leeg vlak"
        }
        if typingOn && mcqOn {
            return "Oefenen · gemengd"
        }
        if mcqOn && !typingOn {
            return "Oefenen · meerkeuze"
        }
        switch route {
        case .all:
            return "Alle termen"
        case .chapters(let titles):
            if titles.count == 1, let only = titles.first {
                return only
            }
            if titles.isEmpty {
                return "Oefenen"
            }
            return "\(titles.count) hoofdstukken"
        }
    }

    init(route: DogmatiekStudyRoute = .all, configuration: DogmatiekStudyConfiguration = .default) {
        self.route = route
        self.configuration = configuration
    }

    var body: some View {
        Group {
            switch phase {
            case .active:
                activeSessionView
            case .typingSelfReview:
                typingSelfReviewView
            case .roundWrapUp:
                roundWrapUpView
            case .wrongBrowseReadOnly:
                wrongBrowseReadOnlyView
            case .summary:
                summaryView
            case .mistakeReview:
                mistakeReviewView
            case .perfect:
                perfectView
            }
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    exitConfirmationPresented = true
                } label: {
                    Label("Terug", systemImage: "chevron.backward")
                }
                .accessibilityHint("Vraagt om bevestiging. De oefening wordt anders afgesloten.")
            }
        }
        .alert("Oefening afsluiten?", isPresented: $exitConfirmationPresented) {
            Button("Annuleren", role: .cancel) {}
            Button("Afsluiten", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Weet je het zeker? Als je nu teruggaat, wordt deze oefening afgesloten en gaat je voortgang in deze ronde verloren.")
        }
        .onAppear {
            if roundTurns.isEmpty {
                startFreshRoundIfPossible()
            }
        }
    }

    private var activeSessionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if totalInRound == 0 {
                ContentUnavailableView(
                    "Geen kaarten",
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text(
                        emptyDeckMessage
                    )
                )
            } else if currentIndex >= totalInRound {
                EmptyView()
            } else {
                Text(progressLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let card = currentCard, let note = card.contextNote, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ter info (geen aparte vraag)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.quaternary.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    if !promptKindLabel.isEmpty {
                        Text(promptKindLabel)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    studyPromptTitleBlock(promptText, card: currentCard)

                    if let extra = mcqSupplementaryLine {
                        Text(extra)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.quaternary.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                if currentUsesMultipleChoice {
                    mcqOptionsView
                } else if currentUsesRevealBlank {
                    revealBlankInputView
                } else {
                    TextField(
                        showTermPrompt[currentIndex] ? "Typ de definitie…" : "Typ de term…",
                        text: $answerText,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .font(.body)
                    .focused($answerFocused)
                    .submitLabel(.done)
                    .onSubmit { submitTextAnswer() }

                    Spacer(minLength: 24)

                    HStack(spacing: 12) {
                        Button {
                            goToPreviousQuestion()
                        } label: {
                            Text("Vorige")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!canGoToPreviousQuestion)
                        .accessibilityLabel("Vorige vraag")
                        .accessibilityHint("Ga één vraag terug om je antwoord aan te passen.")

                        Button(action: submitTextAnswer) {
                            Text(currentIndex + 1 >= totalInRound ? "Laatste antwoord" : "Volgende")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            answerFocused = !currentUsesMultipleChoice && !currentUsesRevealBlank
        }
        .onChange(of: currentIndex) { oldIndex, newIndex in
            if newIndex != oldIndex {
                revealAnswerVisible = false
            }
            if newIndex > oldIndex {
                mcqPendingSelection = nil
            }
            if currentUsesMultipleChoice || currentUsesRevealBlank {
                answerFocused = false
            } else {
                answerFocused = true
            }
            reshuffleMCQOptionsIfNeeded()
        }
    }

    private var promptKindLabel: String {
        guard currentIndex < showTermPrompt.count else { return "" }
        if currentUsesRevealBlank {
            return ""
        }
        if currentUsesMultipleChoice {
            return mcqPicksTerm ? "Kies de juiste term" : "Kies de juiste definitie"
        }
        return showTermPrompt[currentIndex] ? "Wat is de definitie?" : "Welke term hoort hierbij?"
    }

    private var revealExpectedAnswerText: String {
        guard let card = currentCard, currentIndex < showTermPrompt.count else { return "" }
        return showTermPrompt[currentIndex] ? card.definition : card.term
    }

    @ViewBuilder
    private var revealBlankInputView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if revealAnswerVisible {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(revealExpectedAnswerText)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.quaternary.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Wist je dit (al) zelf?")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Button {
                            submitRevealAnswer(wasCorrect: false)
                        } label: {
                            Label("Fout", systemImage: "xmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)

                        Button {
                            submitRevealAnswer(wasCorrect: true)
                        } label: {
                            Label("Goed", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .foregroundStyle(.secondary.opacity(0.45))
                    .frame(minHeight: 120)
                    .accessibilityLabel("Ruimte om zelf aan het antwoord te denken")
            }

            Spacer(minLength: 24)

            if revealAnswerVisible {
                Button {
                    goToPreviousQuestion()
                } label: {
                    Text("Vorige")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .disabled(!canGoToPreviousQuestion)
                .accessibilityLabel("Vorige vraag")
            } else {
                HStack(spacing: 12) {
                    Button {
                        goToPreviousQuestion()
                    } label: {
                        Text("Vorige")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canGoToPreviousQuestion)
                    .accessibilityLabel("Vorige vraag")

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            revealAnswerVisible = true
                        }
                    } label: {
                        Text("Laat antwoord zien")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private var mcqOptionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(shuffledMCQOptions.enumerated()), id: \.offset) { _, option in
                let isPicked = mcqPendingSelection == option
                Button {
                    mcqPendingSelection = option
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: isPicked ? "checkmark.circle.fill" : "circle")
                            .font(.body.weight(.medium))
                            .foregroundStyle(isPicked ? Color.accentColor : .secondary)
                        Text(option)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isPicked ? Color.accentColor.opacity(0.14) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(isPicked ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: isPicked ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityAddTraits(isPicked ? .isSelected : [])
            }

            Text("Kies een optie en tik op Bevestigen om door te gaan.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 24)

            HStack(spacing: 12) {
                Button {
                    goToPreviousQuestion()
                } label: {
                    Text("Vorige")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .disabled(!canGoToPreviousQuestion)
                .accessibilityLabel("Vorige vraag")
                .accessibilityHint("Ga één vraag terug om je antwoord aan te passen.")

                Button {
                    guard let picked = mcqPendingSelection else { return }
                    submitMCQAnswer(picked)
                } label: {
                    Text("Bevestigen")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(mcqPendingSelection == nil)
            }
        }
    }

    private var promptText: String {
        guard let card = currentCard, currentIndex < showTermPrompt.count else { return "" }
        if currentUsesMultipleChoice, let mode = currentMcqMode {
            if mcqPicksTerm {
                return mcqDefinitionFirstStem(for: card, mode: mode)
            }
            return mcqTermFirstPromptShown(for: card, mode: mode)
        }
        return showTermPrompt[currentIndex] ? card.term : card.definition
    }

    /// Grote prompt (oefenscherm) met optioneel „blz” rechtsonder, 20 pt van de rechterrand van het omringende vlak (bij 20 pt content-padding).
    @ViewBuilder
    private func studyPromptTitleBlock(_ text: String, card: DogmatiekCard?) -> some View {
        studyPromptWithPageLabel(
            text,
            card: card,
            textFont: .title3.weight(.semibold),
            pageFont: .caption.weight(.medium),
            pageLabelExtraTrailing: 0
        )
    }

    /// Zelfde layout; bij 16 pt kaartpadding: +4 pt trailing op het label → 20 pt tot buitenrand.
    @ViewBuilder
    private func studyPromptBodyLine(_ text: String, card: DogmatiekCard?) -> some View {
        studyPromptWithPageLabel(
            text,
            card: card,
            textFont: .body,
            pageFont: .caption2.weight(.medium),
            pageLabelExtraTrailing: 4
        )
    }

    @ViewBuilder
    private func studyPromptWithPageLabel(
        _ text: String,
        card: DogmatiekCard?,
        textFont: Font,
        pageFont: Font,
        pageLabelExtraTrailing: CGFloat
    ) -> some View {
        if let p = card?.sourcePage {
            HStack(alignment: .bottom, spacing: 12) {
                Text(text)
                    .font(textFont)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text("blz \(p)")
                    .font(pageFont)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, pageLabelExtraTrailing)
            }
        } else {
            Text(text)
                .font(textFont)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Stelling bovenaan bij meerkeuze ‘definitie → term’ (H4: voorzienigheid; H9: vier kenmerken).
    private func mcqDefinitionFirstStem(for card: DogmatiekCard, mode: DogmatiekPracticeInputMode) -> String {
        if mode == .multipleChoiceHoofdstuk2,
           let stem = DogmatiekHoofdstuk2MultipleChoice.definitionFirstStemIfNeeded(for: card) {
            return stem
        }
        if mode == .multipleChoiceHoofdstuk4,
           let stem = DogmatiekHoofdstuk4MultipleChoice.definitionFirstStemIfNeeded(for: card) {
            return stem
        }
        if mode == .multipleChoiceHoofdstuk9,
           let stem = DogmatiekHoofdstuk9MultipleChoice.definitionFirstStemIfNeeded(for: card) {
            return stem
        }
        if mode == .multipleChoiceHoofdstuk6,
           let stem = DogmatiekHoofdstuk6MultipleChoice.definitionFirstStemIfNeeded(for: card) {
            return stem
        }
        if mode == .multipleChoiceHoofdstuk7,
           let stem = DogmatiekHoofdstuk7MultipleChoice.definitionFirstStemIfNeeded(for: card) {
            return stem
        }
        return mode.mcqCorrectAnswerLine(for: card)
    }

    private func mcqTermFirstPromptShown(for card: DogmatiekCard, mode: DogmatiekPracticeInputMode) -> String {
        if mode == .multipleChoiceHoofdstuk6,
           let line = DogmatiekHoofdstuk6MultipleChoice.termFirstPromptLine(for: card) {
            return line
        }
        if mode == .multipleChoiceHoofdstuk7,
           let line = DogmatiekHoofdstuk7MultipleChoice.termFirstPromptLine(for: card) {
            return line
        }
        return card.term.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var summaryView: some View {
        VStack(spacing: 24) {
            Text("Ronde afgerond")
                .font(.title2.weight(.bold))

            VStack(spacing: 12) {
                HStack {
                    Label("\(correctCount) goed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Spacer()
                }
                .font(.body.weight(.medium))

                HStack {
                    Label("\(wrongCount) fout", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                }
                .font(.body.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.quaternary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if wrongCount > 0 {
                Button {
                    goToMistakeReview(mandatory: false)
                } label: {
                    Label("Fouten bekijken", systemImage: "eye.fill")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button {
                    startRound(withWrongTurns: wrongTurns)
                } label: {
                    Text("Alleen foute opnieuw")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
            }

            if wrongCount > 0 {
                Button {
                    exitConfirmationPresented = true
                } label: {
                    Text("Terug naar Dogmatiek")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    exitConfirmationPresented = true
                } label: {
                    Text("Klaar")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private var typingSelfReviewView: some View {
        let items = typingAnswersInRound
        if items.isEmpty || typingSelfReviewIndex >= items.count {
            Color.clear
                .task {
                    if phase == .typingSelfReview { phase = .roundWrapUp }
                }
        } else {
            typingSelfReviewCard(
                item: items[typingSelfReviewIndex],
                step: typingSelfReviewIndex + 1,
                totalSteps: items.count
            )
        }
    }

    private func typingSelfReviewCard(item: DogmatiekRoundAnswerSnapshot, step: Int, totalSteps: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nakijken \(step) van \(totalSteps)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Text(mistakeReviewPromptKind(for: item))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                studyPromptTitleBlock(item.promptShown, card: item.card)

                Divider()

                Text("Jouw antwoord")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(item.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "—" : item.userAnswer)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Juiste antwoord")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(item.expectedAnswer)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.quaternary.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("Was jouw antwoord goed genoeg?")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    completeTypingSelfReviewStep(markFout: true)
                } label: {
                    Label("Fout", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button {
                    completeTypingSelfReviewStep(markFout: false)
                } label: {
                    Label("Goed", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
    }

    private var roundWrapUpView: some View {
        VStack(spacing: 24) {
            Text("Ronde afgerond")
                .font(.title2.weight(.bold))

            VStack(spacing: 12) {
                HStack {
                    Label("\(effectiveGoodCount) goed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Spacer()
                }
                .font(.body.weight(.medium))

                HStack {
                    Label("\(effectiveWrongCount) fout", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                }
                .font(.body.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.quaternary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if effectiveWrongCount == 0 {
                Text("Geen antwoorden om opnieuw te oefenen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Meerkeuze dat fout was, telt automatisch als fout. Typen en leeg vlak alleen als je zelf Fout koos.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    wrongBrowseSnapshots = finalWrongItems
                    wrongBrowseIndex = 0
                    phase = .wrongBrowseReadOnly
                } label: {
                    Label("Foute antwoorden bekijken", systemImage: "eye.fill")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                Button {
                    startRound(withWrongTurns: turns(from: finalWrongItems))
                } label: {
                    Text("Foute opnieuw")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
            }

            Group {
                if effectiveWrongCount == 0 {
                    Button {
                        exitConfirmationPresented = true
                    } label: {
                        Text("Klaar")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        exitConfirmationPresented = true
                    } label: {
                        Text("Terug naar Dogmatiek")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding()
    }

    private var wrongBrowseReadOnlyView: some View {
        Group {
            if wrongBrowseSnapshots.isEmpty {
                ContentUnavailableView(
                    "Geen foute antwoorden",
                    systemImage: "checkmark.circle",
                    description: Text("Er valt niets te tonen.")
                )
                .onAppear { phase = .roundWrapUp }
            } else if wrongBrowseIndex < wrongBrowseSnapshots.count {
                let item = wrongBrowseSnapshots[wrongBrowseIndex]
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Antwoord \(wrongBrowseIndex + 1) van \(wrongBrowseSnapshots.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Dit zijn antwoorden die als fout tellen — je hoeft hier niets meer aan te geven.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(mistakeReviewPromptKind(for: item))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            studyPromptBodyLine(item.promptShown, card: item.card)

                            Divider()

                            Text("Jouw antwoord")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(displayUserAnswerLine(for: item))
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Text("Antwoord in de app")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            Text(item.expectedAnswer)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(.quaternary.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        if wrongBrowseIndex + 1 >= wrongBrowseSnapshots.count {
                            phase = .roundWrapUp
                        } else {
                            wrongBrowseIndex += 1
                        }
                    } label: {
                        Text(wrongBrowseIndex + 1 >= wrongBrowseSnapshots.count ? "Terug naar overzicht" : "Volgende")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .background(.bar)
                }
            } else {
                Color.clear.onAppear { phase = .roundWrapUp }
            }
        }
    }

    private var mistakeReviewView: some View {
        let mustJudgeAll = mistakeReviewRequiresAllJudged && !mistakeReviewPendingIds.isEmpty

        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if mistakeReviewRequiresAllJudged {
                    Text("Je ronde is klaar. Bekijk elke fout en tik op Bekeken om door te gaan. Daarna zie je het overzicht.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)
                } else {
                    Text("Hier zie je wat je invulde en wat het antwoord in de app was — dat laatste staat vet gedrukt.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)
                }

                ForEach(mistakeReviewVisibleItems) { item in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mistakeReviewPromptKind(for: item))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        studyPromptBodyLine(item.promptShown, card: item.card)

                        Divider()

                        Text("Jouw antwoord")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(displayUserAnswerLine(for: item))
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("Antwoord in de app")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(item.expectedAnswer)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        if mistakeReviewRequiresAllJudged {
                            Button {
                                confirmMistakeAsWrong(id: item.id)
                            } label: {
                                Text("Bekeken")
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.quaternary.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if mustJudgeAll {
                    Text("Tik bij elke fout op Bekeken om verder te gaan.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Button {
                    mistakeReviewRequiresAllJudged = false
                    mistakeReviewPendingIds = []
                    phase = .summary
                } label: {
                    Text("Naar overzicht")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(mustJudgeAll)
            }
            .padding()
            .background(.bar)
        }
    }

    private var perfectView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .symbolRenderingMode(.hierarchical)

            Text("Alles goed!")
                .font(.title2.weight(.bold))

            Text("Je hebt alle termen in deze reeks correct.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                exitConfirmationPresented = true
            } label: {
                Text("Terug")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }

    private func mistakeReviewPromptKind(for item: DogmatiekRoundAnswerSnapshot) -> String {
        if item.usedRevealBlank {
            return item.showedTerm ? "Leeg vlak — je zag de term" : "Leeg vlak — je zag de definitie"
        }
        if item.usedMultipleChoice {
            return item.showedTerm ? "Meerkeuze — je zag de term" : "Meerkeuze — je zag de definitie"
        }
        return item.showedTerm ? "Je zag de term" : "Je zag de definitie"
    }

    private func displayUserAnswerLine(for item: DogmatiekRoundAnswerSnapshot) -> String {
        let t = item.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "—" }
        return t
    }

    private func goToMistakeReview(mandatory: Bool) {
        mistakeReviewDismissedIds = []
        mistakeReviewRequiresAllJudged = mandatory
        mistakeReviewPendingIds = mandatory ? Set(mistakeItems.map(\.id)) : []
        phase = .mistakeReview
    }

    private func confirmMistakeAsWrong(id: UUID) {
        mistakeReviewPendingIds.remove(id)
        mistakeReviewDismissedIds.insert(id)
        finalizeMistakeReviewIfListFullyHandled()
    }

    private func finalizeMistakeReviewIfListFullyHandled() {
        guard phase == .mistakeReview, mistakeReviewVisibleItems.isEmpty else { return }
        mistakeReviewRequiresAllJudged = false
        mistakeReviewPendingIds = []
        phase = .summary
    }

    private func uniqueCards(_ cards: [DogmatiekCard]) -> [DogmatiekCard] {
        Array(Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) }).values)
    }

    private func startFreshRoundIfPossible() {
        guard configuration.canStart else { return }
        var turns = buildTurnsForFreshRound()
        turns.shuffle()
        applyTurns(turns)
    }

    /// Meerkeuze: `true` = definitie eerst, juiste term kiezen.
    private func resolveMcqPicksTermForTurn() -> Bool {
        switch configuration.practicePromptStyle {
        case .termThenPickDefinition: false
        case .definitionThenPickTerm: true
        case .mixed: Bool.random()
        }
    }

    /// Typen: `true` = term getoond, definitie intypen.
    private func resolveTypingShowsTermAsPromptForTurn() -> Bool {
        switch configuration.practicePromptStyle {
        case .termThenPickDefinition: true
        case .definitionThenPickTerm: false
        case .mixed: Bool.random()
        }
    }

    /// Per unieke kaart hoogstens één vraag per ronde. Bij typen én meerkeuze tegelijk: willekeurig één van beide,
    /// zodat dezelfde term niet direct ‘definitie→term’ (meerkeuze) én ‘term↔definitie’ (typen) in dezelfde ronde voorkomt.
    private func buildTurnsForFreshRound() -> [DogmatiekRoundTurn] {
        var turns: [DogmatiekRoundTurn] = []
        let cards = uniqueCards(studyDeck)
        let typingOn = configuration.includeTyping
        let mcqOn = configuration.includeMultipleChoice
        let revealOn = configuration.includeRevealBlank

        if revealOn, !typingOn, !mcqOn {
            for card in cards {
                turns.append(
                    DogmatiekRoundTurn(
                        card: card,
                        inputKind: .revealBlank,
                        mcqMode: nil,
                        showsTermAsPrompt: resolveTypingShowsTermAsPromptForTurn()
                    )
                )
            }
            return turns
        }

        for card in cards {
            let mcqMode = DogmatiekPracticeInputMode.multipleChoiceMode(forChapter: card.chapter)
            let cardHasMcq = mcqMode != nil

            if typingOn, mcqOn, cardHasMcq, let mode = mcqMode {
                if Bool.random() {
                    let picksTerm = resolveMcqPicksTermForTurn()
                    turns.append(
                        DogmatiekRoundTurn(
                            card: card,
                            inputKind: .multipleChoice,
                            mcqMode: mode,
                            showsTermAsPrompt: !picksTerm
                        )
                    )
                } else {
                    turns.append(
                        DogmatiekRoundTurn(
                            card: card,
                            inputKind: .typing,
                            mcqMode: nil,
                            showsTermAsPrompt: resolveTypingShowsTermAsPromptForTurn()
                        )
                    )
                }
            } else if mcqOn, cardHasMcq, let mode = mcqMode {
                let picksTerm = resolveMcqPicksTermForTurn()
                turns.append(
                    DogmatiekRoundTurn(
                        card: card,
                        inputKind: .multipleChoice,
                        mcqMode: mode,
                        showsTermAsPrompt: !picksTerm
                    )
                )
            } else if typingOn {
                turns.append(
                    DogmatiekRoundTurn(
                        card: card,
                        inputKind: .typing,
                        mcqMode: nil,
                        showsTermAsPrompt: resolveTypingShowsTermAsPromptForTurn()
                    )
                )
            }
        }
        return turns
    }

    private func startRound(withWrongTurns turns: [DogmatiekRoundTurn]) {
        applyTurns(turns.shuffled())
    }

    private func applyTurns(_ turns: [DogmatiekRoundTurn]) {
        roundTurns = turns
        showTermPrompt = turns.map(\.showsTermAsPrompt)
        currentIndex = 0
        roundAnswers = []
        answerText = ""
        mistakeReviewRequiresAllJudged = false
        mistakeReviewPendingIds = []
        mistakeReviewDismissedIds = []
        mcqPendingSelection = nil
        revealAnswerVisible = false
        typingSelfReviewIndex = 0
        typingMarkedFoutIds = []
        wrongBrowseSnapshots = []
        wrongBrowseIndex = 0
        phase = .active
        reshuffleMCQOptionsIfNeeded()
    }

    private func reshuffleMCQOptionsIfNeeded() {
        guard currentUsesMultipleChoice, let card = currentCard, let mode = currentMcqMode else {
            shuffledMCQOptions = []
            return
        }
        if mcqPicksTerm {
            shuffledMCQOptions = mcqTermOptionPool(for: card).shuffled()
        } else {
            shuffledMCQOptions = mode.mcqOptionPool(for: card).shuffled()
        }
    }

    /// Vier (of minder) unieke termen: het goede begrip plus afleiders uit hetzelfde hoofdstuk, daarna de rest van je selectie.
    private func mcqTermOptionPool(for card: DogmatiekCard) -> [String] {
        if let fixed = DogmatiekHoofdstuk2MultipleChoice.fixedCouncilTermOptionPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk2MultipleChoice.fixedBijbelGezagTermOptionPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk2MultipleChoice.fixedMarcionSchismaTermOptionPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk3MultipleChoice.fixedCouncilTermOptionPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk9MultipleChoice.fixedFourMarksTermPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk6MultipleChoice.fixedTermOptionPool(for: card) {
            return fixed
        }
        if let fixed = DogmatiekHoofdstuk7MultipleChoice.fixedTermOptionPool(for: card) {
            return fixed
        }

        let correct = card.term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !correct.isEmpty else { return [correct] }

        var usedKeys: Set<String> = [DogmatiekAnswerCheck.normalizedKey(correct)]
        var pool: [String] = [correct]

        let sameChapter = uniqueCards(studyDeck).filter { $0.chapter == card.chapter }.shuffled()
        for peer in sameChapter where pool.count < 4 {
            let t = peer.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = DogmatiekAnswerCheck.normalizedKey(t)
            if !t.isEmpty, !usedKeys.contains(key) {
                usedKeys.insert(key)
                pool.append(t)
            }
        }

        if pool.count < 4 {
            for peer in uniqueCards(studyDeck).shuffled() where pool.count < 4 {
                let t = peer.term.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = DogmatiekAnswerCheck.normalizedKey(t)
                if !t.isEmpty, !usedKeys.contains(key) {
                    usedKeys.insert(key)
                    pool.append(t)
                }
            }
        }

        return pool
    }

    private func submitTextAnswer() {
        guard let card = currentCard, currentIndex < showTermPrompt.count else { return }
        let showTerm = showTermPrompt[currentIndex]
        let promptShown = showTerm ? card.term : card.definition
        let expected = showTerm ? card.definition : card.term
        let typed = answerText
        let ok = DogmatiekAnswerCheck.matches(typed, expected: expected)

        roundAnswers.append(
            DogmatiekRoundAnswerSnapshot(
                card: card,
                showedTerm: showTerm,
                promptShown: promptShown,
                userAnswer: typed,
                expectedAnswer: expected,
                wasCorrect: ok,
                usedMultipleChoice: false,
                usedRevealBlank: false,
                mcqModeUsed: nil
            )
        )
        answerText = ""
        if !ok {
            answerFocused = false
        }
        advanceAfterAnswer()
    }

    private func submitMCQAnswer(_ selected: String) {
        guard let card = currentCard, let mode = currentMcqMode else { return }
        mcqPendingSelection = nil
        let definitionLine = mode.mcqCorrectAnswerLine(for: card)
        let expected: String
        let promptShown: String
        let showedTerm: Bool
        if mcqPicksTerm {
            let termPick = DogmatiekHoofdstuk9MultipleChoice.expectedAnswerWhenPickingTermIfNeeded(for: card)
                ?? DogmatiekHoofdstuk2MultipleChoice.expectedAnswerWhenPickingTermIfNeeded(for: card)
                ?? card.term.trimmingCharacters(in: .whitespacesAndNewlines)
            expected = termPick
            promptShown = mcqDefinitionFirstStem(for: card, mode: mode)
            showedTerm = false
        } else {
            expected = definitionLine
            promptShown = mcqTermFirstPromptShown(for: card, mode: mode)
            showedTerm = true
        }
        let ok = DogmatiekAnswerCheck.matches(selected, expected: expected)

        roundAnswers.append(
            DogmatiekRoundAnswerSnapshot(
                card: card,
                showedTerm: showedTerm,
                promptShown: promptShown,
                userAnswer: selected,
                expectedAnswer: expected,
                wasCorrect: ok,
                usedMultipleChoice: true,
                usedRevealBlank: false,
                mcqModeUsed: mode
            )
        )
        if !ok {
            answerFocused = false
        }
        advanceAfterAnswer()
    }

    private func submitRevealAnswer(wasCorrect: Bool) {
        guard let card = currentCard, currentIndex < showTermPrompt.count else { return }
        let showTerm = showTermPrompt[currentIndex]
        let promptShown = showTerm ? card.term : card.definition
        let expected = showTerm ? card.definition : card.term
        let selfLabel = wasCorrect ? "Eigen oordeel: goed" : "Eigen oordeel: fout"
        roundAnswers.append(
            DogmatiekRoundAnswerSnapshot(
                card: card,
                showedTerm: showTerm,
                promptShown: promptShown,
                userAnswer: selfLabel,
                expectedAnswer: expected,
                wasCorrect: wasCorrect,
                usedMultipleChoice: false,
                usedRevealBlank: true,
                mcqModeUsed: nil
            )
        )
        revealAnswerVisible = false
        advanceAfterAnswer()
    }

    private func advanceAfterAnswer() {
        if currentIndex + 1 >= totalInRound {
            if hasTypingAnswersInRound {
                typingSelfReviewIndex = 0
                typingMarkedFoutIds = []
                phase = .typingSelfReview
            } else if mistakeItems.isEmpty {
                phase = .perfect
            } else {
                phase = .summary
            }
        } else {
            currentIndex += 1
            reshuffleMCQOptionsIfNeeded()
        }
    }

    private func completeTypingSelfReviewStep(markFout: Bool) {
        let items = typingAnswersInRound
        guard typingSelfReviewIndex < items.count else { return }
        let id = items[typingSelfReviewIndex].id
        if markFout {
            typingMarkedFoutIds.insert(id)
        } else {
            typingMarkedFoutIds.remove(id)
        }
        typingSelfReviewIndex += 1
        if typingSelfReviewIndex >= items.count {
            phase = .roundWrapUp
        }
    }

    private func goToPreviousQuestion() {
        guard canGoToPreviousQuestion else { return }
        let undone = roundAnswers.removeLast()
        currentIndex -= 1

        if undone.usedMultipleChoice {
            answerText = ""
            let trimmed = undone.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            mcqPendingSelection = nil
            reshuffleMCQOptionsIfNeeded()
            mcqPendingSelection = trimmed.isEmpty ? nil : trimmed
            revealAnswerVisible = false
        } else if undone.usedRevealBlank {
            answerText = ""
            mcqPendingSelection = nil
            reshuffleMCQOptionsIfNeeded()
            revealAnswerVisible = false
        } else {
            answerText = undone.userAnswer
            mcqPendingSelection = nil
            reshuffleMCQOptionsIfNeeded()
            revealAnswerVisible = false
        }

        if currentUsesMultipleChoice || currentUsesRevealBlank {
            answerFocused = false
        } else {
            answerFocused = true
        }
    }
}

#Preview("Alleen typen") {
    NavigationStack {
        DogmatiekStudyView(route: .all, configuration: .default)
    }
    .environment(DogmatiekStore())
}

#Preview("Alleen meerkeuze") {
    NavigationStack {
        DogmatiekStudyView(
            route: .all,
            configuration: DogmatiekStudyConfiguration(
                includeTyping: false,
                includeMultipleChoice: true,
                includeRevealBlank: false,
                practicePromptStyle: .termThenPickDefinition
            )
        )
    }
    .environment(DogmatiekStore())
}

#Preview("Gemengd") {
    NavigationStack {
        DogmatiekStudyView(
            route: .all,
            configuration: DogmatiekStudyConfiguration(
                includeTyping: true,
                includeMultipleChoice: true,
                includeRevealBlank: false,
                practicePromptStyle: .termThenPickDefinition
            )
        )
    }
    .environment(DogmatiekStore())
}
