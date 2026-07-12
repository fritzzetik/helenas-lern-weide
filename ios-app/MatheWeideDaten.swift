//
//  MatheWeideDaten.swift
//  Helenas Lern-Weide 🐶🐴 – Modul Mathe
//
//  Lokale Speicherung mit SwiftData + optionalem iCloud-Sync (CloudKit).
//
//  Datenschutz-Architektur:
//  ┌────────────────────────────────────────────────────────────────┐
//  │  iPhone (SwiftData)  ⇄  private iCloud-Datenbank des Accounts  │
//  │                                                                │
//  │  - KEINE zentrale Speicherung, kein eigener Server             │
//  │  - Daten liegen verschlüsselt in Helenas eigener iCloud        │
//  │  - Der Entwickler kann die Inhalte NICHT einsehen              │
//  │  - Ohne iCloud-Capability (Gratis-Account): rein lokal,        │
//  │    identischer Code – der Sync kommt später einfach dazu       │
//  └────────────────────────────────────────────────────────────────┘
//
//  Einrichtung für iCloud-Sync (braucht bezahlten Developer-Account):
//  1. Target → Signing & Capabilities → „+ Capability“ → iCloud
//     → CloudKit anhaken → Container anlegen,
//       z. B. iCloud.at.deinname.matheweide
//  2. „+ Capability“ → Background Modes → Remote notifications anhaken
//  3. Fertig – SwiftData synchronisiert automatisch.
//
//  CloudKit-Spielregeln für @Model-Klassen (deshalb sieht das Modell so aus):
//  - Jede Property braucht einen Default-Wert ODER ist optional
//  - Keine #Unique-Constraints → Duplikate nach Sync selbst zusammenführen
//    (macht unten FortschrittsService.raeumeAuf())
//  - Beziehungen müssen optional sein
//

import Foundation
import SwiftData

// MARK: - Modelle

/// Helenas Profil – hier wandert der Klassen-Schalter hin.
@Model
final class Profil {
    var name: String = "Helena"
    var klasse: String = "klasse3"          // "klasse3" | "klasse4"
    var erstelltAm: Date = Date()

    init(name: String = "Helena", klasse: String = "klasse3") {
        self.name = name
        self.klasse = klasse
    }
}

/// Heutige Übungs-Statistik für Daisys Tagesbericht 📸.
/// Ein Datensatz pro Kalendertag (Schlüssel "JJJJ-MM-TT").
@Model
final class Tagesstatistik {
    var datum: String = ""
    var aufgaben: Int = 0
    var sterne: Int = 0
    var schleifen: Int = 0

    init(datum: String) {
        self.datum = datum
    }
}

/// Fortschritt pro Turnier-Station.
/// stationID entspricht den IDs aus dem Turnierpfad
/// (z. B. "s3_warm", "s3_rest", "s4_final").
@Model
final class StationsFortschritt {
    var stationID: String = ""
    var schleife: Bool = false              // 🎀 bestanden?
    var schleifeAm: Date?                   // wann gewonnen (fürs Trophäenregal!)
    var gangart: Int = 0                    // 0 Schritt, 1 Trab, 2 Galopp
    var besteSterne: Int = 0                // Bestleistung (0–5)
    var rundenGespielt: Int = 0
    var zuletztGeuebt: Date?

    init(stationID: String) {
        self.stationID = stationID
    }
}

// MARK: - Fortschritts-Service

/// Kapselt alles Laden/Speichern, damit die Views schlank bleiben.
/// Die Freischalt-Logik (welche Station ist offen?) lebt hier –
/// identisch zum React-Prototyp.
@MainActor
final class FortschrittsService {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Profil

    /// Liefert das Profil – legt beim allerersten Start eines an.
    func profil() -> Profil {
        let vorhandene = (try? context.fetch(FetchDescriptor<Profil>())) ?? []
        if let p = vorhandene.first { return p }
        let neu = Profil()
        context.insert(neu)
        try? context.save()
        return neu
    }

    func setzeKlasse(_ klasse: String) {
        profil().klasse = klasse
        try? context.save()
    }

    // MARK: Stationen

    /// Fortschritt einer Station – legt bei Bedarf einen leeren an.
    func fortschritt(fuer stationID: String) -> StationsFortschritt {
        let deskriptor = FetchDescriptor<StationsFortschritt>(
            predicate: #Predicate { $0.stationID == stationID }
        )
        let treffer = (try? context.fetch(deskriptor)) ?? []
        if let f = treffer.first { return f }
        let neu = StationsFortschritt(stationID: stationID)
        context.insert(neu)
        try? context.save()
        return neu
    }

    /// Nach jeder Runde aufrufen – speichert alles auf einmal.
    /// `schleifeGewonnen` nur true, wenn die Runde die Kriterien erfüllt
    /// hat (≥ 4 Sterne in Trab oder Galopp) – die Prüfung macht die
    /// Spiellogik, hier wird nur persistiert.
    func rundeBeendet(
        stationID: String,
        aufgaben: Int,
        sterne: Int,
        gangart: Int,
        schleifeGewonnen: Bool
    ) {
        let f = fortschritt(fuer: stationID)
        let schleifeNeu = schleifeGewonnen && !f.schleife
        f.rundenGespielt += 1
        f.gangart = gangart
        f.besteSterne = max(f.besteSterne, sterne)
        f.zuletztGeuebt = Date()
        if schleifeNeu {
            f.schleife = true
            f.schleifeAm = Date()
        }

        // Daisys Tagesbericht 📸 mitzählen
        let heute = heutigeStatistik()
        heute.aufgaben += aufgaben
        heute.sterne += sterne
        if schleifeNeu { heute.schleifen += 1 }

        try? context.save()
    }

    // MARK: Tagesstatistik (Daisys Tagesbericht 📸)

    /// Kalendertag als Schlüssel, z. B. "2026-07-12".
    static func datumsSchluessel(_ tag: Date = Date()) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: tag)
    }

    /// Statistik für heute – legt bei Bedarf einen frischen Datensatz an.
    func heutigeStatistik() -> Tagesstatistik {
        let heute = Self.datumsSchluessel()
        let deskriptor = FetchDescriptor<Tagesstatistik>(
            predicate: #Predicate { $0.datum == heute }
        )
        if let t = ((try? context.fetch(deskriptor)) ?? []).first { return t }
        let neu = Tagesstatistik(datum: heute)
        context.insert(neu)
        try? context.save()
        return neu
    }

    // MARK: Freischalt-Logik (wie im Prototyp)

    enum StationsStatus { case geschafft, offen, gesperrt }

    /// Eine Station ist offen, wenn sie die erste ist oder die vorige
    /// eine Schleife hat. Geschaffte bleiben immer offen (Freies Training).
    func status(stationID: String, inReihenfolge alleIDs: [String]) -> StationsStatus {
        if fortschritt(fuer: stationID).schleife { return .geschafft }
        guard let idx = alleIDs.firstIndex(of: stationID) else { return .gesperrt }
        if idx == 0 { return .offen }
        return fortschritt(fuer: alleIDs[idx - 1]).schleife ? .offen : .gesperrt
    }

    /// Für Wiederholungs-Mix: alle geschafften Stationen des Pfads.
    func geschaffteStationen(inReihenfolge alleIDs: [String]) -> [String] {
        alleIDs.filter { fortschritt(fuer: $0).schleife }
    }

    // MARK: CloudKit-Hygiene

    /// CloudKit kennt keine Unique-Constraints: Wenn zwei Geräte
    /// gleichzeitig denselben Fortschritt anlegen, entstehen nach dem
    /// Sync Duplikate. Diese Funktion führt sie zusammen (beste Werte
    /// gewinnen, Schleife bleibt Schleife). Beim App-Start aufrufen.
    func raeumeAuf() {
        let alle = (try? context.fetch(FetchDescriptor<StationsFortschritt>())) ?? []
        let gruppen = Dictionary(grouping: alle, by: \.stationID)
        for (_, duplikate) in gruppen where duplikate.count > 1 {
            let behalten = duplikate[0]
            for d in duplikate.dropFirst() {
                behalten.schleife = behalten.schleife || d.schleife
                behalten.schleifeAm = [behalten.schleifeAm, d.schleifeAm].compactMap { $0 }.min()
                behalten.gangart = max(behalten.gangart, d.gangart)
                behalten.besteSterne = max(behalten.besteSterne, d.besteSterne)
                behalten.rundenGespielt += d.rundenGespielt
                behalten.zuletztGeuebt = [behalten.zuletztGeuebt, d.zuletztGeuebt].compactMap { $0 }.max()
                context.delete(d)
            }
        }
        // Tagesstatistiken: Duplikate desselben Tages aufsummieren.
        let tage = (try? context.fetch(FetchDescriptor<Tagesstatistik>())) ?? []
        for (_, dubletten) in Dictionary(grouping: tage, by: \.datum) where dubletten.count > 1 {
            let behalten = dubletten[0]
            for d in dubletten.dropFirst() {
                behalten.aufgaben += d.aufgaben
                behalten.sterne += d.sterne
                behalten.schleifen += d.schleifen
                context.delete(d)
            }
        }
        // Falls auch das Profil doppelt synchronisiert wurde:
        let profile = (try? context.fetch(FetchDescriptor<Profil>())) ?? []
        for p in profile.dropFirst() { context.delete(p) }
        try? context.save()
    }
}

// MARK: - App-Einstieg (Beispiel)

/*
import SwiftUI
import SwiftData

@main
struct MatheWeideApp: App {

    // Ein Container für beide Modelle. Sobald die iCloud-Capability
    // gesetzt ist, synchronisiert SwiftData automatisch über CloudKit –
    // der Code bleibt exakt gleich. Ohne Capability: rein lokal.
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
                    // Duplikate aus dem CloudKit-Sync zusammenführen
                    FortschrittsService(context: container.mainContext).raeumeAuf()
                }
        }
        .modelContainer(container)
    }
}

// MARK: Verwendung in einer View

struct TurnierpfadView: View {
    @Environment(\.modelContext) private var context

    // Live-aktualisierte Abfrage: sobald CloudKit neue Daten liefert
    // (z. B. Helena hat am iPad geübt), aktualisiert sich die View.
    @Query private var fortschritte: [StationsFortschritt]

    private var service: FortschrittsService {
        FortschrittsService(context: context)
    }

    var body: some View {
        // Beispiel: Klassen-Schalter aus dem Profil
        let profil = service.profil()

        List {
            Text("Hallo \(profil.name)! 🐶🐴")
            // … Turnierpfad-Stationen mit
            //    service.status(stationID:inReihenfolge:) rendern
        }
    }
}
*/
