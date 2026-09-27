import Testing
@testable import BookShelf
internal import Foundation
import SwiftData



    @Suite struct Validation {
        @Test func isBookValid_emptyAuthor() async throws {
            let book = Book(title: "TestTitle", author: "", genre: .fantasy, review: "", rating: 3, date: .now)
            #expect(book.isBookValid == false)
        }
        @Test func isBookValid_emptyTitle() async throws {
            let book = Book(title: "", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            #expect(book.isBookValid == false)
        }
        @Test func isBookValid_validTitleAndAuthor() async throws {
            let book = Book(title: "TestTitle", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            #expect(book.isBookValid == true)
        }
        @Test func isBookValid_onlyWhitespaces() async throws {
            let book = Book(title: "      ", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            #expect(book.isBookValid == false)
        }
    }
    @MainActor
    @Suite struct Persistance  {
        let container: ModelContainer
        let context: ModelContext

        init() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(for: Book.self, configurations: config)
            context = container.mainContext
        }

        @Test func insert_fetchReturnsBookWithCorrectFields() async throws {
            let book = Book(title: "TestTitle", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            context.insert(book)

            let fetched = try context.fetch(FetchDescriptor<Book>())

            #expect(fetched.count == 1)
            #expect(fetched.first?.title == "TestTitle")
            #expect(fetched.first?.author == "TestAuthor")
            #expect(fetched.first?.rating == 3)
        }

        @Test func delete_fetchReturnsEmpty() async throws {
            let book = Book(title: "TestTitle", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            context.insert(book)

            let beforeDelete = try context.fetch(FetchDescriptor<Book>())
            #expect(beforeDelete.count == 1)

            context.delete(book)

            let afterDelete = try context.fetch(FetchDescriptor<Book>())
            #expect(afterDelete.isEmpty)
        }

        @Test func fetchDescriptor_sortDescriptor_returnSortedAlphabetically() async throws {
            let book0 = Book(title: "Zebra", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            let book1 = Book(title: "Xylophone", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            let book2 = Book(title: "Mango", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            let book3 = Book(title: "Horse", author: "TestAuthor", genre: .fantasy, review: "", rating: 3, date: .now)
            context.insert(book0)
            context.insert(book1)
            context.insert(book2)
            context.insert(book3)

            let fetched = try context.fetch(FetchDescriptor<Book>(sortBy: [
                SortDescriptor(\Book.title)
            ]))
            #expect(fetched.map(\.title) == ["Horse", "Mango", "Xylophone", "Zebra"])
        }
    }

