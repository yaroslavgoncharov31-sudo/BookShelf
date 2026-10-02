import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false

    let book: Book

    var body: some View {
        ScrollView {
            VStack {
                Text("By \(book.author)")
                    .padding()
                    .font(.headline)
                Text(book.genre.rawValue)
                    .padding()
                    .font(.subheadline)
                    .bold()
                Text(book.review)
                    .padding()

                Text("Adding date: \(book.date.formatted(date: .abbreviated, time: .shortened))")
                    .padding()
                    .foregroundStyle(.secondary)

                RatingView(rating: .constant(book.rating))
                    .font(.largeTitle)
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .alert("Delete book", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(book)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
        .toolbar {
            Button("Delete this book", systemImage: "trash") {
                showingDeleteAlert = true
            }
        }
    }
}
#Preview {

    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Book.self, configurations: config)
        let example = Book(title: "Test Name", author: "Test Author", genre: .biography, review: "Lorem ipsum", rating: 3, date: .now)
        return DetailView(book: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to load preview: \(error.localizedDescription)")
    }
}
