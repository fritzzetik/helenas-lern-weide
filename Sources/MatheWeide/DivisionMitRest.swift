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

/// Erzeugt Aufgaben passend zur Gangart.
/// Nimmt einen RandomNumberGenerator entgegen → mit Seed vollständig reproduzierbar testbar.
public enum DivisionsGenerator {

    /// Wertebereiche je Gangart (Divisor, Dividend-Obergrenze).
    static func bereich(fuer gangart: Gangart) -> (divisoren: ClosedRange<Int>, maxDividend: Int) {
        switch gangart {
        case .schritt: return (2...5, 30)
        case .trab: return (2...9, 60)
        case .galopp: return (3...9, 100)
        }
    }

    public static func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> DivisionsAufgabe {
        let b = bereich(fuer: gangart)
        let divisor = Int.random(in: b.divisoren, using: &rng)
        // Dividend so wählen, dass ein echter Rest möglich, aber nicht garantiert ist –
        // die Kinder sollen auch „Rest 0" kennenlernen.
        let dividend = Int.random(in: divisor...b.maxDividend, using: &rng)
        return DivisionsAufgabe(dividend: dividend, divisor: divisor)
    }
}
