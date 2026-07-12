//
//  Stationen.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Turnierpfad-Stationen (IDs identisch zum React-Prototyp → der
//  Fortschritt bleibt kompatibel) und Aufgaben-Generatoren.
//  PRINZIP: Alle Antworten werden hier deterministisch berechnet.
//  Das LLM (Bruno) formuliert nur Erklärungstexte, es rechnet NIE.
//

import Foundation
import LernWeideCore
import MatheWeide

// MARK: - Aufgabe (App-Modell)

/// Eine Aufgabe, wie die Runde sie braucht: Frage, korrekte Antworten
/// (1 oder 2 Eingabefelder, z. B. Ergebnis + Rest) und Metadaten für Bruno.
struct AppAufgabe {
    let frage: String
    let felder: [Feld]              // 1 oder 2 Eingaben
    let thema: String
    let hinweis: String

    struct Feld {
        let label: String           // z. B. "=", "Rest"
        let antwort: Int
    }

    var antwortText: String {
        felder.map { f in f.label == "=" ? "\(f.antwort)" : "\(f.label) \(f.antwort)" }
            .joined(separator: ", ")
    }

    /// Brücke zum BrunoErklaerungsService (dessen MatheAufgabe-Modell).
    func alsMatheAufgabe(gangart: Gangart, generator: @escaping (Gangart) -> AppAufgabe) -> MatheAufgabe {
        MatheAufgabe(
            frage: frage,
            antwortText: antwortText,
            thema: thema,
            hinweis: hinweis,
            gangart: gangart.rawValue,
            neueAehnlicheAufgabe: { g in
                let neu = generator(Gangart(rawValue: g) ?? .schritt)
                return neu.alsMatheAufgabe(gangart: Gangart(rawValue: g) ?? .schritt, generator: generator)
            }
        )
    }
}

// MARK: - Station

struct Station: Identifiable {
    let id: String                  // identisch zum React-Prototyp!
    let emoji: String
    let titel: String
    let sub: String
    let generator: (Gangart) -> AppAufgabe
}

// MARK: - Zufall

@inline(__always) func zufall(_ bereich: ClosedRange<Int>) -> Int {
    Int.random(in: bereich)
}

// MARK: - Generatoren (3. Klasse)

enum Generatoren {

    /// Aufwärmen: Plus & Minus bis 100
    static func warm100(_ g: Gangart) -> AppAufgabe {
        let max = [30, 60, 100][g.rawValue]
        let a = zufall(10...max), b = zufall(1...min(a, max - 1))
        if Bool.random() {
            return AppAufgabe(frage: "\(a) + \(b) = ?", felder: [.init(label: "=", antwort: a + b)],
                              thema: "Plus und Minus bis 100",
                              hinweis: "Rechne zuerst zum nächsten Zehner.")
        }
        return AppAufgabe(frage: "\(a) − \(b) = ?", felder: [.init(label: "=", antwort: a - b)],
                          thema: "Plus und Minus bis 100",
                          hinweis: "Ziehe zuerst bis zum Zehner ab, dann den Rest.")
    }

    /// Zahlenraum 1000: Stellenwerte
    static func zahlenraum1000(_ g: Gangart) -> AppAufgabe {
        let h = zufall(1...9), z = zufall(0...9), e = zufall(0...9)
        let zahl = h * 100 + z * 10 + e
        switch g {
        case .schritt:
            return AppAufgabe(frage: "\(h) H + \(z) Z + \(e) E = ?", felder: [.init(label: "=", antwort: zahl)],
                              thema: "Zahlenraum 1000",
                              hinweis: "H sind Hunderter, Z Zehner, E Einer.")
        case .trab:
            return AppAufgabe(frage: "Wie viele Zehner stecken in \(zahl)?", felder: [.init(label: "=", antwort: zahl / 10)],
                              thema: "Zahlenraum 1000",
                              hinweis: "Streiche die Einerstelle weg.")
        case .galopp:
            let sprung = [10, 100].randomElement()!
            return AppAufgabe(frage: "\(zahl) + \(sprung) = ?", felder: [.init(label: "=", antwort: zahl + sprung)],
                              thema: "Zahlenraum 1000",
                              hinweis: "Nur die betroffene Stelle ändert sich.")
        }
    }

    /// Plus & Minus bis 1000
    static func plusMinus1000(_ g: Gangart) -> AppAufgabe {
        let max = [200, 500, 1000][g.rawValue]
        let a = zufall(100...max), b = zufall(10...min(a - 1, max - 100))
        if Bool.random() {
            return AppAufgabe(frage: "\(a) + \(b) = ?", felder: [.init(label: "=", antwort: a + b)],
                              thema: "Plus und Minus im Zahlenraum 1000",
                              hinweis: "Rechne zuerst die Hunderter, dann Zehner, dann Einer.")
        }
        return AppAufgabe(frage: "\(a) − \(b) = ?", felder: [.init(label: "=", antwort: a - b)],
                          thema: "Plus und Minus im Zahlenraum 1000",
                          hinweis: "Rechne zuerst die Hunderter, dann Zehner, dann Einer.")
    }

    /// Malreihen (Einmaleins)
    static func malreihen(_ g: Gangart) -> AppAufgabe {
        let reihen: [ClosedRange<Int>] = [2...5, 2...9, 3...9]
        let a = zufall(reihen[g.rawValue]), b = zufall(g == .schritt ? 1...5 : 1...10)
        return AppAufgabe(frage: "\(a) · \(b) = ?", felder: [.init(label: "=", antwort: a * b)],
                          thema: "Malreihe von \(a)",
                          hinweis: "Denk an die \(a)er-Reihe.")
    }

    /// In-Rechnungen (Teilen ohne Rest)
    static func inRechnungen(_ g: Gangart) -> AppAufgabe {
        let teiler = zufall(g == .schritt ? 2...5 : 2...9)
        let ergebnis = zufall(g == .galopp ? 3...10 : 1...10)
        let zahl = teiler * ergebnis
        return AppAufgabe(frage: "\(teiler) in \(zahl) = ?", felder: [.init(label: "=", antwort: ergebnis)],
                          thema: "In-Rechnungen",
                          hinweis: "Wie oft passt \(teiler) in \(zahl)? Denk an die \(teiler)er-Reihe.")
    }

    /// Division mit Rest – nutzt den getesteten Generator aus dem Package!
    static func divisionMitRest(_ g: Gangart) -> AppAufgabe {
        var rng = SystemRandomNumberGenerator()
        let a = DivisionsGenerator.neueAufgabe(gangart: g, using: &rng)
        return AppAufgabe(frage: "\(a.dividend) : \(a.divisor) = ?",
                          felder: [.init(label: "=", antwort: a.ergebnis),
                                   .init(label: "Rest", antwort: a.rest)],
                          thema: "Division mit Rest",
                          hinweis: "Such die größte Zahl der \(a.divisor)er-Reihe, die noch in \(a.dividend) passt.")
    }

    /// Längenmaße: m, cm, km
    static func laengen(_ g: Gangart) -> AppAufgabe {
        switch g {
        case .schritt:
            let m = zufall(1...9)
            return AppAufgabe(frage: "\(m) m = ? cm", felder: [.init(label: "=", antwort: m * 100)],
                              thema: "Längenmaße umwandeln", hinweis: "1 m sind 100 cm.")
        case .trab:
            let cm = zufall(2...9) * 100
            return AppAufgabe(frage: "\(cm) cm = ? m", felder: [.init(label: "=", antwort: cm / 100)],
                              thema: "Längenmaße umwandeln", hinweis: "100 cm sind 1 m.")
        case .galopp:
            let km = zufall(1...9)
            return AppAufgabe(frage: "\(km) km = ? m", felder: [.init(label: "=", antwort: km * 1000)],
                              thema: "Längenmaße umwandeln", hinweis: "1 km sind 1.000 m.")
        }
    }

    /// Gewichte: kg, dag, g (österreichisch!)
    static func gewichte(_ g: Gangart) -> AppAufgabe {
        switch g {
        case .schritt:
            let kg = zufall(1...9)
            return AppAufgabe(frage: "\(kg) kg = ? dag", felder: [.init(label: "=", antwort: kg * 100)],
                              thema: "Gewichte umwandeln", hinweis: "1 kg sind 100 dag.")
        case .trab:
            let dag = zufall(1...9)
            return AppAufgabe(frage: "\(dag) dag = ? g", felder: [.init(label: "=", antwort: dag * 10)],
                              thema: "Gewichte umwandeln", hinweis: "1 dag sind 10 g.")
        case .galopp:
            let dag = zufall(2...9) * 100
            return AppAufgabe(frage: "\(dag) dag = ? kg", felder: [.init(label: "=", antwort: dag / 100)],
                              thema: "Gewichte umwandeln", hinweis: "100 dag sind 1 kg.")
        }
    }

    /// Geld & Zeit
    static func geldZeit(_ g: Gangart) -> AppAufgabe {
        switch g {
        case .schritt:
            let e = zufall(1...9)
            return AppAufgabe(frage: "\(e) € = ? c", felder: [.init(label: "=", antwort: e * 100)],
                              thema: "Geld umwandeln", hinweis: "1 € sind 100 Cent.")
        case .trab:
            let h = zufall(1...5)
            return AppAufgabe(frage: "\(h) h = ? min", felder: [.init(label: "=", antwort: h * 60)],
                              thema: "Zeit umwandeln", hinweis: "1 Stunde sind 60 Minuten.")
        case .galopp:
            let preis = zufall(2...9), stueck = zufall(2...5)
            return AppAufgabe(frage: "1 Sackerl Karotten kostet \(preis) €. Was kosten \(stueck) Sackerl?",
                              felder: [.init(label: "=", antwort: preis * stueck)],
                              thema: "Sachaufgaben mit Geld",
                              hinweis: "Rechne \(stueck) · \(preis).")
        }
    }

    /// Abschlussturnier 3. Klasse: Mix aus allem
    static func sach3(_ g: Gangart) -> AppAufgabe {
        [warm100, plusMinus1000, malreihen, inRechnungen, divisionMitRest, laengen, gewichte, geldZeit]
            .randomElement()!(g)
    }
}

// MARK: - Der Turnierpfad (3. Klasse – Stall 4. Klasse folgt)

enum Turnierpfad {
    static let klasse3: [Station] = [
        Station(id: "s3_warm",    emoji: "🐾",  titel: "Aufwärmen: Plus & Minus bis 100", sub: "Wiederholung",              generator: Generatoren.warm100),
        Station(id: "s3_zr",      emoji: "🔢",  titel: "Zahlenraum 1000 entdecken",       sub: "Hunderter, Zehner, Einer",  generator: Generatoren.zahlenraum1000),
        Station(id: "s3_pm",      emoji: "➕",  titel: "Plus & Minus bis 1000",           sub: "rechnen im großen Raum",    generator: Generatoren.plusMinus1000),
        Station(id: "s3_mal",     emoji: "✖️",  titel: "Malreihen sichern",               sub: "das Einmaleins",            generator: Generatoren.malreihen),
        Station(id: "s3_in",      emoji: "🍏",  titel: "In-Rechnungen",                   sub: "Teilen lernen",             generator: Generatoren.inRechnungen),
        Station(id: "s3_rest",    emoji: "➗",  titel: "Division mit Rest",               sub: "z. B. 47 : 5",              generator: Generatoren.divisionMitRest),
        Station(id: "s3_laenge",  emoji: "📏",  titel: "Längenmaße",                      sub: "m, cm, km",                 generator: Generatoren.laengen),
        Station(id: "s3_gewicht", emoji: "⚖️",  titel: "Gewichte",                        sub: "kg, dag, g",                generator: Generatoren.gewichte),
        Station(id: "s3_geld",    emoji: "💶",  titel: "Geld & Zeit",                     sub: "€, c, h, min",              generator: Generatoren.geldZeit),
        Station(id: "s3_final",   emoji: "🏆",  titel: "Abschlussturnier",                sub: "gemischte Sachaufgaben",    generator: Generatoren.sach3)
    ]

    static var alleIDs: [String] { klasse3.map(\.id) }
}
