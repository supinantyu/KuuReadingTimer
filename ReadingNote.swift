import Foundation
import SwiftData

@Model
final class ReadingNote {
    var book: Book?
    var minutes: Int
    var pages: Int
    var memo: String
    var date: Date

    init(
        book: Book?,
        minutes: Int,
        pages: Int,
        memo: String,
        date: Date = Date()
    ) {
        self.book = book
        self.minutes = minutes
        self.pages = pages
        self.memo = memo
        self.date = date
    }
}
