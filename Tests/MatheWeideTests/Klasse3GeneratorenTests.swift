// Klasse3GeneratorenTests.swift
// Tests für alle ZahlenAufgabe-Generatoren der 3. Klasse.
// SeedRNG kommt aus DivisionMitRestTests.swift (gleiches Testmodul).

import Testing
import LernWeideCore
@testable import MatheWeide

/// Alle Stationen der 3. Klasse, die eine ZahlenAufgabe erzeugen
/// (Division mit Rest hat ein eigenes Modell und eigene Tests).
enum Station3: CaseIterable, Sendable {
    case aufwaermen
    case zahlenraum1000
    case plusMinus1000
    case malreihen
    case inRechnungen
    case laengen
    case gewichte
    case geldZeit
    case sachaufgaben

    /// Obergrenze für die Antwort – abgeleitet aus den Wertebereichen der Generatoren.
    var maxAntwort: Int {
        switch self {
        case .aufwaermen: return 100
        case .zahlenraum1000: return 1000
        case .plusMinus1000: return 1000
        case .malreihen: return 900
        case .inRechnungen: return 100
        case .laengen: return 10000
        case .gewichte: return 1000
        case .geldZeit: return 900
        case .sachaufgaben: return 1000
        }
    }

    func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch self {
        case .aufwaermen: return AufwaermenGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .zahlenraum1000: return Zahlenraum1000Generator.neueAufgabe(gangart: gangart, using: &rng)
        case .plusMinus1000: return PlusMinus1000Generator.neueAufgabe(gangart: gangart, using: &rng)
        case .malreihen: return MalreihenGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .inRechnungen: return InRechnungenGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .laengen: return LaengenGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .gewichte: return GewichteGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .geldZeit: return GeldZeitGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .sachaufgaben: return Sachaufgaben3Generator.neueAufgabe(gangart: gangart, using: &rng)
        }
    }
}

@Suite("Aufgabengeneratoren 3. Klasse")
struct Klasse3GeneratorenTests {

    @Test(
        "Aufgaben sind wohlgeformt und halten die Antwortgrenzen ein",
        arguments: Station3.allCases, Gangart.allCases
    )
    func wohlgeformt(station: Station3, gangart: Gangart) {
        var rng = SeedRNG(seed: 42)
        for _ in 1...200 {
            let a = station.neueAufgabe(gangart: gangart, using: &rng)
            #expect(!a.frage.isEmpty)
            #expect(a.frage.contains("?"))
            #expect(!a.thema.isEmpty)
            #expect(!a.hinweis.isEmpty)
            #expect(a.antwort >= 0)
            #expect(a.antwort <= station.maxAntwort)
        }
    }

    @Test(
        "Gleicher Seed erzeugt exakt die gleiche Aufgabenfolge",
        arguments: Station3.allCases
    )
    func reproduzierbarkeit(station: Station3) {
        var rng1 = SeedRNG(seed: 7)
        var rng2 = SeedRNG(seed: 7)
        for _ in 1...50 {
            let a = station.neueAufgabe(gangart: .trab, using: &rng1)
            let b = station.neueAufgabe(gangart: .trab, using: &rng2)
            #expect(a == b)
        }
    }

    @Test(
        "Quercheck: geparste Rechenfragen ergeben die gespeicherte Antwort",
        arguments: [Station3.aufwaermen, .plusMinus1000, .malreihen, .inRechnungen],
        Gangart.allCases
    )
    func quercheck(station: Station3, gangart: Gangart) {
        var rng = SeedRNG(seed: 99)
        var geprueft = 0
        for _ in 1...200 {
            let a = station.neueAufgabe(gangart: gangart, using: &rng)
            guard let (x, op, y) = Self.zerlegeEinfacheRechnung(a.frage) else { continue }
            geprueft += 1
            switch op {
            case "+": #expect(x + y == a.antwort, "\(a.frage)")
            case "−": #expect(x - y == a.antwort, "\(a.frage)")
            case "·": #expect(x * y == a.antwort, "\(a.frage)")
            case ":":
                #expect(x % y == 0, "\(a.frage) sollte ohne Rest aufgehen")
                #expect(x / y == a.antwort, "\(a.frage)")
            default: Issue.record("Unbekannter Operator in \(a.frage)")
            }
        }
        // Platzhalter-Formen („? + b = ziel") werden übersprungen. Bei Aufwärmen
        // und Plus & Minus 1000 besteht der Galopp NUR aus solchen Formen –
        // überall sonst muss der Parser Fragen gefunden haben.
        let nurPlatzhalter = gangart == .galopp
            && (station == .aufwaermen || station == .plusMinus1000)
        if !nurPlatzhalter {
            #expect(geprueft > 0)
        }
    }

    @Test("istRichtig akzeptiert nur die korrekte Antwort")
    func antwortPruefung() {
        let aufgabe = ZahlenAufgabe(frage: "3 + 4 = ?", antwort: 7, thema: "Test", hinweis: "–")
        #expect(aufgabe.istRichtig(7))
        #expect(!aufgabe.istRichtig(8))
    }

    @Test("Tausenderpunkt-Formatierung (österreichische Schreibweise)")
    func formatierung() {
        #expect(999.mitTausenderpunkt == "999")
        #expect(1000.mitTausenderpunkt == "1.000")
        #expect(25000.mitTausenderpunkt == "25.000")
        #expect(100000.mitTausenderpunkt == "100.000")
    }

    /// Zerlegt Fragen der Form „a <op> b = ?" – alles andere ergibt nil.
    /// Tausenderpunkte („12.300") werden entfernt.
    static func zerlegeEinfacheRechnung(_ frage: String) -> (Int, String, Int)? {
        let teile = frage.split(separator: " ").map(String.init)
        guard teile.count == 5,
              teile[3] == "=",
              teile[4] == "?",
              let x = Int(teile[0].split(separator: ".").joined()),
              let y = Int(teile[2].split(separator: ".").joined())
        else { return nil }
        return (x, teile[1], y)
    }
}
