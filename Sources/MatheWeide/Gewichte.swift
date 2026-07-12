// Gewichte.swift
// Station 8 (3. Klasse): Gewichte – mit dag, wie in Österreich üblich!
// Portiert aus dem React-Prototyp (genGewichte). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum GewichteGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            if Bool.random(using: &rng) {
                let kg = Int.random(in: 1...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(kg) kg = ? dag",
                    antwort: kg * 100,
                    thema: "Gewichte umwandeln",
                    hinweis: "1 kg sind 100 dag."
                )
            }
            let dag = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(dag) dag = ? g",
                antwort: dag * 10,
                thema: "Gewichte umwandeln",
                hinweis: "1 dag sind 10 g."
            )

        case .trab:
            if Bool.random(using: &rng) {
                let kg = Int.random(in: 2...9, using: &rng)
                let dag = [20, 50, 25, 75].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "\(kg) kg \(dag) dag = ? dag",
                    antwort: kg * 100 + dag,
                    thema: "Gewichte umwandeln",
                    hinweis: "1 kg sind 100 dag – dann die restlichen dag dazuzählen."
                )
            }
            let dag = Int.random(in: 2...9, using: &rng)
            let g = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(dag) dag \(g) g = ? g",
                antwort: dag * 10 + g,
                thema: "Gewichte umwandeln",
                hinweis: "1 dag sind 10 g – dann die restlichen g dazuzählen."
            )

        case .galopp:
            if Bool.random(using: &rng) {
                let kg = Int.random(in: 2...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(kg * 100) dag = ? kg",
                    antwort: kg,
                    thema: "Gewichte rückwärts",
                    hinweis: "100 dag sind 1 kg."
                )
            }
            let dag = Int.random(in: 3...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(dag * 10) g = ? dag",
                antwort: dag,
                thema: "Gramm rückwärts in dag",
                hinweis: "10 g sind 1 dag."
            )
        }
    }
}
