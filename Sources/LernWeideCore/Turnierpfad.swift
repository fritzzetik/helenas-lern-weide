// Turnierpfad.swift
// Stationen in Lehrplan-Reihenfolge mit Freischalt-Logik.
// Fachübergreifend: die konkreten Stationen liefert das jeweilige Fach-Package.

/// Status einer Station im Turnierpfad.
public enum StationsStatus: Sendable, Equatable {
    case geschafft
    case offen
    case gesperrt
}

/// Ein Turnierpfad: Stationen in fester Reihenfolge.
/// Eine Station ist offen, wenn sie die erste ist oder die vorige eine
/// Schleife 🎀 hat. Geschaffte Stationen bleiben immer offen.
public struct Turnierpfad<StationID: Hashable & Sendable>: Sendable {
    public let stationen: [StationID]
    /// Rundenlänge dieses Pfads: 5 für die 1./2. Klasse, 10 für die 3./4.
    public let aufgabenProRunde: Int

    public init(stationen: [StationID], aufgabenProRunde: Int = 10) {
        self.stationen = stationen
        self.aufgabenProRunde = aufgabenProRunde
    }

    public func status(_ station: StationID, geschafft: Set<StationID>) -> StationsStatus {
        guard let idx = stationen.firstIndex(of: station) else { return .gesperrt }
        if geschafft.contains(station) { return .geschafft }
        if idx == 0 || geschafft.contains(stationen[idx - 1]) { return .offen }
        return .gesperrt
    }

    /// Die nächste offene (noch nicht geschaffte) Station – nil, wenn alle geschafft sind.
    public func naechsteOffene(geschafft: Set<StationID>) -> StationID? {
        stationen.first { status($0, geschafft: geschafft) == .offen }
    }
}
