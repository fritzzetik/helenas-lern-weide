//
//  Stationen.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Dünne Brücke zwischen UI und dem getesteten LernWeide-Package:
//  Stationen, Metadaten und ALLE Aufgaben kommen aus MatheWeide –
//  identisch zum React-Prototyp und per CI abgesichert. Hier wird
//  nichts neu erfunden. Das LLM (Bruno) erklärt nur, es rechnet NIE.
//

import Foundation
import LernWeideCore
import MatheWeide

// MARK: - AppAufgabe: UI-Sicht auf eine Package-Aufgabe

/// Eine Aufgabe, wie die Runde sie braucht: Frage plus 1 oder 2
/// Eingabefelder (z. B. Ergebnis + Rest) und Metadaten für Bruno.
struct AppAufgabe: Sendable {
    let frage: String
    let felder: [Feld]              // 1 oder 2 Eingaben
    let thema: String
    let hinweis: String

    struct Feld {
        let label: String           // z. B. "=", "Rest"
        let antwort: Int
    }

    init(_ aufgabe: MatheWeide.MatheAufgabe) {
        frage = aufgabe.frage
        thema = aufgabe.thema
        hinweis = aufgabe.hinweis
        switch aufgabe {
        case .zahl(let z):
            felder = [Feld(label: "=", antwort: z.antwort)]
        case .divisionMitRest(let d):
            felder = [Feld(label: "Ergebnis", antwort: d.ergebnis),
                      Feld(label: "Rest", antwort: d.rest)]
        }
    }

    var antwortText: String {
        if felder.count == 1 { return "\(felder[0].antwort)" }
        return "\(felder[0].antwort), Rest \(felder[1].antwort)"
    }

    /// Brücke zum BrunoErklaerungsService (dessen BrunoAufgabe-Modell).
    /// `station` liefert die ähnlichen Aufgaben für den Quercheck.
    func alsBrunoAufgabe(gangart: Gangart, station: MatheStation) -> BrunoAufgabe {
        BrunoAufgabe(
            frage: frage,
            antwortText: antwortText,
            thema: thema,
            hinweis: hinweis,
            gangart: gangart.rawValue,
            neueAehnlicheAufgabe: { rohwert in
                let g = Gangart(rawValue: rohwert) ?? .schritt
                return station.appAufgabe(gangart: g).alsBrunoAufgabe(gangart: g, station: station)
            }
        )
    }
}

// MARK: - MatheStation für die App

extension MatheStation {
    /// Neue Aufgabe mit dem System-RNG (die Package-Tests nutzen Seed-RNGs).
    func appAufgabe(gangart: Gangart) -> AppAufgabe {
        var rng = SystemRandomNumberGenerator()
        return AppAufgabe(neueAufgabe(gangart: gangart, using: &rng))
    }
}

// MARK: - Pfade

/// Die Turnierpfade aus dem Package, ausgewählt nach Profil-Klasse.
enum Pfade {
    static func pfad(fuer klasse: String) -> Turnierpfad<MatheStation> {
        klasse == "klasse4" ? Turnierpfade.klasse4 : Turnierpfade.klasse3
    }
}

// MARK: - Pausen-Wächter

/// Verpflichtende Bewegungspause: Das Ende liegt als Zeitstempel in
/// UserDefaults und übersteht damit App-Neustart und Hintergrund –
/// genau wie im Web-Prototyp (localStorage). Kein Austricksen. 🙂
enum PausenWaechter {
    private static let schluessel = "lernweide.pauseEnde"

    static var ende: Date {
        Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: schluessel))
    }

    /// Nach jeder Runde aufrufen – startet die 3 Minuten.
    static func starten() {
        let ende = Date().addingTimeInterval(TimeInterval(Bewegungspause.dauerSekunden))
        UserDefaults.standard.set(ende.timeIntervalSince1970, forKey: schluessel)
    }

    static var laeuft: Bool { Date() < ende }

    static var restSekunden: Int {
        max(0, Int(ende.timeIntervalSinceNow.rounded(.up)))
    }
}
