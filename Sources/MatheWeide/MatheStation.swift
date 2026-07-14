// MatheStation.swift
// Alle Stationen beider Turnierpfade – Metadaten und Generator-Zuordnung
// wie im Prototyp (TURNIERPFADE). Die Rohwerte sind die Prototyp-IDs,
// damit Fortschritt aus dem Web-Prototyp übertragbar bleibt.

import Foundation
import LernWeideCore

public enum MatheStation: String, CaseIterable, Sendable, Identifiable {
    /// Die Prototyp-ID – auch für SwiftUI-Listen (Identifiable).
    public var id: String { rawValue }

    // 1. Klasse (Lehrplan-Reihenfolge, Zahlenraum 20)
    case zaehlenBis20 = "s1_zaehlen"
    case zerlegenErgaenzen = "s1_zerlegen"
    case plusMinusBis10 = "s1_pm10"
    case zahlenraum20 = "s1_zr20"
    case plusMinusBis20 = "s1_pm20"
    case verdoppelnBis20 = "s1_verdopp"
    case geldBis20 = "s1_geld"
    case abschlussturnier1 = "s1_final"

    // 2. Klasse (Zahlenraum 100, kleines Einmaleins)
    case zahlenraum100 = "s2_zr100"
    case plusMinusOhneUebertrag = "s2_pmo"
    case plusMinusMitUebertrag = "s2_pmm"
    case kleineMalreihen = "s2_mal"
    case ersteInRechnungen = "s2_in"
    case verdoppelnHalbieren = "s2_verdopp"
    case uhrZeit = "s2_zeit"
    case abschlussturnier2 = "s2_final"

    // 3. Klasse (Lehrplan-Reihenfolge)
    case aufwaermenBis100 = "s3_warm"
    case zahlenraum1000 = "s3_zr"
    case plusMinusBis1000 = "s3_pm"
    case malreihen = "s3_mal"
    case inRechnungen = "s3_in"
    case divisionMitRest = "s3_rest"
    case haelfteViertel = "s3_teile"
    case laengenmasse = "s3_laenge"
    case gewichte = "s3_gewicht"
    case geldUndZeit = "s3_geld"
    case abschlussturnier3 = "s3_final"

    // 4. Klasse (Lehrplan-Reihenfolge)
    case zahlenraum100000 = "s4_zr"
    case bisZurMillion = "s4_mio"
    case plusMinusBis100000 = "s4_pm"
    case rundenUndUeberschlagen = "s4_rund"
    case malInBis100000 = "s4_mal"
    case schriftlichDividieren = "s4_div"
    case bruecheUndTeile = "s4_brueche"
    case umfangUndFlaeche = "s4_geo"
    case neueMasse = "s4_masse"
    case kommaGeldMasse = "s4_komma"
    case abschlussturnier4 = "s4_final"

    public var titel: String {
        switch self {
        case .zaehlenBis20: return "Zählen & Zahlen"
        case .zerlegenErgaenzen: return "Zerlegen & Ergänzen"
        case .plusMinusBis10: return "Plus & Minus bis 10"
        case .zahlenraum20: return "Zahlenraum 20"
        case .plusMinusBis20: return "Plus & Minus bis 20"
        case .verdoppelnBis20: return "Verdoppeln & Halbieren"
        case .geldBis20: return "Mit Euro zahlen"
        case .abschlussturnier1: return "Abschlussturnier"
        case .zahlenraum100: return "Zahlenraum 100 entdecken"
        case .plusMinusOhneUebertrag: return "Plus & Minus ohne Übertrag"
        case .plusMinusMitUebertrag: return "Plus & Minus mit Übertrag"
        case .kleineMalreihen: return "Das kleine Einmaleins"
        case .ersteInRechnungen: return "Erste In-Rechnungen"
        case .verdoppelnHalbieren: return "Verdoppeln & Halbieren"
        case .uhrZeit: return "Uhr & Zeit"
        case .abschlussturnier2: return "Abschlussturnier"
        case .aufwaermenBis100: return "Aufwärmen: Plus & Minus bis 100"
        case .zahlenraum1000: return "Zahlenraum 1000 entdecken"
        case .plusMinusBis1000: return "Plus & Minus bis 1000"
        case .malreihen: return "Malreihen sichern"
        case .inRechnungen: return "In-Rechnungen"
        case .divisionMitRest: return "Division mit Rest"
        case .haelfteViertel: return "Hälfte & Viertel"
        case .laengenmasse: return "Längenmaße"
        case .gewichte: return "Gewichte"
        case .geldUndZeit: return "Geld & Zeit"
        case .abschlussturnier3: return "Abschlussturnier"
        case .zahlenraum100000: return "Zahlenraum 100.000 entdecken"
        case .bisZurMillion: return "Bis zur Million"
        case .plusMinusBis100000: return "Plus & Minus bis 100.000"
        case .rundenUndUeberschlagen: return "Runden & Überschlagen"
        case .malInBis100000: return "Mal & In mit großen Zahlen"
        case .schriftlichDividieren: return "Schriftlich dividieren"
        case .bruecheUndTeile: return "Brüche & Teile"
        case .umfangUndFlaeche: return "Umfang & Fläche"
        case .neueMasse: return "Neue Maße"
        case .kommaGeldMasse: return "Komma, Geld & Maße"
        case .abschlussturnier4: return "Abschlussturnier"
        }
    }

    public var untertitel: String {
        switch self {
        case .zaehlenBis20: return "Nachbarzahlen finden"
        case .zerlegenErgaenzen: return "Wie viel fehlt?"
        case .plusMinusBis10: return "die ersten Rechnungen"
        case .zahlenraum20: return "Zehner und Einer"
        case .plusMinusBis20: return "über den Zehner"
        case .verdoppelnBis20: return "doppelt und halb"
        case .geldBis20: return "€ bis 20"
        case .abschlussturnier1: return "kleine Sachaufgaben"
        case .zahlenraum100: return "Zehner und Einer"
        case .plusMinusOhneUebertrag: return "Schritt für Schritt"
        case .plusMinusMitUebertrag: return "über den Zehner"
        case .kleineMalreihen: return "alle Malreihen"
        case .ersteInRechnungen: return "Teilen kennenlernen"
        case .verdoppelnHalbieren: return "doppelt und halb"
        case .uhrZeit: return "Stunden, Minuten, Tage"
        case .abschlussturnier2: return "gemischte Sachaufgaben"
        case .aufwaermenBis100: return "Wiederholung"
        case .zahlenraum1000: return "Hunderter, Zehner, Einer"
        case .plusMinusBis1000: return "rechnen im großen Raum"
        case .malreihen: return "das Einmaleins"
        case .inRechnungen: return "Teilen lernen"
        case .divisionMitRest: return "z. B. 47 : 5"
        case .haelfteViertel: return "Brüche anbahnen"
        case .laengenmasse: return "m, cm, km"
        case .gewichte: return "kg, dag, g"
        case .geldUndZeit: return "€, c, h, min"
        case .abschlussturnier3: return "gemischte Sachaufgaben"
        case .zahlenraum100000: return "große Zahlen verstehen"
        case .bisZurMillion: return "der ganze Zahlenraum"
        case .plusMinusBis100000: return "rechnen im großen Raum"
        case .rundenUndUeberschlagen: return "≈ ungefähr rechnen"
        case .malInBis100000: return "geschickt zerlegen"
        case .schriftlichDividieren: return "große Zahlen teilen"
        case .bruecheUndTeile: return "Drittel, Viertel, Achtel"
        case .umfangUndFlaeche: return "Rechteck und Quadrat"
        case .neueMasse: return "t, mm, s"
        case .kommaGeldMasse: return "2,50 € verstehen"
        case .abschlussturnier4: return "gemischte Sachaufgaben"
        }
    }

    public var emoji: String {
        switch self {
        case .zaehlenBis20: return "🐣"
        case .zerlegenErgaenzen: return "🧩"
        case .plusMinusBis10: return "🌱"
        case .zahlenraum20, .zahlenraum100, .zahlenraum1000, .zahlenraum100000: return "🔢"
        case .plusMinusBis20, .plusMinusOhneUebertrag, .plusMinusBis1000, .plusMinusBis100000: return "➕"
        case .plusMinusMitUebertrag: return "💪"
        case .verdoppelnBis20, .verdoppelnHalbieren: return "🪞"
        case .geldBis20, .geldUndZeit, .kommaGeldMasse: return "💶"
        case .kleineMalreihen, .malreihen, .malInBis100000: return "✖️"
        case .ersteInRechnungen, .inRechnungen: return "🍏"
        case .uhrZeit: return "⏰"
        case .aufwaermenBis100: return "🐾"
        case .divisionMitRest, .schriftlichDividieren: return "➗"
        case .haelfteViertel, .bruecheUndTeile: return "🍕"
        case .laengenmasse: return "📏"
        case .gewichte, .neueMasse: return "⚖️"
        case .rundenUndUeberschlagen: return "🎯"
        case .bisZurMillion: return "🚀"
        case .umfangUndFlaeche: return "📐"
        case .abschlussturnier1, .abschlussturnier2, .abschlussturnier3, .abschlussturnier4: return "🏆"
        }
    }

    /// Mischt diese Station Wiederholungsaufgaben aus geschafften Stationen bei?
    /// (Im Prototyp etwa jede dritte Station des Pfads.)
    public var mischtWiederholungen: Bool {
        switch self {
        case .plusMinusBis20, .geldBis20, .abschlussturnier1,
             .plusMinusMitUebertrag, .uhrZeit, .abschlussturnier2,
             .plusMinusBis1000, .divisionMitRest, .geldUndZeit, .abschlussturnier3,
             .rundenUndUeberschlagen, .schriftlichDividieren, .kommaGeldMasse, .abschlussturnier4:
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
        case .zaehlenBis20: return .zahl(ZaehlenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .zerlegenErgaenzen: return .zahl(ZerlegenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis10: return .zahl(PlusMinus10Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum20: return .zahl(Zahlenraum20Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis20: return .zahl(PlusMinus20Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .verdoppelnBis20: return .zahl(VerdoppelnBis20Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .geldBis20: return .zahl(GeldBis20Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier1: return .zahl(Sachaufgaben1Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum100: return .zahl(Zahlenraum100Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusOhneUebertrag: return .zahl(PlusMinusOhneUebertragGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusMitUebertrag: return .zahl(PlusMinus100MitUebertragGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .kleineMalreihen: return .zahl(KleineMalreihenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .ersteInRechnungen: return .zahl(ErsteInRechnungenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .verdoppelnHalbieren: return .zahl(VerdoppelnHalbierenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .uhrZeit: return .zahl(UhrZeitGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier2: return .zahl(Sachaufgaben2Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .aufwaermenBis100: return .zahl(AufwaermenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum1000: return .zahl(Zahlenraum1000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis1000: return .zahl(PlusMinus1000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .malreihen: return .zahl(MalreihenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .inRechnungen: return .zahl(InRechnungenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .divisionMitRest: return .divisionMitRest(DivisionsGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .haelfteViertel: return .zahl(HaelfteViertelGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .laengenmasse: return .zahl(LaengenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .gewichte: return .zahl(GewichteGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .geldUndZeit: return .zahl(GeldZeitGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier3: return .zahl(Sachaufgaben3Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .zahlenraum100000: return .zahl(Zahlenraum100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .bisZurMillion: return .zahl(MillionGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .plusMinusBis100000: return .zahl(PlusMinus100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .rundenUndUeberschlagen: return .zahl(RundenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .malInBis100000: return .zahl(MalIn100000Generator.neueAufgabe(gangart: gangart, using: &rng))
        case .schriftlichDividieren: return .divisionMitRest(SchriftlichDividierenGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .bruecheUndTeile: return .zahl(BruecheGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .umfangUndFlaeche: return .zahl(UmfangFlaecheGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .neueMasse: return .zahl(NeueMasseGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .kommaGeldMasse: return .zahl(KommaGeldGenerator.neueAufgabe(gangart: gangart, using: &rng))
        case .abschlussturnier4: return .zahl(Sachaufgaben4Generator.neueAufgabe(gangart: gangart, using: &rng))
        }
    }
}

/// Die Turnierpfade in Lehrplan-Reihenfolge – wie im Prototyp.
/// 1./2. Klasse üben kurze Runden mit 5 Aufgaben, 3./4. Klasse mit 10.
public enum Turnierpfade {
    public static let klasse1 = Turnierpfad<MatheStation>(stationen: [
        .zaehlenBis20, .zerlegenErgaenzen, .plusMinusBis10, .zahlenraum20,
        .plusMinusBis20, .verdoppelnBis20, .geldBis20, .abschlussturnier1,
    ], aufgabenProRunde: 5)

    public static let klasse2 = Turnierpfad<MatheStation>(stationen: [
        .zahlenraum100, .plusMinusOhneUebertrag, .plusMinusMitUebertrag,
        .kleineMalreihen, .ersteInRechnungen, .verdoppelnHalbieren,
        .uhrZeit, .abschlussturnier2,
    ], aufgabenProRunde: 5)

    public static let klasse3 = Turnierpfad<MatheStation>(stationen: [
        .aufwaermenBis100, .zahlenraum1000, .plusMinusBis1000, .malreihen, .inRechnungen,
        .divisionMitRest, .haelfteViertel, .laengenmasse, .gewichte, .geldUndZeit,
        .abschlussturnier3,
    ], aufgabenProRunde: 10)

    public static let klasse4 = Turnierpfad<MatheStation>(stationen: [
        .zahlenraum100000, .bisZurMillion, .plusMinusBis100000, .rundenUndUeberschlagen,
        .malInBis100000, .schriftlichDividieren, .bruecheUndTeile, .umfangUndFlaeche,
        .neueMasse, .kommaGeldMasse, .abschlussturnier4,
    ], aufgabenProRunde: 10)

    /// Alle Pfade in Schulstufen-Reihenfolge.
    public static let alle = [klasse1, klasse2, klasse3, klasse4]
}
