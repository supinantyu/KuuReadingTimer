import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var createdAt: Date
    var isFinished: Bool

    init(
        title: String,
        author: String = "",
        createdAt: Date = Date(),
        isFinished: Bool = false
    ) {
        self.title = title
        self.author = author
        self.createdAt = createdAt
        self.isFinished = isFinished
    }
}
