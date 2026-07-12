//
//  LernWeideApp.swift
//  Helenas Lern-Weide 🐶🐴
//
//  App-Einstieg. SwiftData läuft vorerst rein lokal (ohne iCloud-Entitlement) –
//  der CloudKit-Sync kommt später durch bloßes Aktivieren der Capability dazu,
//  der Code bleibt identisch (siehe MatheWeideDaten.swift).
//

import SwiftUI
import SwiftData

@main
struct LernWeideApp: App {

    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Profil.self, StationsFortschritt.self)
        } catch {
            fatalError("SwiftData-Container konnte nicht erstellt werden: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TurnierpfadView()
                .task {
                    FortschrittsService(context: container.mainContext).raeumeAuf()
                }
        }
        .modelContainer(container)
    }
}
