// RundenUndUeberschlagen.swift
// Station 3 (4. Klasse): Runden & Überschlagen.
// Portiert aus dem React-Prototyp (genRunden). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum RundenGenerator {

    /// Kaufmännisch runden auf einen Stellenwert (10, 100, 1000).
    static func gerundet(_ n: Int, auf stelle: Int) -> Int {
        (n + stelle / 2) / stelle * stelle
    }

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            var n: Int
            repeat { n = Int.random(in: 21...289, using: &rng) } while n % 10 == 0
            return ZahlenAufgabe(
                frage: "Runde \(n) auf Zehner.",
                antwort: gerundet(n, auf: 10),
                thema: "Auf Zehner runden",
                hinweis: "Schau auf die Einerstelle: 0–4 → abrunden, 5–9 → aufrunden."
            )

        case .trab:
            var n: Int
            repeat { n = Int.random(in: 210...8900, using: &rng) } while n % 100 == 0
            return ZahlenAufgabe(
                frage: "Runde \(n.mitTausenderpunkt) auf Hunderter.",
                antwort: gerundet(n, auf: 100),
                thema: "Auf Hunderter runden",
                hinweis: "Schau auf die Zehnerstelle: 0–4 → abrunden, 5–9 → aufrunden."
            )

        case .galopp:
            switch Int.random(in: 0...2, using: &rng) {
            case 0:
                var n: Int
                repeat { n = Int.random(in: 2100...89000, using: &rng) } while n % 1000 == 0
                return ZahlenAufgabe(
                    frage: "Runde \(n.mitTausenderpunkt) auf Tausender.",
                    antwort: gerundet(n, auf: 1000),
                    thema: "Auf Tausender runden",
                    hinweis: "Schau auf die Hunderterstelle: 0–4 → abrunden, 5–9 → aufrunden."
                )
            case 1:
                let a = Int.random(in: 180...640, using: &rng)
                let b = Int.random(in: 180...640, using: &rng)
                return ZahlenAufgabe(
                    frage: "Überschlage: \(a) + \(b) ≈ ?  (beide Zahlen auf Hunderter runden)",
                    antwort: gerundet(a, auf: 100) + gerundet(b, auf: 100),
                    thema: "Überschlagsrechnen",
                    hinweis: "Runde zuerst: \(a) ≈ \(gerundet(a, auf: 100)) und \(b) ≈ \(gerundet(b, auf: 100)). Dann zusammenzählen."
                )
            default:
                let a = Int.random(in: 21...78, using: &rng)
                let b = Int.random(in: 3...6, using: &rng)
                return ZahlenAufgabe(
                    frage: "Überschlage: \(a) · \(b) ≈ ?  (\(a) auf Zehner runden)",
                    antwort: gerundet(a, auf: 10) * b,
                    thema: "Überschlagsrechnen",
                    hinweis: "Runde zuerst: \(a) ≈ \(gerundet(a, auf: 10)). Dann mal \(b)."
                )
            }
        }
    }
}
