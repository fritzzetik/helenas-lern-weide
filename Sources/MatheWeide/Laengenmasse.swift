// Laengenmasse.swift
// Station 7 (3. Klasse): Längenmaße (mm folgt erst in der 4. Klasse).
// Portiert aus dem React-Prototyp (genLaengen). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum LaengenGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            if Bool.random(using: &rng) {
                let m = Int.random(in: 1...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(m) m = ? cm",
                    antwort: m * 100,
                    thema: "Längenmaße umwandeln",
                    hinweis: "1 m sind 100 cm."
                )
            }
            let km = Int.random(in: 1...5, using: &rng)
            return ZahlenAufgabe(
                frage: "\(km) km = ? m",
                antwort: km * 1000,
                thema: "Kilometer und Meter",
                hinweis: "1 km sind 1000 m."
            )

        case .trab:
            if Bool.random(using: &rng) {
                let m = Int.random(in: 2...9, using: &rng)
                let cm = [10, 20, 40, 50].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "\(m) m \(cm) cm = ? cm",
                    antwort: m * 100 + cm,
                    thema: "Längenmaße umwandeln",
                    hinweis: "1 m sind 100 cm – dann die restlichen cm dazuzählen."
                )
            }
            let km = Int.random(in: 2...9, using: &rng)
            let m = [200, 500, 250].randomElement(using: &rng)!
            return ZahlenAufgabe(
                frage: "\(km) km \(m) m = ? m",
                antwort: km * 1000 + m,
                thema: "Kilometer und Meter",
                hinweis: "1 km sind 1000 m – dann die restlichen Meter dazuzählen."
            )

        case .galopp:
            if Bool.random(using: &rng) {
                let m = Int.random(in: 2...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(m * 100) cm = ? m",
                    antwort: m,
                    thema: "Längenmaße rückwärts",
                    hinweis: "100 cm sind 1 m."
                )
            }
            let km = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\((km * 1000).mitTausenderpunkt) m = ? km",
                antwort: km,
                thema: "Meter rückwärts in Kilometer",
                hinweis: "1000 m sind 1 km."
            )
        }
    }
}
