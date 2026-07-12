// Zahlenraum1000.swift
// Station 2 (3. Klasse): Zahlenraum 1000 entdecken (Stellenwert).
// Portiert aus dem React-Prototyp (genZahlenraum1000). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum Zahlenraum1000Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let variante = Int.random(in: 0...2, using: &rng)
        switch gangart {
        case .schritt:
            switch variante {
            case 0:
                let h = Int.random(in: 2...9, using: &rng)
                let z = Int.random(in: 1...9, using: &rng)
                let e = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(h * 100) + \(z * 10) + \(e) = ?",
                    antwort: h * 100 + z * 10 + e,
                    thema: "Zahlen zusammensetzen",
                    hinweis: "Hunderter, Zehner und Einer einfach nebeneinander schreiben."
                )
            case 1:
                let h = Int.random(in: 2...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "Wie viele Zehner hat die Zahl \(h * 100)?",
                    antwort: h * 10,
                    thema: "Stellenwert verstehen",
                    hinweis: "\(h * 100) sind \(h) Hunderter – und jeder Hunderter hat 10 Zehner."
                )
            default:
                let h = Int.random(in: 2...9, using: &rng)
                let z = Int.random(in: 1...9, using: &rng)
                let e = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "Welche Zahl ist das: \(h) H \(z) Z \(e) E?",
                    antwort: h * 100 + z * 10 + e,
                    thema: "Stellenwert verstehen",
                    hinweis: "H = Hunderter, Z = Zehner, E = Einer."
                )
            }

        case .trab:
            switch variante {
            case 0:
                let start = Int.random(in: 2...7, using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "Zähle in Hunderterschritten weiter: \(start), \(start + 100), ?",
                    antwort: start + 200,
                    thema: "In Hunderterschritten zählen",
                    hinweis: "Immer 100 dazu."
                )
            case 1:
                let start = Int.random(in: 15...88, using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "Zähle in Zehnerschritten weiter: \(start), \(start + 10), ?",
                    antwort: start + 20,
                    thema: "In Zehnerschritten zählen",
                    hinweis: "Immer 10 dazu."
                )
            default:
                // n ist nie ein glatter Zehner (Einerstelle 1–9).
                let n = Int.random(in: 21...89, using: &rng) * 10 + Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "Welcher Zehner kommt direkt nach \(n)?",
                    antwort: (n / 10 + 1) * 10,
                    thema: "Nachbarzehner finden",
                    hinweis: "Der nächste Zehner ist die nächste runde Zahl."
                )
            }

        case .galopp:
            switch variante {
            case 0:
                let a = Int.random(in: 2...7, using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "Welche Zahl liegt genau in der Mitte zwischen \(a) und \(a + 200)?",
                    antwort: a + 100,
                    thema: "Zahlen auf dem Zahlenstrahl",
                    hinweis: "Die Mitte ist gleich weit von beiden entfernt."
                )
            case 1:
                let h = Int.random(in: 3...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(h * 100) = ? Zehner",
                    antwort: h * 10,
                    thema: "Stellenwerte umdenken",
                    hinweis: "1 Hunderter sind 10 Zehner."
                )
            default:
                // n ist nie ein glatter Hunderter (Zehnerstelle 1–9).
                let n = Int.random(in: 3...8, using: &rng) * 100 + Int.random(in: 1...9, using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "Welcher Hunderter kommt direkt nach \(n)?",
                    antwort: (n / 100 + 1) * 100,
                    thema: "Nachbarhunderter finden",
                    hinweis: "Der nächste Hunderter ist die nächste runde Hunderterzahl."
                )
            }
        }
    }
}
