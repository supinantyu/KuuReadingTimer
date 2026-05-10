import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let book: Book

    @Query(sort: \ReadingNote.date, order: .reverse)
    private var allNotes: [ReadingNote]

    private var notes: [ReadingNote] {
        allNotes.filter { $0.book === book }
    }

    private var totalMinutes: Int {
        notes.reduce(0) { $0 + $1.minutes }
    }

    private var totalPages: Int {
        notes.reduce(0) { $0 + $1.pages }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.title2)
                        .bold()

                    if !book.author.isEmpty {
                        Text(book.author)
                            .foregroundStyle(.secondary)
                    }

                    Text("合計読書時間：\(totalMinutes)分")
                        .foregroundStyle(.secondary)

                    Text("合計ページ数：\(totalPages)ページ")
                        .foregroundStyle(.secondary)

                    Text("感想：\(notes.count)件")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section("感想ログ") {
                if notes.isEmpty {
                    Text("まだ感想がありません。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("\(note.minutes)分 / \(note.pages)ページ")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(note.memo)
                                .font(.body)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteNotes)
                }
            }
        }
        .navigationTitle("読書記録")
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            modelContext.delete(note)
        }

        do {
            try modelContext.save()
        } catch {
            print("感想ログの削除に失敗しました: \(error.localizedDescription)")
        }
    }
}
