// MatheAufgabe.swift
// Vereinheitlicht die beiden Aufgabentypen: eine Zahl als Antwort
// oder Division mit Rest (zwei Eingabefelder). Wie „typ" im Prototyp.

import Foundation

public enum MatheAufgabe: Equatable, Sendable {
    case zahl(ZahlenAufgabe)
    case divisionMitRest(DivisionsAufgabe)

    /// Aufgabentext, wie ihn das Kind sieht.
    public var frage: String {
        switch self {
        case .zahl(let a):
            return a.frage
        case .divisionMitRest(let a):
            return "\(a.dividend.mitTausenderpunkt) : \(a.divisor) = ?  Rest ?"
        }
    }

    public var thema: String {
        switch self {
        case .zahl(let a): return a.thema
        case .divisionMitRest: return "Division mit Rest"
        }
    }

    /// Kindgerechter Lösungshinweis.
    public var hinweis: String {
        switch self {
        case .zahl(let a):
            return a.hinweis
        case .divisionMitRest(let a):
            return "Such die größte Zahl der \(a.divisor)er-Reihe, die noch in \(a.dividend) passt (\(a.divisor) · \(a.ergebnis) = \(a.divisor * a.ergebnis)). Was übrig bleibt, ist der Rest."
        }
    }

    /// Die richtige Antwort als Text – z. B. für Brunos Erklärungen.
    public var antwortText: String {
        switch self {
        case .zahl(let a): return a.antwortText
        case .divisionMitRest(let a): return "\(a.ergebnis), Rest \(a.rest)"
        }
    }
}
