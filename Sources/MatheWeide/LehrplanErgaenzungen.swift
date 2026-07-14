// LehrplanErgaenzungen.swift
// Stationen, die beim Lehrplan-Abgleich (österreichische Volksschule)
// noch gefehlt haben: Verdoppeln und Geld in der 1. Klasse, Uhr & Zeit
// in der 2., Brüche-Anbahnung in der 3. und der große Block der 4. Klasse
// (Million, schriftliche Division, Brüche, Geometrie, Kommazahlen).
// Alle Antworten werden deterministisch berechnet – das LLM rechnet NIE.

import Foundation
import LernWeideCore

// MARK: - 1. Klasse

/// Verdoppeln & Halbieren im Zahlenraum 20.
public enum VerdoppelnBis20Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 1...5, using: &rng)
            return ZahlenAufgabe(
                frage: "Verdopple \(a)!",
                antwort: a * 2,
                thema: "Verdoppeln bis 10",
                hinweis: "Verdoppeln heißt: \(a) + \(a)."
            )
        case .trab:
            let a = Int.random(in: 6...10, using: &rng)
            return ZahlenAufgabe(
                frage: "Verdopple \(a)!",
                antwort: a * 2,
                thema: "Verdoppeln bis 20",
                hinweis: "Verdoppeln heißt: \(a) + \(a)."
            )
        case .galopp:
            let a = Int.random(in: 1...10, using: &rng) * 2
            return ZahlenAufgabe(
                frage: "Die Hälfte von \(a) = ?",
                antwort: a / 2,
                thema: "Halbieren bis 20",
                hinweis: "Teile \(a) in zwei gleich große Teile."
            )
        }
    }
}

/// Mit Geld umgehen: Euro bis 20 €.
public enum GeldBis20Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 1...5, using: &rng)
            let b = Int.random(in: 1...(10 - a), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) € + \(b) € = ? €",
                antwort: a + b,
                thema: "Mit Euro rechnen",
                hinweis: "Rechne wie mit Zahlen – nur mit € dahinter."
            )
        case .trab:
            let a = Int.random(in: 5...20, using: &rng)
            let b = Int.random(in: 1...(a - 1), using: &rng)
            return ZahlenAufgabe(
                frage: "Du hast \(a) € und kaufst etwas um \(b) €. Wie viele € bleiben?",
                antwort: a - b,
                thema: "Einkaufen mit Euro",
                hinweis: "Ausgeben heißt Minus: \(a) − \(b)."
            )
        case .galopp:
            let preis = Int.random(in: 2...9, using: &rng)
            let schein = preis <= 9 ? 10 : 20
            return ZahlenAufgabe(
                frage: "Das Spielzeug kostet \(preis) €. Du zahlst mit \(schein) €. Wie viele € bekommst du zurück?",
                antwort: schein - preis,
                thema: "Rückgeld",
                hinweis: "Rückgeld heißt Minus: \(schein) − \(preis)."
            )
        }
    }
}

// MARK: - 2. Klasse

/// Uhr & Zeit: Stunden, Minuten, Tage.
public enum UhrZeitGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            return [
                ZahlenAufgabe(frage: "1 Stunde = ? Minuten", antwort: 60, thema: "Zeit-Maße", hinweis: "Der große Zeiger braucht 60 Minuten für eine Runde."),
                ZahlenAufgabe(frage: "1 Tag = ? Stunden", antwort: 24, thema: "Zeit-Maße", hinweis: "Ein ganzer Tag mit Tag und Nacht hat 24 Stunden."),
                ZahlenAufgabe(frage: "1 Woche = ? Tage", antwort: 7, thema: "Zeit-Maße", hinweis: "Montag bis Sonntag – zähl nach!"),
                ZahlenAufgabe(frage: "1 Minute = ? Sekunden", antwort: 60, thema: "Zeit-Maße", hinweis: "Eine Minute hat 60 Sekunden."),
            ].randomElement(using: &rng)!
        case .trab:
            return [
                ZahlenAufgabe(frage: "Eine halbe Stunde = ? Minuten", antwort: 30, thema: "Halbe und Viertelstunden", hinweis: "Die Hälfte von 60."),
                ZahlenAufgabe(frage: "Eine Viertelstunde = ? Minuten", antwort: 15, thema: "Halbe und Viertelstunden", hinweis: "60 geteilt in 4 Teile."),
                ZahlenAufgabe(frage: "Eine Dreiviertelstunde = ? Minuten", antwort: 45, thema: "Halbe und Viertelstunden", hinweis: "Drei mal eine Viertelstunde: 15 + 15 + 15."),
            ].randomElement(using: &rng)!
        case .galopp:
            if Bool.random(using: &rng) {
                let von = Int.random(in: 1...9, using: &rng)
                let bis = Int.random(in: (von + 1)...min(von + 5, 12), using: &rng)
                return ZahlenAufgabe(
                    frage: "Von \(von) Uhr bis \(bis) Uhr sind es ? Stunden",
                    antwort: bis - von,
                    thema: "Zeitspannen",
                    hinweis: "Zähl die vollen Stunden von \(von) bis \(bis)."
                )
            }
            let a = Int.random(in: 1...5, using: &rng) * 5
            let b = Int.random(in: 1...5, using: &rng) * 5
            return ZahlenAufgabe(
                frage: "\(a) Minuten + \(b) Minuten = ? Minuten",
                antwort: a + b,
                thema: "Mit Minuten rechnen",
                hinweis: "Rechne wie mit Zahlen – nur mit Minuten."
            )
        }
    }
}

// MARK: - 3. Klasse

/// Hälfte & Viertel: Brüche anbahnen im Zahlenraum 1000.
public enum HaelfteViertelGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 6...50, using: &rng) * 2
            return ZahlenAufgabe(
                frage: "Die Hälfte von \(a) = ?",
                antwort: a / 2,
                thema: "Halbieren",
                hinweis: "Teile \(a) in zwei gleich große Teile."
            )
        case .trab:
            let a = Int.random(in: 3...25, using: &rng) * 4
            return ZahlenAufgabe(
                frage: "Ein Viertel von \(a) = ?",
                antwort: a / 4,
                thema: "Vierteln",
                hinweis: "Halbiere \(a) – und halbiere dann noch einmal."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 11...49, using: &rng) * 20
                return ZahlenAufgabe(
                    frage: "Die Hälfte von \(a) = ?",
                    antwort: a / 2,
                    thema: "Halbieren im Zahlenraum 1000",
                    hinweis: "Halbiere zuerst die Hunderter, dann die Zehner."
                )
            }
            let a = Int.random(in: 2...12, using: &rng) * 80
            return ZahlenAufgabe(
                frage: "Ein Viertel von \(a) = ?",
                antwort: a / 4,
                thema: "Vierteln im Zahlenraum 1000",
                hinweis: "Zweimal halbieren – das ist ein Viertel."
            )
        }
    }
}

// MARK: - 4. Klasse

/// Bis zur Million: Stellenwerte und Sprünge im Zahlenraum 1.000.000.
public enum MillionGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let ht = Int.random(in: 1...9, using: &rng)
            let zt = Int.random(in: 1...9, using: &rng)
            let t = Int.random(in: 1...9, using: &rng)
            let zahl = ht * 100_000 + zt * 10_000 + t * 1000
            return ZahlenAufgabe(
                frage: "\((ht * 100_000).mitTausenderpunkt) + \((zt * 10_000).mitTausenderpunkt) + \((t * 1000).mitTausenderpunkt) = ?",
                antwort: zahl,
                thema: "Große Zahlen zusammensetzen",
                hinweis: "Hunderttausender, Zehntausender und Tausender einfach nebeneinander."
            )
        case .trab:
            let t = Int.random(in: 12...98, using: &rng) * 10
            return ZahlenAufgabe(
                frage: "Wie viele Tausender stecken in \((t * 1000).mitTausenderpunkt)?",
                antwort: t,
                thema: "Stellenwert verstehen",
                hinweis: "Streich die letzten drei Nullen weg."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let n = Int.random(in: 12...89, using: &rng) * 10_000 + Int.random(in: 1...9, using: &rng) * 1000
                return ZahlenAufgabe(
                    frage: "\(n.mitTausenderpunkt) + 10.000 = ?",
                    antwort: n + 10_000,
                    thema: "Zehntausendersprünge",
                    hinweis: "Nur die Zehntausender-Stelle ändert sich."
                )
            }
            return ZahlenAufgabe(
                frage: "999.999 + 1 = ?",
                antwort: 1_000_000,
                thema: "Die Million!",
                hinweis: "Alle Stellen kippen um – wie ein Kilometerzähler."
            )
        }
    }
}

/// Schriftliche Division: große Dividenden, einstelliger Divisor, mit Rest.
/// Anders als in der 3. Klasse darf der Rest hier auch 0 sein.
public enum SchriftlichDividierenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> DivisionsAufgabe {
        let divisor: Int
        let ergebnis: Int
        switch gangart {
        case .schritt:
            divisor = [2, 3, 4, 5].randomElement(using: &rng)!
            ergebnis = Int.random(in: 21...99, using: &rng)
        case .trab:
            divisor = Int.random(in: 3...9, using: &rng)
            ergebnis = Int.random(in: 51...199, using: &rng)
        case .galopp:
            divisor = Int.random(in: 3...9, using: &rng)
            ergebnis = Int.random(in: 201...999, using: &rng)
        }
        let rest = Int.random(in: 0...(divisor - 1), using: &rng)
        return DivisionsAufgabe(dividend: divisor * ergebnis + rest, divisor: divisor)
    }
}

/// Brüche & Teile: Drittel, Sechstel, Achtel – und mehrere Teile davon.
public enum BruecheGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let teile = [2, 4].randomElement(using: &rng)!
            let a = Int.random(in: 3...25, using: &rng) * teile
            let name = teile == 2 ? "Die Hälfte" : "Ein Viertel"
            return ZahlenAufgabe(
                frage: "\(name) von \(a) = ?",
                antwort: a / teile,
                thema: "Hälfte und Viertel",
                hinweis: "Teile \(a) in \(teile) gleich große Teile."
            )
        case .trab:
            let teile = [3, 6, 8].randomElement(using: &rng)!
            let a = Int.random(in: 2...12, using: &rng) * teile
            let name = teile == 3 ? "Ein Drittel" : teile == 6 ? "Ein Sechstel" : "Ein Achtel"
            return ZahlenAufgabe(
                frage: "\(name) von \(a) = ?",
                antwort: a / teile,
                thema: "Bruchteile",
                hinweis: "Teile \(a) in \(teile) gleich große Teile."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 3...20, using: &rng) * 4
                return ZahlenAufgabe(
                    frage: "Drei Viertel von \(a) = ?",
                    antwort: a / 4 * 3,
                    thema: "Mehrere Bruchteile",
                    hinweis: "Rechne zuerst ein Viertel (\(a / 4)) – und nimm es dreimal."
                )
            }
            let a = Int.random(in: 4...30, using: &rng) * 3
            return ZahlenAufgabe(
                frage: "Zwei Drittel von \(a) = ?",
                antwort: a / 3 * 2,
                thema: "Mehrere Bruchteile",
                hinweis: "Rechne zuerst ein Drittel (\(a / 3)) – und nimm es zweimal."
            )
        }
    }
}

/// Umfang & Fläche von Quadrat und Rechteck.
public enum UmfangFlaecheGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Ein Quadrat hat die Seite \(a) cm. Wie groß ist sein Umfang in cm?",
                antwort: 4 * a,
                thema: "Umfang des Quadrats",
                hinweis: "Vier gleich lange Seiten: 4 · \(a)."
            )
        case .trab:
            let a = Int.random(in: 4...12, using: &rng)
            let b = Int.random(in: 2...(a - 1), using: &rng)
            return ZahlenAufgabe(
                frage: "Ein Rechteck ist \(a) cm lang und \(b) cm breit. Wie groß ist sein Umfang in cm?",
                antwort: 2 * (a + b),
                thema: "Umfang des Rechtecks",
                hinweis: "Länge plus Breite – und das Ganze zweimal: 2 · (\(a) + \(b))."
            )
        case .galopp:
            let a = Int.random(in: 4...12, using: &rng)
            let b = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Ein Rechteck ist \(a) cm lang und \(b) cm breit. Wie groß ist seine Fläche in cm²?",
                antwort: a * b,
                thema: "Fläche des Rechtecks",
                hinweis: "Fläche heißt Länge mal Breite: \(a) · \(b)."
            )
        }
    }
}

/// Komma, Geld & Maße: Kommazahlen über Umwandlungen begreifen.
public enum KommaGeldGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let euro = Int.random(in: 1...9, using: &rng)
            let zehner = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(euro),\(zehner)0 € = ? c",
                antwort: euro * 100 + zehner * 10,
                thema: "Kommazahlen bei Geld",
                hinweis: "Vor dem Komma stehen Euro (je 100 c), dahinter die Cent."
            )
        case .trab:
            if Bool.random(using: &rng) {
                let km = Int.random(in: 1...9, using: &rng)
                let rest = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(km),\(rest) km = ? m",
                    antwort: km * 1000 + rest * 100,
                    thema: "Kommazahlen bei Längen",
                    hinweis: "1 km sind 1.000 m – die Kommastelle sind Hunderter-Meter."
                )
            }
            let m = Int.random(in: 1...9, using: &rng)
            let cm = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(m),\(cm)0 m = ? cm",
                antwort: m * 100 + cm * 10,
                thema: "Kommazahlen bei Längen",
                hinweis: "1 m sind 100 cm – die Kommastellen sind die Zentimeter."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let t = Int.random(in: 1...9, using: &rng)
                let rest = Int.random(in: 1...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(t),\(rest) t = ? kg",
                    antwort: t * 1000 + rest * 100,
                    thema: "Kommazahlen bei Gewichten",
                    hinweis: "1 t sind 1.000 kg – die Kommastelle sind Hunderter-Kilo."
                )
            }
            let kg = Int.random(in: 1...9, using: &rng)
            let dag = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(kg) kg \(dag * 10) dag = ? dag",
                antwort: kg * 100 + dag * 10,
                thema: "Gemischte Maße",
                hinweis: "1 kg sind 100 dag – dann die dag dazuzählen."
            )
        }
    }
}
