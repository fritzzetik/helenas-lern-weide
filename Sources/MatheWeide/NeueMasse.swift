// NeueMasse.swift
// Station 5 (4. Klasse): Neue Maße – Tonnen, Millimeter, Sekunden.
// Portiert aus dem React-Prototyp (genMasseNeu). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum NeueMasseGenerator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let variante = Int.random(in: 0...2, using: &rng)
        switch gangart {
        case .schritt:
            switch variante {
            case 0:
                let t = Int.random(in: 1...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(t) t = ? kg",
                    antwort: t * 1000,
                    thema: "Tonnen und Kilogramm",
                    hinweis: "1 t sind 1000 kg. Daisy wiegt ungefähr eine halbe Tonne!"
                )
            case 1:
                let cm = Int.random(in: 2...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(cm) cm = ? mm",
                    antwort: cm * 10,
                    thema: "Zentimeter und Millimeter",
                    hinweis: "1 cm sind 10 mm."
                )
            default:
                let minuten = Int.random(in: 1...4, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(minuten) min = ? s",
                    antwort: minuten * 60,
                    thema: "Minuten und Sekunden",
                    hinweis: "1 Minute sind 60 Sekunden."
                )
            }

        case .trab:
            switch variante {
            case 0:
                let t = Int.random(in: 1...4, using: &rng)
                let kg = [200, 500, 250, 750].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "\(t) t \(kg) kg = ? kg",
                    antwort: t * 1000 + kg,
                    thema: "Tonnen und Kilogramm",
                    hinweis: "1 t sind 1000 kg – dann die restlichen kg dazuzählen."
                )
            case 1:
                let cm = Int.random(in: 2...9, using: &rng)
                let mm = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(cm) cm \(mm) mm = ? mm",
                    antwort: cm * 10 + mm,
                    thema: "Zentimeter und Millimeter",
                    hinweis: "1 cm sind 10 mm – dann die restlichen mm dazuzählen."
                )
            default:
                let minuten = Int.random(in: 1...3, using: &rng)
                let s = [15, 30, 45].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "\(minuten) min \(s) s = ? s",
                    antwort: minuten * 60 + s,
                    thema: "Minuten und Sekunden",
                    hinweis: "1 Minute sind 60 Sekunden – dann die restlichen Sekunden dazuzählen."
                )
            }

        case .galopp:
            switch variante {
            case 0:
                let t = Int.random(in: 2...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\((t * 1000).mitTausenderpunkt) kg = ? t",
                    antwort: t,
                    thema: "Kilogramm rückwärts in Tonnen",
                    hinweis: "1000 kg sind 1 t."
                )
            case 1:
                let cm = Int.random(in: 3...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(cm * 10) mm = ? cm",
                    antwort: cm,
                    thema: "Millimeter rückwärts",
                    hinweis: "10 mm sind 1 cm."
                )
            default:
                let minuten = Int.random(in: 2...4, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(minuten * 60) s = ? min",
                    antwort: minuten,
                    thema: "Sekunden rückwärts",
                    hinweis: "60 Sekunden sind 1 Minute."
                )
            }
        }
    }
}
