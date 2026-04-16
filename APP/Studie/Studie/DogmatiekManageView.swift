//
//  DogmatiekManageView.swift
//  Studie
//

import SwiftUI

struct DogmatiekManageView: View {
    @Environment(DogmatiekStore.self) private var store
    @State private var showAdd = false
    @State private var importAlertTitle = ""
    @State private var importAlertMessage = ""
    @State private var showImportAlert = false

    var body: some View {
        Group {
            if store.cards.isEmpty {
                ContentUnavailableView(
                    "Nog geen termen",
                    systemImage: "text.book.closed",
                    description: Text("Tik op + om zelf termen toe te voegen, of laad de set uit je Practicing Christian Doctrine-document.")
                )
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            presentImportResult(store.importPracticingChristianDoctrineTermsFromBundle())
                        } label: {
                            Label("Documenttermen laden", systemImage: "doc.badge.plus")
                        }
                        .frame(minHeight: 44)
                    }
                }
            } else {
                List {
                    ForEach(store.nestedChapters()) { chapterBlock in
                        Section {
                            ForEach(chapterBlock.subgroups) { sub in
                                if let subTitle = sub.title {
                                    Section {
                                        ForEach(sub.cards) { card in
                                            cardRow(card)
                                        }
                                        .onDelete { offsets in
                                            deleteCards(at: offsets, in: sub.cards)
                                        }
                                    } header: {
                                        Text(subTitle)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                            .textCase(nil)
                                    }
                                } else {
                                    ForEach(sub.cards) { card in
                                        cardRow(card)
                                    }
                                    .onDelete { offsets in
                                        deleteCards(at: offsets, in: sub.cards)
                                    }
                                }
                            }
                        } header: {
                            HStack(alignment: .firstTextBaseline) {
                                Text(chapterBlock.chapter)
                                    .font(.subheadline.weight(.semibold))
                                Spacer(minLength: 8)
                                let count = chapterBlock.subgroups.reduce(0) { $0 + $1.cards.count }
                                Text("\(count) termen")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            .textCase(nil)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Termen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Term toevoegen")
                .frame(minWidth: 44, minHeight: 44)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    presentImportResult(store.importPracticingChristianDoctrineTermsFromBundle())
                } label: {
                    Image(systemName: "doc.badge.plus")
                }
                .accessibilityLabel("Documenttermen toevoegen")
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                DogmatiekCardFormView(mode: .add)
            }
        }
        .alert(importAlertTitle, isPresented: $showImportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importAlertMessage)
        }
    }

    @ViewBuilder
    private func cardRow(_ card: DogmatiekCard) -> some View {
        NavigationLink {
            DogmatiekEditView(card: card)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(card.term)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(card.definition)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .padding(.vertical, 4)
        }
    }

    private func deleteCards(at offsets: IndexSet, in bucket: [DogmatiekCard]) {
        for idx in offsets {
            store.delete(bucket[idx])
        }
    }

    private func presentImportResult(_ result: DogmatiekStore.BundledTermsImportResult) {
        switch result {
        case .added(let n):
            importAlertTitle = "Toegevoegd"
            importAlertMessage = "\(n) termen uit het document zijn toegevoegd."
        case .noneNew:
            importAlertTitle = "Geen wijziging"
            importAlertMessage = "Alle documenttermen staan al in je lijst."
        case .bundleMissing:
            importAlertTitle = "Importeren mislukt"
            importAlertMessage = "Het bestand met documenttermen zit niet in de app-bundel. Controleer of PracticingChristianDoctrineTerms.json bij de target hoort."
        }
        showImportAlert = true
    }
}

#Preview {
    NavigationStack {
        DogmatiekManageView()
    }
    .environment(DogmatiekStore())
}
