import SwiftUI
import SwiftData

struct BookshelfView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Book.createdAt, order: .reverse)
    private var books: [Book]

    @Query(sort: \ReadingNote.date, order: .reverse)
    private var notes: [ReadingNote]

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        BookDetailView(book: book)
                    } label: {
                        bookRow(book)
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("本棚")
            .overlay {
                if books.isEmpty {
                    ContentUnavailableView(
                        "本がありません",
                        systemImage: "books.vertical",
                        description: Text("タイマー画面から本を追加できます。")
                    )
                }
            }
        }
    }

    private func bookRow(_ book: Book) -> some View {
        let bookNotes = notesForBook(book)
        let totalMinutes = bookNotes.reduce(0) { $0 + $1.minutes }

        return VStack(alignment: .leading, spacing: 6) {
            Text(book.title)
                .font(.headline)

            if !book.author.isEmpty {
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("合計 \(totalMinutes)分 / 感想 \(bookNotes.count)件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func notesForBook(_ book: Book) -> [ReadingNote] {
        notes.filter { $0.book === book }
    }

    private func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            let book = books[index]

            let relatedNotes = notes.filter { $0.book === book }
            for note in relatedNotes {
                modelContext.delete(note)
            }

            modelContext.delete(book)
        }

        do {
            try modelContext.save()
        } catch {
            print("本の削除に失敗しました: \(error.localizedDescription)")
        }
    }
}
