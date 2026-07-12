// Malreihen.swift
// Station 4 (3. Klasse): Malreihen sichern (das Einmaleins).
// Portiert aus dem React-Prototyp (genMalreihen). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum MalreihenGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = [2, 5, 10].randomElement(using: &rng)!
            let b = Int.random(in: 2...10, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) · \(b) = ?",
                antwort: a * b,
                thema: "Malreihe von \(a)",
                hinweis: "Zähl in \(a)er-Schritten: \(a), \(a * 2), \(a * 3) …"
            )

        case .trab:
            let a = Int.random(in: 2...10, using: &rng)
            let b = Int.random(in: 2...10, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) · \(b) = ?",
                antwort: a * b,
                thema: "Malreihe von \(a)",
                hinweis: "Denk an die \(a)er-Reihe: \(a), \(a * 2), \(a * 3) …"
            )

        case .galopp:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 2...9, using: &rng)
                let b = Int.random(in: 2...9, using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "\(a) · \(b) = ?",
                    antwort: a * b,
                    thema: "Mal-Rechnen mit Zehnerzahlen",
                    hinweis: "Rechne zuerst \(a) · \(b / 10), dann häng eine Null an."
                )
            }
            let a = Int.random(in: 3...9, using: &rng)
            let b = Int.random(in: 3...9, using: &rng)
            return ZahlenAufgabe(
                frage: "? · \(a) = \(a * b)",
                antwort: b,
                thema: "Fehlenden Faktor finden",
                hinweis: "Frag dich: WAS mal \(a) ergibt \(a * b)?"
            )
        }
    }
}
