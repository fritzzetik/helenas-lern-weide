// AufwaermenBis100.swift
// Station 1 (3. Klasse): Aufwärmen – Plus & Minus bis 100 (Wiederholung 2. Klasse).
// Portiert aus dem React-Prototyp (genWarm100). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum AufwaermenGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            // Ohne Zehnerübergang – nur die Einer ändern sich.
            if Bool.random(using: &rng) {
                let a = Int.random(in: 2...7, using: &rng) * 10 + Int.random(in: 1...4, using: &rng)
                let b = Int.random(in: 1...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus bis 100 ohne Übergang",
                    hinweis: "Nur die Einer ändern sich."
                )
            }
            let a = Int.random(in: 2...8, using: &rng) * 10 + Int.random(in: 5...9, using: &rng)
            let b = Int.random(in: 1...4, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus bis 100 ohne Übergang",
                hinweis: "Nur die Einer ändern sich."
            )

        case .trab:
            // Mit Zehnerübergang.
            if Bool.random(using: &rng) {
                let a = Int.random(in: 15...60, using: &rng)
                let b = Int.random(in: 5...min(39, 100 - a), using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus bis 100 mit Übergang",
                    hinweis: "Rechne zuerst bis zum nächsten Zehner, dann den Rest."
                )
            }
            let a = Int.random(in: 31...99, using: &rng)
            let b = Int.random(in: 5...29, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus bis 100 mit Übergang",
                hinweis: "Zieh zuerst bis zum Zehner ab, dann den Rest."
            )

        case .galopp:
            // Ergänzen auf runde Ziele.
            let ziel = [50, 70, 80, 100].randomElement(using: &rng)!
            let b = Int.random(in: 11...(ziel - 10), using: &rng)
            return ZahlenAufgabe(
                frage: "\(b) + ? = \(ziel)",
                antwort: ziel - b,
                thema: "Ergänzen bis 100",
                hinweis: "Wie viel fehlt von \(b) bis \(ziel)?"
            )
        }
    }
}
