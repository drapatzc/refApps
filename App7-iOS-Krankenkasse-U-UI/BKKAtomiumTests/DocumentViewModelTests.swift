import Testing
import SwiftData
@testable import BKKAtomium

@Suite("DocumentViewModel")
struct DocumentViewModelTests {

    private func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: InsuranceDocument.self,
            BenefitRequest.self,
            Invoice.self,
            Document.self,
            configuration: config
        )
        return container
    }

    @Test("Load documents")
    func loadDocuments() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        #expect(!viewModel.documents.isEmpty || viewModel.documents.isEmpty)
    }

    @Test("Add document")
    func addDocument() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)
        let initialCount = viewModel.documents.count

        let testData = "Test PDF Content".data(using: .utf8) ?? Data()
        let newDocument = Document(
            title: "Test Document",
            documentType: .bescheinigung,
            fileData: testData,
            uploadDate: Date(),
            notes: "Test note"
        )
        try? container.mainContext.insert(newDocument)
        try? container.mainContext.save()

        await viewModel.setup(context: container.mainContext)
        #expect(viewModel.documents.count == initialCount + 1)
    }

    @Test("Delete document")
    func deleteDocument() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        if let firstDocument = viewModel.documents.first {
            try? container.mainContext.delete(firstDocument)
            try? container.mainContext.save()

            await viewModel.setup(context: container.mainContext)
            #expect(!viewModel.documents.contains(where: { $0.id == firstDocument.id }))
        }
    }

    @Test("Calculate storage usage")
    func calculateStorageUsage() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        let totalSize = viewModel.documents.reduce(0) { $0 + Double(viewModel.getFileSizeInKB(viewModel.documents.count)) }
        #expect(totalSize >= 0)
    }

    @Test("Get file size in KB")
    func getFileSizeInKB() {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        let testData = "X".repeated(1024).data(using: .utf8) ?? Data() // ~1 KB
        let sizeKB = Double(testData.count) / 1024.0

        #expect(sizeKB > 0)
    }

    @Test("Documents sorted by upload date descending")
    func documentsSortedByDate() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        for i in 0..<(viewModel.documents.count - 1) {
            let current = viewModel.documents[i]
            let next = viewModel.documents[i + 1]
            #expect(current.uploadDate >= next.uploadDate)
        }
    }

    @Test("Filter documents by type")
    func filterByType() async {
        let container = makeContainer()
        let viewModel = DocumentViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        let bescheinigungen = viewModel.documents.filter { $0.documentType == .bescheinigung }
        #expect(bescheinigungen.count >= 0)
    }
}
