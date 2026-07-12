// MatheStation.swift
// Alle Stationen beider Turnierpfade – Metadaten und Generator-Zuordnung
// wie im Prototyp (TURNIERPFADE). Die Rohwerte sind die Prototyp-IDs,
// damit Fortschritt aus dem Web-Prototyp übertragbar bleibt.

import Foundation
import LernWeideCore

public enum MatheStation: String, CaseIterable, Sendable, Identifiable {
    /// Die Prototyp-ID – auch für SwiftUI-Listen (Identifiable).
    public var id: String { rawValue }

    // 3. Klasse (Lehrplan-Reihenfolge)
    case aufwaermenBis100 = "s3_warm"
    case zahlenraum1000 = "s3_zr"
    case plusMinusBis1000 = "s3_pm"
    case malreihen = "s3_mal"
    case inRechnungen = "s3_in"
    case divisionMitRest = "s3_rest"
    case laengenmasse = "s3_laenge"
    case gewichte = "s3_gewicht"
    case geldUndZeit = "s3_geld"
    case abschlussturnier3 = "s3_final"

    // 4. Klasse (Lehrplan-Reihenfolge)
    case zahlenraum100000 = "s4_zr"
    case plusMinusBis100000 = "s4_pm"
    case rundenUndUeberschlagen = "s4_rund"
    case malInBis100000 = "s4_mal"
    case neueMasse = "s4_masse"
    case abschlussturnier4 = "s4_final"

    public var titel: String {
        switch self {
        case .aufwaermenBis100: return "Aufwärmen: Plus & Minus bis 100"
        case .zahlenraum1000: return "Zahlenraum 1000 entdecken"
        case .plusMinusBis1000: return "Plus & Minus bis 1000"
        case .malreihen: return "Malreihen sichern"
        case .inRechnungen: return "In-Rechnungen"
        case .divisionMitRest: return "Division mit Rest"
        case .laengenmasse: return "Längenmaße"
        case .gewichte: return "Gewichte"
        case .geldUndZeit: return "Geld & Zeit"
        case .abschlussturnier3: return "Abschlussturnier"
        case .zahlenraum100000: return "Zahlenraum 100.000 entdecken"
        case .plusMinusBis100000: return "Plus & Minus bis 100.000"
        case .rundenUndUeberschlagen: return "Runden & Überschlagen"
        case .malInBis100000: return "Mal & In mit großen Zahlen"
        case .neueMasse: return "Neue Maße"
        case .abschlussturnier4: return "Abschlussturnier"
        }
    }

    public var untertitel: String {
        switch self {
        case .aufwaermenBis100: return "Wiederholung"
        case .zahlenraum1000: return "Hunderter, Zehner, Einer"
        case .plusMinusBis1000: return "rechnen im großen Raum"
        case .malreihen: return "das Einmaleins"
        case .inRechnungen: return "Teilen lernen"
        case .divisionMitRest: return "z. B. 47 : 5"
        case .laengenmasse: return "m, cm, km"
        case .gewichte: return "kg, dag, g"
        case .geldUndZeit: return "€, c, h, min"
        case .abschlussturnier3: return "gemischte Sachaufgaben"
        case .zahlenraum100000: return "große Zahlen verstehen"
        case .plusMinusBis100000: return "rechnen im großen Raum"
        case .rundenUndUeberschlagen: return "≈ ungefähr rechnen"
        case .malInBis100000: return "geschickt zerlegen"
        case .neueMasse: return "t, mm, s"
        case .abschlussturnier4: return "gemischte Sachaufgaben"
        }
    }

    public var emoji: String {
        switch self {
        case .aufwaermenBis100: return "🐾"
        case .zahlenraum1000, .zahlenraum100000: return "🔢"
        case .plusMinusBis1000, .plusMinusBis100000: return "➕"
        case .malreihen, .malInBis100000: return "✖️"
        case .inRechnungen: return "🍏"
        case .divisionMitRest: return "➗"
        case .laengenmasse: return "📏"
        case .gewichte, .neueMasse: return "⚖️"
        case .geldUndZeit: return "💶"
        case .rundenUndUeberschlagen: return "🎯"
        case .abschlussturnier3, .abschlussturnier4: return "🏆"
        }
    }

    /// Mischt diese Station Wiederholungsaufgaben aus geschafften Stationen bei?
    /// (Im Prototyp etwa jede dritte Station des Pfads.)
    public var mischtWiederholungen: Bool {
        switch self {
        case .plusMinusBis1000, .divisionMitRest, .geldUndZeit, .abschlussturnier3,
             .rundenUndUeberschlagen, .abschlussturnier4:
            return true
        default:
            return false
        }
    }

    public func neueAufgabe(
        gangart: Gangart,
        using rng: inout some RandomNumberGenerator
    ) -> MatheAufgabe {
        switch self {
        case .aufwaermenBis100: return .zahl(AufwaermenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum1000: return .zahl(Zahlenraum1000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis1000: return .zahl(PlusMinus1000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .malreihen: return .zahl(MalreihenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .inRechnungen: return .zahl(InRechnungenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .divisionMitRest: return .divisionMitRest(DivisionsGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .laengenmasse: return .zahl(LaengenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .gewichte: return .zahl(GewichteGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .geldUndZeit: return .zahl(GeldZeitGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier3: return .zahl(Sachaufgaben3Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum100000: return .zahl(Zahlenraum100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis100000: return .zahl(PlusMinus100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .rundenUndUeberschlagen: return .zahl(RundenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .malInBis100000: return .zahl(MalIn100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .neueMasse: return .zahl(NeueMasseGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier4: return .zahl(Sachaufgaben4Generator.neueAufgabe(gangart: gangart, using: &rng))
        }
    }
}

/// Die Turnierpfade in Lehrplan-Reihenfolge – wie im Prototyp.
public enum Turnierpfade {
    public static let klasse3 = Turnierpfad<MatheStation>(stationen: [
        .aufwaermenBis100, .zahlenraum1000, .plusMinusBis1000, .malreihen, .inRechnungen,
        .divisionMitRest, .laengenmasse, .gewichte, .geldUndZeit, .abschlussturnier3,
    ])

    public static let klasse4 = Turnierpfad<MatheStation>(stationen: [
        .zahlenraum100000, .plusMinusBis100000, .rundenUndUeberschlagen,
        .malInBis100000, .neueMasse, .abschlussturnier4,
    ])
}
