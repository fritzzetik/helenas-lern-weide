// InRechnungen.swift
// Station 5 (3. Klasse): In-Rechnungen (Dividieren ohne Rest).
// Portiert aus dem React-Prototyp (genInRechnungen). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum InRechnungenGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = [2, 5, 10].randomElement(using: &rng)!
            let b = Int.random(in: 2...10, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a * b) : \(a) = ?",
                antwort: b,
                thema: "In-Rechnungen mit leichten Reihen",
                hinweis: "Frag dich: \(a) mal WAS ergibt \(a * b)?"
            )

        case .trab:
            let a = Int.random(in: 2...10, using: &rng)
            let b = Int.random(in: 2...10, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a * b) : \(a) = ?",
                antwort: b,
                thema: "In-Rechnungen (Dividieren)",
                hinweis: "Frag dich: \(a) mal WAS ergibt \(a * b)?"
            )

        case .galopp:
            let a = Int.random(in: 2...9, using: &rng)
            let b = Int.random(in: 2...9, using: &rng) * 10
            return ZahlenAufgabe(
                frage: "\(a * b) : \(a) = ?",
                antwort: b,
                thema: "In-Rechnen mit großen Zahlen",
                hinweis: "Rechne zuerst \(a * b / 10) : \(a), dann häng eine Null an."
            )
        }
    }
}
