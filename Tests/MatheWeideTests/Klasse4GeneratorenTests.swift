// Klasse4GeneratorenTests.swift
// Tests für alle ZahlenAufgabe-Generatoren der 4. Klasse.
// SeedRNG und der Fragen-Parser kommen aus den Klasse-3-Tests (gleiches Testmodul).

import Testing
import LernWeideCore
@testable import MatheWeide

enum Station4: CaseIterable, Sendable {
    case zahlenraum100000
    case plusMinus100000
    case runden
    case malIn100000
    case neueMasse
    case sachaufgaben

    /// Obergrenze für die Antwort – abgeleitet aus den Wertebereichen der Generatoren.
    var maxAntwort: Int {
        switch self {
        case .zahlenraum100000: return 100000
        case .plusMinus100000: return 100000
        case .runden: return 90000
        case .malIn100000: return 10000
        case .neueMasse: return 5000
        case .sachaufgaben: return 10000
        }
    }

    func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> ZahlenAufgabe {
        switch self {
        case .zahlenraum100000: return Zahlenraum100000Generator.neueAufgabe(gangart: gangart, using: &rng)
        case .plusMinus100000: return PlusMinus100000Generator.neueAufgabe(gangart: gangart, using: &rng)
        case .runden: return RundenGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .malIn100000: return MalIn100000Generator.neueAufgabe(gangart: gangart, using: &rng)
        case .neueMasse: return NeueMasseGenerator.neueAufgabe(gangart: gangart, using: &rng)
        case .sachaufgaben: return Sachaufgaben4Generator.neueAufgabe(gangart: gangart, using: &rng)
        }
    }
}

@Suite("Aufgabengeneratoren 4. Klasse")
struct Klasse4GeneratorenTests {

    // Kein „frage enthält ?"-Check wie in der 3. Klasse:
    // Runden-Aufgaben („Runde 37 auf Zehner.") haben bewusst kein Fragezeichen.
    @Test(
        "Aufgaben sind wohlgeformt und halten die Antwortgrenzen ein",
        arguments: Station4.allCases, Gangart.allCases
    )
    func wohlgeformt(station: Station4, gangart: Gangart) {
        var rng = SeedRNG(seed: 42)
        for _ in 1...200 {
            let a = station.neueAufgabe(gangart: gangart, using: &rng)
            #expect(!a.frage.isEmpty)
            #expect(!a.thema.isEmpty)
            #expect(!a.hinweis.isEmpty)
            #expect(a.antwort >= 0)
            #expect(a.antwort <= station.maxAntwort)
        }
    }

    @Test(
        "Gleicher Seed erzeugt exakt die gleiche Aufgabenfolge",
        arguments: Station4.allCases
    )
    func reproduzierbarkeit(station: Station4) {
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
        arguments: [Station4.plusMinus100000, .malIn100000],
        Gangart.allCases
    )
    func quercheck(station: Station4, gangart: Gangart) {
        var rng = SeedRNG(seed: 99)
        var geprueft = 0
        for _ in 1...200 {
            let a = station.neueAufgabe(gangart: gangart, using: &rng)
            guard let (x, op, y) = Klasse3GeneratorenTests.zerlegeEinfacheRechnung(a.frage) else { continue }
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
        // Plus & Minus 100.000 besteht im Galopp NUR aus Platzhalter-Formen
        // („? + b = ziel") – überall sonst muss der Parser Fragen gefunden haben.
        let nurPlatzhalter = station == .plusMinus100000 && gangart == .galopp
        if !nurPlatzhalter {
            #expect(geprueft > 0)
        }
    }

    @Test("Gerundet wird kaufmännisch (0–4 ab, 5–9 auf)")
    func rundungsRegel() {
        #expect(RundenGenerator.gerundet(34, auf: 10) == 30)
        #expect(RundenGenerator.gerundet(35, auf: 10) == 40)
        #expect(RundenGenerator.gerundet(449, auf: 100) == 400)
        #expect(RundenGenerator.gerundet(450, auf: 100) == 500)
        #expect(RundenGenerator.gerundet(2499, auf: 1000) == 2000)
        #expect(RundenGenerator.gerundet(2500, auf: 1000) == 3000)
    }
}
