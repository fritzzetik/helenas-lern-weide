// Runde.swift
// Eine Übungsrunde: 10 Aufgaben, Sterne, Gangart-Anpassung und Schleifen-Check 🎀.
// Regeln wie im Prototyp: Schleife ab 8 von 10 Sternen in Trab oder Galopp.

/// Zustand einer laufenden Übungsrunde.
/// Die Rundenlänge hängt vom Turnierpfad ab: 1./2. Klasse üben 5 Aufgaben,
/// 3./4. Klasse 10 (Helena-approved 🙂). Die Schleifen-Hürde bleibt immer
/// dieselbe: 80 % der Sterne in Trab oder Galopp.
public struct Runde: Sendable {
    /// Standard-Rundenlänge (3./4. Klasse).
    public static let standardLaenge = 10
    /// Für eine Schleife 🎀: mindestens 80 % der Sterne …
    public static let schleifenQuote = 0.8
    /// … in Trab oder Galopp.
    public static let schleifeMinGangart = Gangart.trab

    public let aufgabenProRunde: Int
    /// Mindest-Sterne für die Schleife (80 % der Rundenlänge, gerundet).
    public var schleifeMinSterne: Int {
        max(1, Int((Double(aufgabenProRunde) * Self.schleifenQuote).rounded()))
    }

    /// Wie viele Aufgaben schon beantwortet sind (0-basiert = Index der nächsten Aufgabe).
    public private(set) var position = 0
    public private(set) var sterne = 0
    public private(set) var tracker: GangartTracker

    public init(gangart: Gangart = .schritt, aufgabenProRunde: Int = Runde.standardLaenge) {
        self.aufgabenProRunde = aufgabenProRunde
        tracker = GangartTracker(start: gangart)
    }

    public var gangart: Gangart { tracker.gangart }
    public var istFertig: Bool { position >= aufgabenProRunde }

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
        istFertig && sterne >= schleifeMinSterne && gangart >= Self.schleifeMinGangart
    }
}
