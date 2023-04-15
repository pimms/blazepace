import Foundation

typealias DiagRepository = NoopDiagRepository

class NoopDiagRepository: DiagRepositoryProtocol {
    func references() async -> [DiagReference] { [] }
    func summary(for reference: DiagReference) async throws -> DiagSummary? { nil }
    func addSummary(_ summary: DiagSummary, title: String, description: String) async { }
    func deleteAll() async { }
}

#if DEBUG
class RealDiagRepository: DiagRepositoryProtocol {
    private let log = Log(name: "DiagRepository")
    private let manager = FileManager.default
    private let referenceFilePath: URL

    init() {
        referenceFilePath = manager.temporaryDirectory.appendingPathComponent("refs", conformingTo: .plainText)
    }

    func references() async -> [DiagReference] {
        guard let data = manager.contents(atPath: referenceFilePath.path()) else {
            log.debug("No ref index")
            return []
        }

        do {
            let decoder = JSONDecoder()
            let refs = try decoder.decode([DiagReference].self, from: data)
            return refs
        } catch {
            log.error("failed to load ref index: \(error)")
            return []
        }
    }

    func summary(for reference: DiagReference) async throws -> DiagSummary? {
        guard let data = manager.contents(atPath: reference.filePath.path()) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let summary = try decoder.decode(DiagSummary.self, from: data)
            return summary
        } catch {
            log.error("failed to load diag dummary: \(error)")
            return nil
        }
    }

    func addSummary(_ summary: DiagSummary, title: String, description: String) async {
        do {
            let encoder = JSONEncoder()

            let id = UUID().uuidString
            let summaryPath = manager.temporaryDirectory.appendingPathComponent(id, conformingTo: .plainText)
            let summaryData = try encoder.encode(summary)
            try summaryData.write(to: summaryPath)

            var refs = await references()
            let reference = DiagReference(title: title, description: description, filePath: summaryPath)
            refs.insert(reference, at: 0)

            let refData = try encoder.encode(refs)
            try refData.write(to: referenceFilePath)
        } catch {
            log.error("failed to save summary: \(error)")
        }
    }

    func deleteAll() async {
        let tempDir = manager.temporaryDirectory
        let files: [String]
        do {
            files = try manager.contentsOfDirectory(atPath: tempDir.path())
        } catch {
            log.error("failed to delete all: \(error)")
            return
        }

        for file in files {
            let path = tempDir.appending(path: file)
            do {
                try manager.removeItem(atPath: path.path())
            } catch {
                log.error("failed to delete file '\(file)': \(error)")
            }
        }
    }
}
#endif
