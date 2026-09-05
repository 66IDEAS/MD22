import SwiftData

enum MD22SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [HistoryRecord.self, ReadingStateRecord.self, BookmarkRecord.self]
    }
}

enum MD22MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MD22SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

