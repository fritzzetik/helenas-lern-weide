// GeldUndZeit.swift
// Station 9 (3. Klasse): Geld & Zeit.
// Portiert aus dem React-Prototyp (genGeldZeit). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum GeldZeitGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            if Bool.random(using: &rng) {
                let euro = Int.random(in: 1...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(euro) € = ? c",
                    antwort: euro * 100,
                    thema: "Mit Geld rechnen",
                    hinweis: "1 € sind 100 c."
                )
            }
            let h = Int.random(in: 1...3, using: &rng)
            return ZahlenAufgabe(
                frage: "\(h) h = ? min",
                antwort: h * 60,
                thema: "Zeitmaße umwandeln",
                hinweis: "1 Stunde sind 60 Minuten."
            )

        case .trab:
            if Bool.random(using: &rng) {
                let euro = Int.random(in: 2...8, using: &rng)
                let cent = [10, 20, 50].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "\(euro) € \(cent) c = ? c",
                    antwort: euro * 100 + cent,
                    thema: "Euro und Cent",
                    hinweis: "1 € sind 100 c."
                )
            }
            let h = Int.random(in: 1...3, using: &rng)
            return ZahlenAufgabe(
                frage: "\(h) h 30 min = ? min",
                antwort: h * 60 + 30,
                thema: "Zeitmaße mit halben Stunden",
                hinweis: "1 Stunde sind 60 Minuten – die 30 Minuten dazuzählen."
            )

        case .galopp:
            if Bool.random(using: &rng) {
                let preis = Int.random(in: 2...4, using: &rng) * 100 + [0, 50].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "Etwas kostet \(preis) c. Du zahlst mit 5 €. Wie viel Cent bekommst du zurück?",
                    antwort: 500 - preis,
                    thema: "Rückgeld berechnen",
                    hinweis: "5 € sind 500 c. Zieh den Preis ab."
                )
            }
            let minuten = [120, 180, 240].randomElement(using: &rng)!
            return ZahlenAufgabe(
                frage: "\(minuten) min = ? h",
                antwort: minuten / 60,
                thema: "Zeitmaße rückwärts",
                hinweis: "60 Minuten sind 1 Stunde."
            )
        }
    }
}
