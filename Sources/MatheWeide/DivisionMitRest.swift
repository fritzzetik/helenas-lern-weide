// DivisionMitRest.swift
// Aufgabengenerator „Division mit Rest" – 3. Klasse laut österreichischem Lehrplan.
// Alle Ergebnisse werden hier deterministisch berechnet. Das LLM erklärt nur, es rechnet NIE.

import Foundation
import LernWeideCore

/// Eine einzelne Division-mit-Rest-Aufgabe inklusive korrekter Lösung.
public struct DivisionsAufgabe: Equatable, Sendable {
    public let dividend: Int
    public let divisor: Int

    public var ergebnis: Int { dividend / divisor }
    public var rest: Int { dividend % divisor }

    /// Text der Aufgabe, z. B. „17 : 5 = ?"
    public var text: String { "\(dividend) : \(divisor) = ?" }

    /// Prüft eine Kinderantwort (Ergebnis und Rest getrennt eingegeben).
    public func istRichtig(ergebnis e: Int, rest r: Int) -> Bool {
        e == ergebnis && r == rest
    }
}

/// Erzeugt Aufgaben passend zur Gangart – wie genRest im Prototyp:
/// dividend = divisor · ergebnis + rest, mit Rest garantiert ≥ 1.
/// („Rest 0" gehört didaktisch zu den In-Rechnungen, nicht hierher.)
/// Nimmt einen RandomNumberGenerator entgegen → mit Seed vollständig reproduzierbar testbar.
public enum DivisionsGenerator {

    /// Wertebereiche je Gangart (Divisoren, Ergebnis-Bereich).
    static func bereich(fuer gangart: Gangart) -> (divisoren: [Int], ergebnis: ClosedRange<Int>) {
        switch gangart {
        case .schritt: return ([2, 3, 4, 5], 2...9)
        case .trab: return (Array(3...9), 4...10)
        case .galopp: return (Array(4...9), 9...15)
        }
    }

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> DivisionsAufgabe {
        let b = bereich(fuer: gangart)
        let divisor = b.divisoren.randomElement(using: &rng)!
        let ergebnis = Int.random(in: b.ergebnis, using: &rng)
        let rest = Int.random(in: 1...(divisor - 1), using: &rng)
        return DivisionsAufgabe(dividend: divisor * ergebnis + rest, divisor: divisor)
    }
}
