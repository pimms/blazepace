import Foundation
import SwiftUI

struct DebugView: View {
    let repository: DiagRepositoryProtocol

    @State private var references: [DiagReference] = []

    var body: some View {
        ScrollView {
            VStack{
                ForEach(references, id: \.self) { ref in
                    DiagSummaryView(reference: ref, repository: repository)
                }
                Button("Delete all", role: .destructive, action: deleteAll)
                    .padding()
            }
        }
        .onAppear {
            Task {
                let refs = await repository.references()
                await MainActor.run {
                    self.references = refs
                }
            }
        }
    }

    private func deleteAll() {
        Task {
            await repository.deleteAll()
            let refs = await repository.references()
            await MainActor.run {
                self.references = refs
            }
        }
    }
}

private struct DiagSummaryView: View {
    let reference: DiagReference
    let repository: DiagRepositoryProtocol

    var body: some View {
        VStack {
            Text(reference.title)
            Text(reference.description)
                .font(.footnote)
            ShareLink(
                item: TransferableDiagnostics(reference: reference, repository: repository),
                preview: SharePreview("Data", image: Image(systemName: "doc.text")))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
        .padding()
    }
}

private struct TransferableDiagnostics: Transferable {
    let reference: DiagReference
    let repository: DiagRepositoryProtocol

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .plainText) { transferable in
            let summary = try await transferable.repository.summary(for: transferable.reference)
            let data = try JSONEncoder().encode(summary)
            return data
        }
    }
}

// MARK: - Preview

struct DebugViewPreview: PreviewProvider {
    private struct MockRepository: DiagRepositoryProtocol {
        func references() async -> [DiagReference] {
            return [
                DiagReference(title: "Run 1", description: "This was a nice one", filePath: URL(string: "https://google.com")!),
                DiagReference(title: "Run 2", description: "This was a nice one", filePath: URL(string: "https://google.com")!),
                DiagReference(title: "Run 3", description: "This was a nice one", filePath: URL(string: "https://google.com")!),
                DiagReference(title: "Run 4", description: "This was a nice one", filePath: URL(string: "https://google.com")!),
            ]
        }
        func summary(for reference: DiagReference) async throws -> DiagSummary? { nil }
        func addSummary(_ summary: DiagSummary, title: String, description: String) async { }
        func deleteAll() async { }
    }

    static var previews: some View {
        DebugView(repository: MockRepository())
    }
}
