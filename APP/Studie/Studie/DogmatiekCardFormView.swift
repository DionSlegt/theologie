//
//  DogmatiekCardFormView.swift
//  Studie
//

import SwiftUI

struct DogmatiekCardFormView: View {
    enum Mode {
        case add
        case edit(DogmatiekCard)
    }

    @Environment(DogmatiekStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var term: String = ""
    @State private var definition: String = ""
    @State private var chapter: String = DogmatiekCard.fallbackChapter
    @State private var subgroup: String = ""
    @State private var contextNote: String = ""

    private var navigationTitle: String {
        switch mode {
        case .add: return "Nieuwe term"
        case .edit: return "Bewerken"
        }
    }

    private var canSave: Bool {
        !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                Picker("Hoofdstuk", selection: $chapter) {
                    ForEach(DogmatiekChapterCatalog.orderedTitles, id: \.self) { title in
                        Text(title).tag(title)
                    }
                }
                .accessibilityHint("Kies bij welk hoofdstuk deze term hoort.")
            } footer: {
                Text("Zelf toegevoegde termen kun je onder Overig laten staan of een hoofdstuk kiezen.")
                    .font(.footnote)
            }

            Section {
                TextField("Subgroep (optioneel)", text: $subgroup)
                    .textInputAutocapitalization(.sentences)
                ForEach(DogmatiekChapterCatalog.subgroupSuggestions, id: \.self) { suggestion in
                    Button {
                        subgroup = suggestion
                    } label: {
                        Label("Gebruik: \(suggestion)", systemImage: "text.badge.plus")
                    }
                }
            } header: {
                Text("Subgroep")
            } footer: {
                Text("Termen met dezelfde subgroep worden in de lijst bij elkaar gezet (bijv. Imago Dei).")
                    .font(.footnote)
            }

            Section {
                TextEditor(text: $contextNote)
                    .frame(minHeight: 80)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            } header: {
                Text("Bijlage / uitleg (optioneel)")
            } footer: {
                Text("Wordt bij het oefenen als extra tekst getoond, niet als aparte vraag.")
                    .font(.footnote)
            }

            Section {
                TextField("Term", text: $term)
                    .textInputAutocapitalization(.sentences)
                    .font(.body)
            } header: {
                Text("Term")
            }

            Section {
                TextEditor(text: $definition)
                    .frame(minHeight: 120)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            } header: {
                Text("Definitie")
            } footer: {
                Text("Kleine verschillen in spelling of formulering tellen mee als goed zolang de strekking overeenkomt met de opgeslagen definitie.")
                    .font(.footnote)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuleer") {
                    dismiss()
                }
                .frame(minHeight: 44)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Bewaar") {
                    save()
                    dismiss()
                }
                .disabled(!canSave)
                .fontWeight(.semibold)
                .frame(minHeight: 44)
            }
        }
        .onAppear {
            switch mode {
            case .add:
                chapter = DogmatiekCard.fallbackChapter
                subgroup = ""
                contextNote = ""
            case .edit(let card):
                term = card.term
                definition = card.definition
                subgroup = card.subgroup ?? ""
                contextNote = card.contextNote ?? ""
                if DogmatiekChapterCatalog.orderedTitles.contains(card.chapter) {
                    chapter = card.chapter
                } else {
                    chapter = DogmatiekCard.fallbackChapter
                }
            }
        }
    }

    private func save() {
        let sg = subgroup.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = contextNote.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .add:
            store.add(
                term: term,
                definition: definition,
                chapter: chapter,
                subgroup: sg.isEmpty ? nil : sg,
                contextNote: note.isEmpty ? nil : note
            )
        case .edit(let card):
            store.update(
                card,
                term: term,
                definition: definition,
                chapter: chapter,
                subgroup: sg.isEmpty ? nil : sg,
                contextNote: note.isEmpty ? nil : note
            )
        }
    }
}

struct DogmatiekEditView: View {
    let card: DogmatiekCard

    var body: some View {
        DogmatiekCardFormView(mode: .edit(card))
    }
}

#Preview {
    NavigationStack {
        DogmatiekCardFormView(mode: .add)
    }
    .environment(DogmatiekStore())
}
