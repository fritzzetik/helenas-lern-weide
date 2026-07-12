// Sachaufgaben3.swift
// Station 10 (3. Klasse): 🏆 Abschlussturnier – gemischte Sachaufgaben mit Bruno und Daisy.
// Portiert aus dem React-Prototyp (genSach3). Deterministisch, das LLM rechnet NIE.
//
// Abweichung vom Prototyp: Bei der Zwei-Schritt-Geldaufgabe (Galopp) ist der erste Preis
// auf 200–300 c begrenzt, damit das Rückgeld nie negativ wird. (Im Prototyp konnten
// Bürste + Ball zusammen 550 c kosten – bezahlt wurde aber nur mit 5 €.)

import Foundation
import LernWeideCore

public enum Sachaufgaben3Generator {

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 2...5, using: &rng)
                let b = Int.random(in: 2...5, using: &rng)
                return ZahlenAufgabe(
                    frage: "Bruno bekommt am Vormittag \(a) Leckerlis und am Nachmittag \(b). Wie viele sind das zusammen?",
                    antwort: a + b,
                    thema: "Sachaufgaben mit Plus",
                    hinweis: "Zusammen heißt: zusammenzählen."
                )
            }
            let a = Int.random(in: 8...15, using: &rng)
            let b = Int.random(in: 2...6, using: &rng)
            return ZahlenAufgabe(
                frage: "Im Korb liegen \(a) Hundekekse. Bruno frisst \(b) davon. Wie viele bleiben übrig?",
                antwort: a - b,
                thema: "Sachaufgaben mit Minus",
                hinweis: "Übrig bleiben heißt: abziehen."
            )

        case .trab:
            switch Int.random(in: 0...2, using: &rng) {
            case 0:
                let a = Int.random(in: 2...6, using: &rng)
                let b = Int.random(in: 5...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "Bruno bekommt jeden Tag \(a) Leckerlis. Wie viele Leckerlis bekommt er in \(b) Tagen?",
                    antwort: a * b,
                    thema: "Sachaufgaben mit Mal-Rechnungen",
                    hinweis: "Rechne \(a) · \(b)."
                )
            case 1:
                let pferde = [2, 3, 4].randomElement(using: &rng)!
                let gesamt = Int.random(in: 3...9, using: &rng) * pferde
                return ZahlenAufgabe(
                    frage: "\(gesamt) Karotten werden gerecht auf \(pferde) Pferde aufgeteilt. Wie viele Karotten bekommt jedes Pferd?",
                    antwort: gesamt / pferde,
                    thema: "Sachaufgaben mit In-Rechnungen",
                    hinweis: "Rechne \(gesamt) : \(pferde)."
                )
            default:
                let a = Int.random(in: 150...450, using: &rng)
                let b = Int.random(in: 120...400, using: &rng)
                return ZahlenAufgabe(
                    frage: "Beim Spaziergang läuft Bruno zuerst \(a) m, dann noch \(b) m. Wie viele Meter läuft er insgesamt?",
                    antwort: a + b,
                    thema: "Sachaufgaben mit Plus",
                    hinweis: "Insgesamt heißt: zusammenzählen."
                )
            }

        case .galopp:
            switch Int.random(in: 0...2, using: &rng) {
            case 0:
                let proTag = Int.random(in: 4...7, using: &rng)
                let vorrat = proTag * 7 + Int.random(in: 3...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "Im Sackerl sind \(vorrat) Karotten. Daisy frisst jeden Tag \(proTag) Karotten. Wie viele Karotten sind nach einer Woche noch im Sackerl?",
                    antwort: vorrat - proTag * 7,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "Rechne zuerst \(proTag) · 7, dann zieh das von \(vorrat) ab."
                )
            case 1:
                // Preis 1 bewusst nur 200–300 c, damit das Rückgeld nie negativ wird.
                let preis1 = Int.random(in: 2...3, using: &rng) * 100
                let preis2 = [50, 100, 150].randomElement(using: &rng)!
                return ZahlenAufgabe(
                    frage: "Eine Bürste für Daisy kostet \(preis1) c, ein Ball für Bruno \(preis2) c. Du zahlst mit 5 €. Wie viel Cent bekommst du zurück?",
                    antwort: 500 - preis1 - preis2,
                    thema: "Zwei-Schritt-Sachaufgaben mit Geld",
                    hinweis: "Zähl zuerst beide Preise zusammen. 5 € sind 500 c."
                )
            default:
                let runde = Int.random(in: 150...300, using: &rng)
                return ZahlenAufgabe(
                    frage: "Eine Runde um die Koppel ist \(runde) m lang. Daisy galoppiert 3 Runden. Wie viele Meter sind das?",
                    antwort: runde * 3,
                    thema: "Zwei-Schritt-Sachaufgaben",
                    hinweis: "Rechne \(runde) · 3."
                )
            }
        }
    }
}
