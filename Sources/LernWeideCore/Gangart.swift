// Gangart.swift
// Adaptive Schwierigkeit über Reitergangarten – fachübergreifend nutzbar.
// WICHTIG: Diese Logik ist rein deterministisch. Kein LLM rechnet hier mit.

import Foundation

/// Die drei Schwierigkeitsstufen als Gangarten.
public enum Gangart: Int, CaseIterable, Comparable, Sendable {
    case schritt = 0
    case trab = 1
    case galopp = 2

    public static func < (lhs: Gangart, rhs: Gangart) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Nächstschnellere Gangart (Galopp bleibt Galopp).
    public var schneller: Gangart {
        Gangart(rawValue: rawValue + 1) ?? .galopp
    }

    /// Nächstlangsamere Gangart (Schritt bleibt Schritt).
    public var langsamer: Gangart {
        Gangart(rawValue: rawValue - 1) ?? .schritt
    }

    /// Anzeigename (österreichisches Deutsch).
    public var anzeigename: String {
        switch self {
        case .schritt: return "Schritt"
        case .trab: return "Trab"
        case .galopp: return "Galopp"
        }
    }
}

/// Verfolgt Antwort-Serien und passt die Gangart an – Regeln wie im Prototyp:
/// 2 Erstversuch-Treffer in Folge → schneller, 2 Fehler in Folge → langsamer.
/// Ein Zweitversuch-Treffer ist kein Fehler, bricht aber die Tempo-Serie.
public struct GangartTracker: Sendable {
    public private(set) var gangart: Gangart
    public private(set) var richtigSerie: Int = 0
    public private(set) var falschSerie: Int = 0

    public let hochstufenNach: Int
    public let runterstufenNach: Int

    public init(
        start: Gangart = .schritt,
        hochstufenNach: Int = 2,
        runterstufenNach: Int = 2
    ) {
        self.gangart = start
        self.hochstufenNach = hochstufenNach
        self.runterstufenNach = runterstufenNach
    }

    /// Verarbeitet ein Ergebnis und liefert `true`, wenn sich die Gangart geändert hat.
    @discardableResult
    public mutating func verarbeite(_ ergebnis: AntwortErgebnis) -> Bool {
        let vorher = gangart
        switch ergebnis {
        case .erstversuch:
            richtigSerie += 1
            falschSerie = 0
            if richtigSerie >= hochstufenNach {
                gangart = gangart.schneller
                richtigSerie = 0
            }
        case .zweitversuch:
            // Geschafft, aber kein Tempo-Beweis: die Serie beginnt neu,
            // die Fehler-Serie bleibt unberührt (wie im Prototyp).
            richtigSerie = 0
        case .erklaert:
            richtigSerie = 0
            falschSerie += 1
            if falschSerie >= runterstufenNach {
                gangart = gangart.langsamer
                falschSerie = 0
            }
        }
        return gangart != vorher
    }

    /// Vereinfachte Sicht: `richtig` heißt „beim ersten Versuch richtig".
    @discardableResult
    public mutating func verarbeite(richtig: Bool) -> Bool {
        verarbeite(richtig ? .erstversuch : .erklaert)
    }
}
