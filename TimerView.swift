import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Book.createdAt, order: .reverse)
    private var books: [Book]

    @State private var selectedBook: Book?
    @State private var timerState: ReadingTimerState = .waiting

    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?

    @State private var pagesText: String = ""
    @State private var memo: String = ""

    @State private var showingAddBook = false
    @State private var newBookTitle = ""
    @State private var newBookAuthor = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    KuuImageView(state: timerState)

                    bookPickerSection

                    timerSection

                    actionButtons

                    if timerState == .recording {
                        recordSection
                    }
                }
                .padding()
            }
            .navigationTitle("読書タイマー")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if selectedBook == nil {
                    selectedBook = books.first
                }
            }
            .onChange(of: books.count) {
                if selectedBook == nil {
                    selectedBook = books.first
                }
            }
            .sheet(isPresented: $showingAddBook) {
                addBookSheet
            }
        }
    }

    private var bookPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("読む本")
                .font(.headline)

            if books.isEmpty {
                Text("まだ本が登録されていません。")
                    .foregroundStyle(.secondary)
            } else {
                Picker("本を選択", selection: $selectedBook) {
                    ForEach(books) { book in
                        Text(book.title).tag(Optional(book))
                    }
                }
                .pickerStyle(.menu)
                .disabled(timerState == .reading)
            }

            Button {
                showingAddBook = true
            } label: {
                Label("新しい本を追加", systemImage: "plus.circle")
            }
            .disabled(timerState == .reading)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var timerSection: some View {
        VStack(spacing: 8) {
            Text(formattedTime(elapsedSeconds))
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(stateLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            switch timerState {
            case .waiting:
                Button {
                    startReading()
                } label: {
                    Text("読書開始")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedBook == nil)

            case .reading:
                Button {
                    finishReading()
                } label: {
                    Text("終了して記録へ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    resetTimer()
                } label: {
                    Text("中止")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

            case .recording:
                Button {
                    saveNote()
                } label: {
                    Text("感想を保存")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var recordSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("読書記録")
                .font(.headline)

            Text("本：\(selectedBook?.title ?? "未選択")")
                .foregroundStyle(.secondary)

            Text("読書時間：\(readingMinutes)分")
                .foregroundStyle(.secondary)

            TextField("読んだページ数", text: $pagesText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            Text("感想")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $memo)
                .frame(minHeight: 140)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var addBookSheet: some View {
        NavigationStack {
            Form {
                Section("本の情報") {
                    TextField("タイトル", text: $newBookTitle)
                    TextField("著者 任意", text: $newBookAuthor)
                }
            }
            .navigationTitle("本を追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        showingAddBook = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addBook()
                    }
                    .disabled(newBookTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var stateLabel: String {
        switch timerState {
        case .waiting:
            return "待機中"
        case .reading:
            return "読書中"
        case .recording:
            return "記録中"
        }
    }

    private var readingMinutes: Int {
        max(1, elapsedSeconds / 60)
    }

    private func startReading() {
        guard selectedBook != nil else { return }

        timerState = .reading
        elapsedSeconds = 0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func finishReading() {
        timer?.invalidate()
        timer = nil
        timerState = .recording
    }

    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        elapsedSeconds = 0
        pagesText = ""
        memo = ""
        timerState = .waiting
    }

    private func saveNote() {
        guard let selectedBook else { return }

        let pages = Int(pagesText) ?? 0

        let note = ReadingNote(
            book: selectedBook,
            minutes: readingMinutes,
            pages: pages,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(note)

        do {
            try modelContext.save()
        } catch {
            print("読書記録の保存に失敗しました: \(error.localizedDescription)")
        }

        elapsedSeconds = 0
        pagesText = ""
        memo = ""
        timerState = .waiting
    }

    private func addBook() {
        let title = newBookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let author = newBookAuthor.trimmingCharacters(in: .whitespacesAndNewlines)

        let book = Book(title: title, author: author)
        modelContext.insert(book)

        do {
            try modelContext.save()
            selectedBook = book
        } catch {
            print("本の保存に失敗しました: \(error.localizedDescription)")
        }

        newBookTitle = ""
        newBookAuthor = ""
        showingAddBook = false
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
