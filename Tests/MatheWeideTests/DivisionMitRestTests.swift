// DivisionMitRestTests.swift
import Testing
import LernWeideCore
@testable import MatheWeide

/// Deterministischer RNG für reproduzierbare Tests (SplitMix64).
struct SeedRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

@Suite("Division mit Rest (3. Klasse)")
struct DivisionMitRestTests {

    @Test("Ergebnis und Rest sind mathematisch korrekt")
    func korrektheit() {
        let aufgabe = DivisionsAufgabe(dividend: 17, divisor: 5)
        #expect(aufgabe.ergebnis == 3)
        #expect(aufgabe.rest == 2)
        #expect(aufgabe.istRichtig(ergebnis: 3, rest: 2))
        #expect(!aufgabe.istRichtig(ergebnis: 3, rest: 1))
    }

    @Test(
        "Generierte Aufgaben halten die Bereichsgrenzen jeder Gangart ein",
        arguments: Gangart.allCases
    )
    func bereichsgrenzen(gangart: Gangart) {
        var rng = SeedRNG(seed: 42)
        let b = DivisionsGenerator.bereich(fuer: gangart)
        for _ in 1...200 {
            let a = DivisionsGenerator.neueAufgabe(gangart: gangart, using: &rng)
            #expect(b.divisoren.contains(a.divisor))
            #expect(b.ergebnis.contains(a.ergebnis))
            // Invariante der Division mit Rest:
            #expect(a.ergebnis * a.divisor + a.rest == a.dividend)
            // Rest ist nie 0 – echte Division MIT Rest, wie im Prototyp:
            #expect(a.rest >= 1)
            #expect(a.rest < a.divisor)
        }
    }

    @Test("Gleicher Seed erzeugt exakt die gleiche Aufgabenfolge")
    func reproduzierbarkeit() {
        var rng1 = SeedRNG(seed: 7)
        var rng2 = SeedRNG(seed: 7)
        for _ in 1...50 {
            let a = DivisionsGenerator.neueAufgabe(gangart: .trab, using: &rng1)
            let b = DivisionsGenerator.neueAufgabe(gangart: .trab, using: &rng2)
            #expect(a == b)
        }
    }
}
