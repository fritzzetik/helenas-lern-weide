// Klasse1und2.swift
// Aufgabengeneratoren für die 1. und 2. Klasse Volksschule
// (österreichischer Lehrplan). Kurze Runden mit 5 Aufgaben.
// Alle Antworten werden deterministisch berechnet – das LLM rechnet NIE.

import Foundation
import LernWeideCore

// MARK: - 1. Klasse (Zahlenraum 20)

/// Zählen & Zahlen bis 20: Nachbarzahlen und Weiterzählen.
public enum ZaehlenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let n = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Welche Zahl kommt direkt nach \(n)?",
                antwort: n + 1,
                thema: "Zählen bis 10",
                hinweis: "Zähl einfach laut weiter: \(n), …"
            )
        case .trab:
            let n = Int.random(in: 2...15, using: &rng)
            return ZahlenAufgabe(
                frage: "Welche Zahl kommt direkt vor \(n)?",
                antwort: n - 1,
                thema: "Zählen bis 20",
                hinweis: "Zähl einen Schritt zurück."
            )
        case .galopp:
            let n = Int.random(in: 1...17, using: &rng)
            return ZahlenAufgabe(
                frage: "Zähle weiter: \(n), \(n + 1), ?",
                antwort: n + 2,
                thema: "Weiterzählen bis 20",
                hinweis: "Immer eins dazu."
            )
        }
    }
}

/// Zerlegen & Ergänzen: Wie viel fehlt?
public enum ZerlegenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let ziel = Int.random(in: 4...6, using: &rng)
            let a = Int.random(in: 1...(ziel - 1), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + ? = \(ziel)",
                antwort: ziel - a,
                thema: "Ergänzen bis 6",
                hinweis: "Zähl von \(a) hinauf bis \(ziel) – wie viele Schritte?"
            )
        case .trab:
            let a = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + ? = 10",
                antwort: 10 - a,
                thema: "Ergänzen auf 10",
                hinweis: "Die Zehnerfreunde! \(a) und \(10 - a) gehören zusammen."
            )
        case .galopp:
            let a = Int.random(in: 11...19, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + ? = 20",
                antwort: 20 - a,
                thema: "Ergänzen auf 20",
                hinweis: "Schau auf die Einer: Wie viel fehlt auf den vollen Zwanziger?"
            )
        }
    }
}

/// Plus & Minus bis 10.
public enum PlusMinus10Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 1...5, using: &rng)
            let b = Int.random(in: 1...(6 - a), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + \(b) = ?",
                antwort: a + b,
                thema: "Plus bis 6",
                hinweis: "Zähl von \(a) einfach \(b) weiter."
            )
        case .trab:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 2...9, using: &rng)
                let b = Int.random(in: 1...(10 - a), using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus bis 10",
                    hinweis: "Zähl von der größeren Zahl weiter."
                )
            }
            let a = Int.random(in: 3...10, using: &rng)
            let b = Int.random(in: 1...(a - 1), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus bis 10",
                hinweis: "Zähl von \(a) rückwärts."
            )
        case .galopp:
            let a = Int.random(in: 1...4, using: &rng)
            let b = Int.random(in: 1...3, using: &rng)
            let c = Int.random(in: 1...(10 - a - b), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + \(b) + \(c) = ?",
                antwort: a + b + c,
                thema: "Plus mit drei Zahlen",
                hinweis: "Rechne zuerst \(a) + \(b), dann kommt \(c) dazu."
            )
        }
    }
}

/// Zahlenraum 20: Zehner und Einer kennenlernen.
public enum Zahlenraum20Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let e = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "10 + \(e) = ?",
                antwort: 10 + e,
                thema: "Zehner und Einer",
                hinweis: "Ein voller Zehner und \(e) Einer."
            )
        case .trab:
            let e = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "1 Z + \(e) E = ?",
                antwort: 10 + e,
                thema: "Zehner und Einer",
                hinweis: "Z ist der Zehner, E sind die Einer."
            )
        case .galopp:
            let n = 10 + Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Wie viele Einer hat die Zahl \(n)?",
                antwort: n - 10,
                thema: "Stellenwert bis 20",
                hinweis: "Der Zehner ist voll – was bleibt übrig?"
            )
        }
    }
}

/// Plus & Minus bis 20 – der Zehnerübergang kommt im Galopp.
public enum PlusMinus20Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = 10 + Int.random(in: 1...5, using: &rng)
            let b = Int.random(in: 1...(20 - a), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + \(b) = ?",
                antwort: a + b,
                thema: "Plus bis 20 ohne Übergang",
                hinweis: "Nur die Einer ändern sich."
            )
        case .trab:
            let a = 10 + Int.random(in: 3...9, using: &rng)
            let b = Int.random(in: 1...(a - 11), using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus bis 20 ohne Übergang",
                hinweis: "Nur die Einer ändern sich."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 5...9, using: &rng)
                let b = Int.random(in: (11 - a)...9, using: &rng)
                return ZahlenAufgabe(
                    frage: "\(a) + \(b) = ?",
                    antwort: a + b,
                    thema: "Plus mit Zehnerübergang",
                    hinweis: "Rechne zuerst bis 10, dann den Rest dazu."
                )
            }
            let a = Int.random(in: 11...18, using: &rng)
            let b = Int.random(in: (a - 9)...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus mit Zehnerübergang",
                hinweis: "Zieh zuerst bis zum Zehner ab, dann den Rest."
            )
        }
    }
}

/// Abschlussturnier 1. Klasse: kleine Sachaufgaben mit Bruno und Daisy.
public enum Sachaufgaben1Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 2...5, using: &rng)
            let b = Int.random(in: 1...4, using: &rng)
            return ZahlenAufgabe(
                frage: "Bruno hat \(a) Knochen und bekommt \(b) dazu. Wie viele hat er jetzt?",
                antwort: a + b,
                thema: "Sachaufgabe: dazubekommen",
                hinweis: "„Dazu“ heißt Plus: \(a) + \(b)."
            )
        case .trab:
            let b = Int.random(in: 5...10, using: &rng)
            let a = Int.random(in: 1...(b - 1), using: &rng)
            return ZahlenAufgabe(
                frage: "Daisy hat \(b) Äpfel und frisst \(a) davon. Wie viele bleiben übrig?",
                antwort: b - a,
                thema: "Sachaufgabe: wegnehmen",
                hinweis: "„Übrig bleiben“ heißt Minus: \(b) − \(a)."
            )
        case .galopp:
            let a = Int.random(in: 5...9, using: &rng)
            let b = Int.random(in: 3...8, using: &rng)
            let c = Int.random(in: 1...(min(a + b - 1, 9)), using: &rng)
            return ZahlenAufgabe(
                frage: "Auf der Weide stehen \(a) Hühner und \(b) Gänse. \(c) laufen weg. Wie viele Tiere bleiben?",
                antwort: a + b - c,
                thema: "Sachaufgabe mit zwei Schritten",
                hinweis: "Zuerst alle zusammenzählen (\(a) + \(b)), dann \(c) wegnehmen."
            )
        }
    }
}

// MARK: - 2. Klasse (Zahlenraum 100, kleines Einmaleins)

/// Zahlenraum 100 entdecken: Zehner, Einer, Nachbarzehner.
public enum Zahlenraum100Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let z = Int.random(in: 2...9, using: &rng)
            let e = Int.random(in: 1...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(z) Z + \(e) E = ?",
                antwort: z * 10 + e,
                thema: "Zehner und Einer",
                hinweis: "Z sind Zehner, E sind Einer – einfach nebeneinander."
            )
        case .trab:
            let n = Int.random(in: 21...89, using: &rng)
            let nicht = n % 10 == 0 ? n + Int.random(in: 1...9, using: &rng) : n
            return ZahlenAufgabe(
                frage: "Welcher Zehner kommt direkt nach \(nicht)?",
                antwort: ((nicht / 10) + 1) * 10,
                thema: "Nachbarzehner finden",
                hinweis: "Der nächste Zehner ist die nächste runde Zahl."
            )
        case .galopp:
            let n = Int.random(in: 15...85, using: &rng)
            if Bool.random(using: &rng) {
                return ZahlenAufgabe(
                    frage: "\(n) + 10 = ?",
                    antwort: n + 10,
                    thema: "Zehnersprünge",
                    hinweis: "Nur der Zehner ändert sich."
                )
            }
            return ZahlenAufgabe(
                frage: "\(n) − 10 = ?",
                antwort: n - 10,
                thema: "Zehnersprünge",
                hinweis: "Nur der Zehner ändert sich."
            )
        }
    }
}

/// Plus & Minus bis 100 ohne Übertrag.
public enum PlusMinusOhneUebertragGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 2...7, using: &rng) * 10
            let b = Int.random(in: 1...(9 - a / 10), using: &rng) * 10
            return ZahlenAufgabe(
                frage: "\(a) + \(b) = ?",
                antwort: a + b,
                thema: "Glatte Zehner",
                hinweis: "Rechne mit den Zehnern – die Null bleibt."
            )
        case .trab:
            let az = Int.random(in: 2...6, using: &rng)
            let ae = Int.random(in: 1...5, using: &rng)
            let bz = Int.random(in: 1...(8 - az), using: &rng)
            let be = Int.random(in: 1...(9 - ae), using: &rng)
            let a = az * 10 + ae
            let b = bz * 10 + be
            return ZahlenAufgabe(
                frage: "\(a) + \(b) = ?",
                antwort: a + b,
                thema: "Plus ohne Übertrag",
                hinweis: "Zehner zu Zehnern, Einer zu Einern."
            )
        case .galopp:
            let az = Int.random(in: 4...9, using: &rng)
            let ae = Int.random(in: 5...9, using: &rng)
            let bz = Int.random(in: 1...(az - 1), using: &rng)
            let be = Int.random(in: 1...(ae - 1), using: &rng)
            let a = az * 10 + ae
            let b = bz * 10 + be
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus ohne Übertrag",
                hinweis: "Zehner minus Zehner, Einer minus Einer."
            )
        }
    }
}

/// Plus & Minus bis 100 mit Übertrag (Zehnerüberschreitung).
public enum PlusMinus100MitUebertragGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 15...45, using: &rng)
            let b = Int.random(in: 6...9, using: &rng)
            return ZahlenAufgabe(
                frage: "\(a) + \(b) = ?",
                antwort: a + b,
                thema: "Plus über den Zehner",
                hinweis: "Rechne zuerst bis zum nächsten Zehner, dann den Rest."
            )
        case .trab:
            let ae = Int.random(in: 1...4, using: &rng)
            let be = Int.random(in: (ae + 1)...9, using: &rng)
            let a = Int.random(in: 3...8, using: &rng) * 10 + ae
            let b = Int.random(in: 1...(a / 10 - 1), using: &rng) * 10 + be
            return ZahlenAufgabe(
                frage: "\(a) − \(b) = ?",
                antwort: a - b,
                thema: "Minus über den Zehner",
                hinweis: "Zieh zuerst bis zum Zehner ab, dann den Rest."
            )
        case .galopp:
            let b = Int.random(in: 25...85, using: &rng)
            let nicht = b % 10 == 0 ? b + 3 : b
            return ZahlenAufgabe(
                frage: "\(nicht) + ? = 100",
                antwort: 100 - nicht,
                thema: "Ergänzen auf 100",
                hinweis: "Zuerst zum nächsten Zehner, dann die Zehner bis 100."
            )
        }
    }
}

/// Kleine Malreihen: 2er, 5er, 10er – im Galopp 3er und 4er.
public enum KleineMalreihenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let reihe: Int
        switch gangart {
        case .schritt: reihe = 2
        case .trab: reihe = [5, 10].randomElement(using: &rng)!
        case .galopp: reihe = [3, 4].randomElement(using: &rng)!
        }
        let b = Int.random(in: 1...10, using: &rng)
        return ZahlenAufgabe(
            frage: "\(reihe) · \(b) = ?",
            antwort: reihe * b,
            thema: "Malreihe von \(reihe)",
            hinweis: "Denk an die \(reihe)er-Reihe: immer \(reihe) dazu."
        )
    }
}

/// Erste In-Rechnungen mit den kleinen Reihen.
public enum ErsteInRechnungenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        let teiler: Int
        switch gangart {
        case .schritt: teiler = 2
        case .trab: teiler = [5, 10].randomElement(using: &rng)!
        case .galopp: teiler = [3, 4].randomElement(using: &rng)!
        }
        let ergebnis = Int.random(in: 1...10, using: &rng)
        let zahl = teiler * ergebnis
        return ZahlenAufgabe(
            frage: "\(teiler) in \(zahl) = ?",
            antwort: ergebnis,
            thema: "In-Rechnungen",
            hinweis: "Wie oft passt \(teiler) in \(zahl)? Denk an die \(teiler)er-Reihe."
        )
    }
}

/// Verdoppeln & Halbieren.
public enum VerdoppelnHalbierenGenerator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let a = Int.random(in: 2...10, using: &rng)
            return ZahlenAufgabe(
                frage: "Verdopple \(a)!",
                antwort: a * 2,
                thema: "Verdoppeln",
                hinweis: "Verdoppeln heißt: \(a) + \(a)."
            )
        case .trab:
            let a = Int.random(in: 2...10, using: &rng) * 2
            return ZahlenAufgabe(
                frage: "Die Hälfte von \(a) = ?",
                antwort: a / 2,
                thema: "Halbieren",
                hinweis: "Teile \(a) in zwei gleich große Teile."
            )
        case .galopp:
            if Bool.random(using: &rng) {
                let a = Int.random(in: 2...5, using: &rng) * 10
                return ZahlenAufgabe(
                    frage: "Verdopple \(a)!",
                    antwort: a * 2,
                    thema: "Verdoppeln mit Zehnern",
                    hinweis: "Verdopple die Zehner – die Null bleibt."
                )
            }
            let a = Int.random(in: 2...5, using: &rng) * 20
            return ZahlenAufgabe(
                frage: "Die Hälfte von \(a) = ?",
                antwort: a / 2,
                thema: "Halbieren mit Zehnern",
                hinweis: "Halbiere die Zehner – die Null bleibt."
            )
        }
    }
}

/// Abschlussturnier 2. Klasse: Sachaufgaben bis 100.
public enum Sachaufgaben2Generator {
    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch gangart {
        case .schritt:
            let preis = Int.random(in: 2...9, using: &rng)
            return ZahlenAufgabe(
                frage: "Ein Sackerl Karotten kostet \(preis) €. Was kosten 2 Sackerl?",
                antwort: preis * 2,
                thema: "Sachaufgabe mit Geld",
                hinweis: "2 Sackerl heißt: \(preis) + \(preis)."
            )
        case .trab:
            let a = Int.random(in: 25...60, using: &rng)
            let b = Int.random(in: 10...(95 - a), using: &rng)
            return ZahlenAufgabe(
                frage: "Im Stall liegen \(a) Heuballen, es kommen \(b) dazu. Wie viele sind es jetzt?",
                antwort: a + b,
                thema: "Sachaufgabe: dazubekommen",
                hinweis: "„Dazu“ heißt Plus: \(a) + \(b)."
            )
        case .galopp:
            let preis = Int.random(in: 12...45, using: &rng)
            let bezahlt = ((preis / 10) + 1) * 10 + [0, 10].randomElement(using: &rng)!
            return ZahlenAufgabe(
                frage: "Das Putzzeug für Daisy kostet \(preis) €. Du zahlst mit \(bezahlt) €. Wie viel bekommst du zurück?",
                antwort: bezahlt - preis,
                thema: "Sachaufgabe: Rückgeld",
                hinweis: "Rückgeld heißt Minus: \(bezahlt) − \(preis)."
            )
        }
    }
}
