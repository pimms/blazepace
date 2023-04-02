import Foundation

protocol DiagRepositoryProtocol {
    func references() async -> [DiagReference]
    func summary(for reference: DiagReference) async throws -> DiagSummary?
    func addSummary(_ summary: DiagSummary, reference: DiagReference) async
    func deleteAll() async
}
