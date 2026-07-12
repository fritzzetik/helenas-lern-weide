// MalInBis100000.swift
// Station 4 (4. Klasse): Mal & In mit großen Zahlen.
// Portiert aus dem React-Prototyp (genMalIn100k). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum MalIn100000Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let variante = Int.random(in: 0...2, using: &rng)
        switch gangart {
        case .schritt:
            switch variante {
            case 0:
                let a = Int.random(in: 12...25, using: &rng)
                let b = Int.random(in: 2...4, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · \(b) = ?",
                    antwort: a * b,
                    thema: "Mal-Rechnen mit zweistelligen Zahlen",
                    hinweis: "Zerlege: \(a / 10 * 10) · \(b) und \(a % 10) · \(b), dann zusammenzählen."
                )
            case 1:
                let a = Int.random(in: 12...89, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · 10 = ?",
                    antwort: a * 10,
                    thema: "Mal 10 rechnen",
                    hinweis: "Mal 10 heißt: eine Null anhängen."
                )
            default:
                let a = Int.random(in: 3...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · 100 = ?",
                    antwort: a * 100,
                    thema: "Mal 100 rechnen",
                    hinweis: "Mal 100 heißt: zwei Nullen anhängen."
                )
            }

        case .trab:
            switch variante {
            case 0:
                let a = Int.random(in: 13...48, using: &rng)
                let b = Int.random(in: 3...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · \(b) = ?",
                    antwort: a * b,
                    thema: "Mal-Rechnen mit zweistelligen Zahlen",
                    hinweis: "Zerlege: \(a / 10 * 10) · \(b) plus \(a % 10) · \(b)."
                )
            case 1:
                let b = Int.random(in: 3...9, using: &rng)
                let q = Int.random(in: 11...24, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(b * q) : \(b) = ?",
                    antwort: q,
                    thema: "In-Rechnen über das Einmaleins hinaus",
                    hinweis: "Zerlege \(b * q) in Teile, die du durch \(b) teilen kannst."
                )
            default:
                let a = Int.random(in: 120...890, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · 10 = ?",
                    antwort: a * 10,
                    thema: "Mal 10 mit großen Zahlen",
                    hinweis: "Mal 10 heißt: eine Null anhängen."
                )
            }

        case .galopp:
            switch variante {
            case 0:
                let a = [120, 150, 210, 240, 320, 250].randomElement(using: &rng)!
                let b = Int.random(in: 3...4, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) · \(b) = ?",
                    antwort: a * b,
                    thema: "Mal-Rechnen mit dreistelligen Zahlen",
                    hinweis: "Rechne zuerst \(a / 10) · \(b), dann häng eine Null an."
                )
            case 1:
                let a = Int.random(in: 12...89, using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "\(a.mitTausenderpunkt) : 100 = ?",
                    antwort: a / 100,
                    thema: "Durch 100 dividieren",
                    hinweis: "Durch 100 heißt: zwei Nullen wegnehmen."
                )
            default:
                let b = Int.random(in: 3...9, using: &rng)
                let q = Int.random(in: 3...9, using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "? · \(b) = \((b * q).mitTausenderpunkt)",
                    antwort: q,
                    thema: "Fehlenden Faktor mit Zehnerzahlen finden",
                    hinweis: "Frag dich: WAS mal \(b) ergibt \((b * q).mitTausenderpunkt)? Denk in Zehnern."
                )
            }
        }
    }
}
