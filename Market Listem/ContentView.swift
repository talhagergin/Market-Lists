//
//  ContentView.swift
//  Market Listem
//
//  Created by Talha Gergin on 4.09.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Product.createdAt) private var products: [Product]
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var activeIssue: AppIssue?

    init(persistenceWarning: String? = nil) {
        _activeIssue = State(initialValue: persistenceWarning.map(AppIssue.init(message:)))
    }

    var body: some View {
        TabView {
            Tab("Liste", systemImage: "checklist") { ShoppingListView() }
            Tab("Ev", systemImage: "house.fill") { HomeView() }
            Tab("Geçmiş", systemImage: "clock.arrow.circlepath") { HistoryView() }
        }
        .tint(.green)
        .onReceive(NotificationCenter.default.publisher(for: .inventoryPersistenceError)) { notification in
            let message = notification.userInfo?["message"] as? String
            activeIssue = AppIssue(
                message: message ?? String(localized: "Değişiklik kaydedilemedi. Lütfen tekrar dene.")
            )
        }
        .alert(item: $activeIssue) { issue in
            Alert(
                title: Text("Veri Sorunu"),
                message: Text(issue.message),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .fullScreenCover(isPresented: onboardingPresentation) {
            OnboardingView { hasCompletedOnboarding = true }
        }
        .task { refreshWidgetList() }
        .onChange(of: widgetItems) { _, items in
            WidgetListStore.save(items)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshWidgetList() }
        }
    }

    private var onboardingPresentation: Binding<Bool> {
        Binding(
            get: {
#if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--sample-data") ||
                    ProcessInfo.processInfo.arguments.contains("--ui-testing") { return false }
#endif
                return !hasCompletedOnboarding
            },
            set: { isPresented in
                if !isPresented { hasCompletedOnboarding = true }
            }
        )
    }

    private var widgetItems: [WidgetListItem] {
        products
            .filter(\.isInShoppingList)
            .map {
                WidgetListItem(
                    id: $0.id,
                    name: $0.name,
                    quantity: $0.quantity,
                    categoryRawValue: $0.categoryRawValue
                )
            }
    }

    private func refreshWidgetList() {
        WidgetListStore.save(widgetItems)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Product.self, PurchaseRecord.self], inMemory: true)
        .environment(ProductArchiveStore())
}
