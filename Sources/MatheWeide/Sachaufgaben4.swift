// Sachaufgaben4.swift
// Station 6 (4. Klasse): 🏆 Abschlussturnier – gemischte Sachaufgaben mit Bruno und Daisy.
// Portiert aus dem React-Prototyp (genSach4). Deterministisch, das LLM rechnet NIE.

import Foundation
import LernWeideCore

public enum Sachaufgaben4Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 15...35, using: &rng)
                let b = Int.random(in: 3...6, using: &rng)
                return ZahlenAufgabe(
                    frage: "Ein Sack Pferdefutter wiegt \(a) kg. Wie viel wiegen \(b) Säcke?",
                    antwort: a * b,
                    thema: "Sachaufgaben mit Mal",
                    hinweis: "Rechne \(a) · \(b)."
                )
            }
            let a = Int.random(in: 12...45, using: &rng) * 100
            let b = Int.random(in: 11...40, using: &rng) * 100
            return ZahlenAufgabe(
                frage: "Der Reiterhof kauft Heu um \(a.mitTausenderpunkt) c und Stroh um \(b.mitTausenderpunkt) c. Wie viel Cent kostet das zusammen?",
                antwort: a + b,
                thema: "Sachaufgaben mit Plus",
                hinweis: "Zusammen heißt: zusammenzählen."
            )

        case .trab:
            switch Int.random(in: 0...2, using: &rng) {
            case 0:
                let runde = Int.random(in: 350...850, using: &rng)
                return ZahlenAufgabe(
                    frage: "Eine große Runde um die Koppel ist \(runde) m. Daisy läuft sie 4-mal. Wie viele Meter sind das?",
                    antwort: runde * 4,
                    thema: "Sachaufgaben mit Mal",
                    hinweis: "Rechne \(runde) · 4 – zerlege in Hunderter und Rest."
                )
            case 1:
                let kg = Int.random(in: 4...8, using: &rng)
                return ZahlenAufgabe(
                    frage: "Daisy frisst \(kg) kg Heu am Tag. Wie viele kg sind das in 2 Wochen?",
                    antwort: kg * 14,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "2 Wochen sind 14 Tage."
                )
            default:
                let preis = Int.random(in: 45...95, using: &rng) * 100
                return ZahlenAufgabe(
                    frage: "Ein neuer Sattel kostet \(preis.mitTausenderpunkt) c. Du zahlst mit 100 €. Wie viel Cent bekommst du zurück?",
                    antwort: 10000 - preis,
                    thema: "Sachaufgaben mit Geld",
                    hinweis: "100 € sind 10.000 c. Zieh den Preis ab."
                )
            }

        case .galopp:
            switch Int.random(in: 0...2, using: &rng) {
            case 0:
                let proTag = Int.random(in: 5...8, using: &rng)
                let vorrat = proTag * 14 + Int.random(in: 5...20, using: &rng)
                return ZahlenAufgabe(
                    frage: "Im Lager sind \(vorrat) kg Heu. Daisy frisst \(proTag) kg am Tag. Wie viele kg bleiben nach 2 Wochen übrig?",
                    antwort: vorrat - proTag * 14,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "Rechne zuerst \(proTag) · 14, dann zieh das von \(vorrat) ab."
                )
            case 1:
                let a = Int.random(in: 180...420, using: &rng)
                return ZahlenAufgabe(
                    frage: "Bruno läuft jeden Tag ungefähr \(a) m beim Gassigehen – und das 2-mal am Tag. Wie viele Meter sind das in einer Woche?",
                    antwort: a * 2 * 7,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "Rechne zuerst \(a) · 2 für einen Tag, dann mal 7."
                )
            default:
                let saecke = Int.random(in: 3...6, using: &rng)
                let proSack = Int.random(in: 15...25, using: &rng)
                let geliefert = saecke * proSack + Int.random(in: 10...30, using: &rng)
                return ZahlenAufgabe(
                    frage: "Der Hof bestellt \(saecke) Säcke Futter zu je \(proSack) kg. Geliefert werden aber \(geliefert) kg. Wie viele kg sind das zu viel?",
                    antwort: geliefert - saecke * proSack,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "Rechne zuerst \(saecke) · \(proSack), dann den Unterschied."
                )
            }
        }
    }
}
