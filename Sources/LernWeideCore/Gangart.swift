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

/// Verfolgt Antwort-Serien und passt die Gangart an.
/// Standard: 3 richtige in Folge → schneller, 2 falsche in Folge → langsamer.
public struct GangartTracker: Sendable {
    public private(set) var gangart: Gangart
    public private(set) var richtigSerie: Int = 0
    public private(set) var falschSerie: Int = 0

    public let hochstufenNach: Int
    public let runterstufenNach: Int

    public init(
        start: Gangart = .schritt,
        hochstufenNach: Int = 3,
        runterstufenNach: Int = 2
    ) {
        self.gangart = start
        self.hochstufenNach = hochstufenNach
        self.runterstufenNach = runterstufenNach
    }

    /// Verarbeitet eine Antwort und liefert `true`, wenn sich die Gangart geändert hat.
    @discardableResult
    public mutating func verarbeite(richtig: Bool) -> Bool {
        let vorher = gangart
        if richtig {
            richtigSerie += 1
            falschSerie = 0
            if richtigSerie >= hochstufenNach {
                gangart = gangart.schneller
                richtigSerie = 0
            }
        } else {
            falschSerie += 1
            richtigSerie = 0
            if falschSerie >= runterstufenNach {
                gangart = gangart.langsamer
                falschSerie = 0
            }
        }
        return gangart != vorher
    }
}
