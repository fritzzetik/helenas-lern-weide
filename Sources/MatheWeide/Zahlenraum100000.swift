// Zahlenraum100000.swift
// Station 1 (4. Klasse): Zahlenraum 100.000 entdecken (Stellenwert).
// Portiert aus dem React-Prototyp (genZahlenraum100k). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum Zahlenraum100000Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let variante = Int.random(in: 0...1, using: &rng)
        switch gangart {
        case .schritt:
            if variante == 0 {
                let zt = Int.random(in: 1...9, using: &rng)
                let t = Int.random(in: 1...9, using: &rng)
                let h = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\((zt * 10000).mitTausenderpunkt) + \((t * 1000).mitTausenderpunkt) + \(h * 100) = ?",
                    antwort: zt * 10000 + t * 1000 + h * 100,
                    thema: "Große Zahlen zusammensetzen",
                    hinweis: "Zehntausender, Tausender und Hunderter nebeneinander schreiben."
                )
            }
            let t = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Wie viele Hunderter hat die Zahl \((t * 1000).mitTausenderpunkt)?",
                antwort: t * 10,
                thema: "Stellenwert verstehen",
                hinweis: "\((t * 1000).mitTausenderpunkt) sind \(t) Tausender – und jeder Tausender hat 10 Hunderter."
            )

        case .trab:
            if variante == 0 {
                let start = Int.random(in: 23...88, using: &rng) * 1000
                return ZahlenAufgabe(
                    frage: "Zähle in Tausenderschritten weiter: \(start.mitTausenderpunkt), \((start + 1000).mitTausenderpunkt), ?",
                    antwort: start + 2000,
                    thema: "In Tausenderschritten zählen",
                    hinweis: "Immer 1000 dazu."
                )
            }
            // n ist nie ein glatter Tausender (Hunderterstelle 1–9).
            let n = Int.random(in: 21...89, using: &rng) * 1000 + Int.random(in: 1...9, using: &rng) * 100
            return ZahlenAufgabe(
                frage: "Welcher Tausender kommt direkt nach \(n.mitTausenderpunkt)?",
                antwort: (n / 1000 + 1) * 1000,
                thema: "Nachbartausender finden",
                hinweis: "Der nächste Tausender ist die nächste runde Tausenderzahl."
            )

        case .galopp:
            if variante == 0 {
                let a = Int.random(in: 2...7, using: &rng) * 10000
                return ZahlenAufgabe(
                    frage: "Welche Zahl liegt genau in der Mitte zwischen \(a.mitTausenderpunkt) und \((a + 20000).mitTausenderpunkt)?",
                    antwort: a + 10000,
                    thema: "Zahlen auf dem Zahlenstrahl",
                    hinweis: "Die Mitte ist gleich weit von beiden entfernt."
                )
            }
            let zt = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\((zt * 10000).mitTausenderpunkt) = ? Tausender",
                antwort: zt * 10,
                thema: "Stellenwerte umdenken",
                hinweis: "1 Zehntausender sind 10 Tausender."
            )
        }
    }
}
