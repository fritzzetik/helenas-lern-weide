// AntwortErgebnis.swift
// Wie eine Aufgabe gelöst wurde – Grundlage für Sterne und Gangart-Anpassung.

/// Ergebnis einer einzelnen Aufgabe aus Sicht des Kindes.
public enum AntwortErgebnis: Sendable, Equatable {
    /// Beim ersten Versuch richtig – zählt für die Tempo-Serie.
    case erstversuch
    /// Beim zweiten Versuch oder im Quercheck nach Brunos Erklärung richtig.
    case zweitversuch
    /// Auch nach Brunos Erklärung nicht geschafft – zählt als Fehler.
    case erklaert

    /// Sterne gibt es beim ersten und zweiten Versuch.
    public var verdientStern: Bool { self != .erklaert }
}
