// Runde.swift
// Eine Übungsrunde: 5 Aufgaben, Sterne, Gangart-Anpassung und Schleifen-Check 🎀.
// Regeln wie im Prototyp: Schleife ab 4 von 5 Sternen in Trab oder Galopp.

/// Zustand einer laufenden Übungsrunde.
public struct Runde: Sendable {
    /// Kurze Runden – ADHS-Prinzip.
    public static let aufgabenProRunde = 5
    /// Mindestens 4 von 5 Sternen …
    public static let schleifeMinSterne = 4
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
