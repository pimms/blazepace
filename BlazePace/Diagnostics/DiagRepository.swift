import Foundation

class DiagRepository: DiagRepositoryProtocol {
    private let log = Log(name: "DiagRepository")
    private let manager = FileManager.default
    private let referenceFilePath: URL

    init() {
        referenceFilePath = manager.temporaryDirectory.appendingPathComponent("refs", conformingTo: .plainText)
    }

    func references() async -> [DiagReference] {
        guard let data = manager.contents(atPath: referenceFilePath.absoluteString) else {
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
        guard let data = manager.contents(atPath: reference.filePath.absoluteString) else {
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

    func addSummary(_ summary: DiagSummary, reference: DiagReference) async {
        var refs = await references()
        refs.insert(reference, at: 0)

        do {
            let encoder = JSONEncoder()

            let id = UUID().uuidString
            let summaryPath = manager.temporaryDirectory.appendingPathComponent(id, conformingTo: .plainText)
            let summaryData = try encoder.encode(summary)
            try summaryData.write(to: summaryPath)

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
            files = try manager.contentsOfDirectory(atPath: tempDir.absoluteString)
        } catch {
            log.error("failed to delete all: \(error)")
            return
        }

        for file in files {
            let path = tempDir.appending(path: file)
            do {
                try manager.removeItem(atPath: path.absoluteString)
            } catch {
                log.error("failed to delete file '\(file)': \(error)")
            }
        }
    }
}
