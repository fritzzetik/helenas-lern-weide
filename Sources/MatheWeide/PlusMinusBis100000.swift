// PlusMinusBis100000.swift
// Station 2 (4. Klasse): Plus & Minus bis 100.000.
// Portiert aus dem React-Prototyp (genPlusMinus100k). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum PlusMinus100000Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            // Glatte Hunderter im Zahlenraum 10.000.
            if Bool.random(using: &rng) {
                let a = Int.random(in: 12...68, using: &rng) * 100
                let b = Int.random(in: 11...((9900 - a) / 100), using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "\(a.mitTausenderpunkt) + \(b.mitTausenderpunkt) = ?",
                    antwort: a + b,
                    thema: "Plus im Zahlenraum 10.000",
                    hinweis: "Rechne mit den Tausendern und Hundertern – die Nullen bleiben."
                )
            }
            let a = Int.random(in: 40...99, using: &rng) * 100
            let b = Int.random(in: 11...(a / 100 - 15), using: &rng) * 100
            return ZahlenAufgabe(
                frage: "\(a.mitTausenderpunkt) − \(b.mitTausenderpunkt) = ?",
                antwort: a - b,
                thema: "Minus im Zahlenraum 10.000",
                hinweis: "Zieh die Tausender und Hunderter ab – die Nullen bleiben."
            )

        case .trab:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 120...750, using: &rng) * 100
                let b = Int.random(in: 50...((99000 - a) / 100), using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "\(a.mitTausenderpunkt) + \(b.mitTausenderpunkt) = ?",
                    antwort: a + b,
                    thema: "Plus im Zahlenraum 100.000",
                    hinweis: "Denk in Hunderterschritten: die letzten zwei Nullen bleiben."
                )
            }
            let a = Int.random(in: 300...990, using: &rng) * 100
            let b = Int.random(in: 50...(a / 100 - 60), using: &rng) * 100
            return ZahlenAufgabe(
                frage: "\(a.mitTausenderpunkt) − \(b.mitTausenderpunkt) = ?",
                antwort: a - b,
                thema: "Minus im Zahlenraum 100.000",
                hinweis: "Denk in Hunderterschritten: die letzten zwei Nullen bleiben."
            )

        case .galopp:
            if Bool.random(using: &rng) {
                let ziel = Int.random(in: 20...100, using: &rng) * 1000
                let b = Int.random(in: 5...(ziel / 1000 - 4), using: &rng) * 1000
                return ZahlenAufgabe(
                    frage: "? + \(b.mitTausenderpunkt) = \(ziel.mitTausenderpunkt)",
                    antwort: ziel - b,
                    thema: "Ergänzen im Zahlenraum 100.000",
                    hinweis: "Rechne rückwärts: \(ziel.mitTausenderpunkt) minus \(b.mitTausenderpunkt)."
                )
            }
            let b = Int.random(in: 10...90, using: &rng) * 1000
            return ZahlenAufgabe(
                frage: "\(b.mitTausenderpunkt) + ? = \(100000.mitTausenderpunkt)",
                antwort: 100000 - b,
                thema: "Ergänzen auf 100.000",
                hinweis: "Wie viel fehlt von \(b.mitTausenderpunkt) bis \(100000.mitTausenderpunkt)?"
            )
        }
    }
}
