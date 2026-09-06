import Foundation
import SwiftData

enum MarketListemSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Product.self, PurchaseRecord.self] }
}

enum MarketListemMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [MarketListemSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

struct PersistenceSetup {
    let container: ModelContainer
    let warning: String?

    @MainActor
    static func live() -> PersistenceSetup {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(
                    for: Product.self,
                    PurchaseRecord.self,
                    configurations: configuration
                )
                return PersistenceSetup(container: container, warning: nil)
            } catch {
                fatalError("UI test konteyneri oluşturulamadı: \(error.localizedDescription)")
            }
        }

        if ProcessInfo.processInfo.arguments.contains("--sample-data") {
            do {
                return PersistenceSetup(container: try PreviewData.makeContainer(), warning: nil)
            } catch {
                assertionFailure("Örnek veri konteyneri oluşturulamadı: \(error.localizedDescription)")
            }
        }
#endif
        do {
            let container = try ModelContainer(
                for: Product.self,
                PurchaseRecord.self,
                migrationPlan: MarketListemMigrationPlan.self
            )
            return PersistenceSetup(container: container, warning: nil)
        } catch {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                let fallback = try ModelContainer(
                    for: Product.self,
                    PurchaseRecord.self,
                    configurations: configuration
                )
                return PersistenceSetup(
                    container: fallback,
                    warning: "Kayıtlı verilere erişilemedi. Bu oturumdaki değişiklikler kalıcı olmayacak."
                )
            } catch {
                fatalError("SwiftData model container oluşturulamadı: \(error.localizedDescription)")
            }
        }
    }
}

extension Notification.Name {
    static let inventoryPersistenceError = Notification.Name("inventoryPersistenceError")
}

struct AppIssue: Identifiable {
    let id = UUID()
    let message: String
}
