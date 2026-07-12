// Bewegungspause.swift
// Verpflichtende 3-Minuten-Bewegungspause nach jeder Runde – nicht überspringbar.
// ADHS-Prinzip: Bewegung ist Teil des Lernens, keine Option. Die UI (Prototyp wie
// iOS-App) darf die nächste Runde erst starten, wenn `istVorbei` true ist.

import Foundation

public struct Bewegungspause: Equatable, Sendable {
    /// Feste Dauer: 3 Minuten.
    public static let dauerSekunden = 180

    public private(set) var verbleibendeSekunden: Int

    public init() {
        verbleibendeSekunden = Self.dauerSekunden
    }

    /// Erst wenn die Pause vorbei ist, darf die nächste Runde starten.
    public var istVorbei: Bool { verbleibendeSekunden == 0 }

    /// Zählt eine Sekunde herunter (ein Timer-Tick der UI).
    public mutating func tick() {
        verstreiche(sekunden: 1)
    }

    /// Zieht mehrere Sekunden auf einmal ab – für nachgeholte Zeit, wenn die
    /// App im Hintergrund war oder das Display gesperrt wurde. Die UI soll das
    /// Pausenende als fixen Zeitpunkt merken, nicht Ticks zählen.
    public mutating func verstreiche(sekunden: Int) {
        verbleibendeSekunden = max(0, verbleibendeSekunden - max(0, sekunden))
    }
}
