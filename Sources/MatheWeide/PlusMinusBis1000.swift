// PlusMinusBis1000.swift
// Station 3 (3. Klasse): Plus & Minus bis 1000.
// Portiert aus dem React-Prototyp (genPlusMinus1000). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum PlusMinus1000Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            // Glatte Zehner – die Null bleibt.
            if Bool.random(using: &rng) {
                let a = Int.random(in: 12...60, using: &rng) * 10
                let b = Int.random(in: 5...((990 - a) / 10), using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus mit glatten Zehnern",
                    hinweis: "Rechne mit den Zehnern – die Null bleibt."
                )
            }
            let a = Int.random(in: 30...99, using: &rng) * 10
            let b = Int.random(in: 5...(a / 10 - 12), using: &rng) * 10
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus mit glatten Zehnern",
                hinweis: "Rechne mit den Zehnern – die Null bleibt."
            )

        case .trab:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 120...850, using: &rng)
                let b = Int.random(in: 15...(999 - a), using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus im Zahlenraum 1000",
                    hinweis: "Rechne zuerst die Hunderter, dann die Zehner, dann die Einer."
                )
            }
            let a = Int.random(in: 200...999, using: &rng)
            let b = Int.random(in: 15...(a - 20), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus im Zahlenraum 1000",
                hinweis: "Zieh zuerst die Hunderter ab, dann die Zehner, dann die Einer."
            )

        case .galopp:
            // Ergänzen mit Platzhalter.
            if Bool.random(using: &rng) {
                let ziel = Int.random(in: 300...1000, using: &rng)
                let b = Int.random(in: 50...(ziel - 50), using: &rng)
                return ZahlenAufgabe(
                    frage: "? + \(b) = \(ziel)",
                    antwort: ziel - b,
                    thema: "Ergänzen im Zahlenraum 1000",
                    hinweis: "Rechne rückwärts: \(ziel) minus \(b)."
                )
            }
            let a = Int.random(in: 300...999, using: &rng)
            let erg = Int.random(in: 50...(a - 50), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − ? = \(erg)",
                antwort: a - erg,
                thema: "Ergänzen im Zahlenraum 1000",
                hinweis: "Wie viel fehlt von \(erg) bis \(a)?"
            )
        }
    }
}
