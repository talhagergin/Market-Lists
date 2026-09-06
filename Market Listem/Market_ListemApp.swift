//
//  Market_ListemApp.swift
//  Market Listem
//
//  Created by Talha Gergin on 4.09.2026.
//

import SwiftUI
import SwiftData

@main
struct Market_ListemApp: App {
    private let persistence = PersistenceSetup.live()
    @State private var archiveStore = ProductArchiveStore()

    var body: some Scene {
        WindowGroup {
            ContentView(persistenceWarning: persistence.warning)
                .environment(archiveStore)
        }
        .modelContainer(persistence.container)
    }
}
