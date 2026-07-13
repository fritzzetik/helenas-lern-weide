// Runde.swift
// Eine Übungsrunde: 10 Aufgaben, Sterne, Gangart-Anpassung und Schleifen-Check 🎀.
// Regeln wie im Prototyp: Schleife ab 8 von 10 Sternen in Trab oder Galopp.

/// Zustand einer laufenden Übungsrunde.
public struct Runde: Sendable {
    /// 10 Aufgaben je Runde – passt besser zu 3 Minuten Bewegungspause
    /// (Helena-approved, 13.07.2026 🙂). Vorher 5.
    public static let aufgabenProRunde = 10
    /// Mindestens 8 von 10 Sternen (gleiche 80-%-Hürde wie vorher 4 von 5) …
    public static let schleifeMinSterne = 8
    /// … in Trab oder Galopp für eine Schleife 🎀.
    public static let schleifeMinGangart = Gangart.trab

    /// Wie viele Aufgaben schon beantwortet sind (0-basiert = Index der nächsten Aufgabe).
    public private(set) var position = 0
    public private(set) var sterne = 0
    public private(set) var tracker: GangartTracker

    public init(gangart: Gangart = .schritt) {
        tracker = GangartTracker(start: gangart)
    }

    public var gangart: Gangart { tracker.gangart }
    public var istFertig: Bool { position >= Self.aufgabenProRunde }

    /// Verarbeitet das Ergebnis der aktuellen Aufgabe.
    /// Liefert `true`, wenn sich die Gangart geändert hat.
    @discardableResult
    public mutating func verarbeite(_ ergebnis: AntwortErgebnis) -> Bool {
        guard !istFertig else { return false }
        if ergebnis.verdientStern { sterne += 1 }
        position += 1
        return tracker.verarbeite(ergebnis)
    }

    /// Schleife 🎀 verdient? Zählt die Gangart NACH der letzten Antwort,
    /// genau wie im Prototyp.
    public var schleifeVerdient: Bool {
        istFertig && sterne >= Self.schleifeMinSterne && gangart >= Self.schleifeMinGangart
    }
}
