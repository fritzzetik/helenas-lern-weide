// AufgabenPlaner.swift
// Plant die Aufgaben einer Runde inklusive Wiederholungs-Mix – wie im Prototyp:
// Bei Misch-Stationen ist jede zweite Position (Index 1, 3, …) eine Wiederholung
// aus einer zufälligen, bereits geschafften Station desselben Pfads – eine
// Gangart gemütlicher (höchstens Trab). Die erste und die letzte Aufgabe der
// Runde gehören immer der Station selbst. Die Rundenlänge kommt vom Pfad
// (5 in der 1./2. Klasse, 10 in der 3./4.).

import Foundation
import LernWeideCore

public enum AufgabenPlaner {

    /// Positionen (0-basiert), an denen Misch-Stationen wiederholen:
    /// jede zweite, außer der letzten. Für 5er-Runden: 1 und 3;
    /// für 10er-Runden: 1, 3, 5 und 7.
    public static func wiederholungsPositionen(rundenLaenge: Int) -> Set<Int> {
        Set(stride(from: 1, to: rundenLaenge - 1, by: 2))
    }

    /// Erzeugt die Aufgabe für eine Position der Runde.
    /// Liefert zusätzlich die Quellstation, wenn es eine Wiederholung ist.
    /// `vermeideFragen`: bereits gestellte Fragen dieser Runde – der Planer
    /// würfelt bis zu 12-mal neu, damit sich keine Frage wiederholt.
    /// (Kleine Zahlenräume wie „Ergänzen auf 10" haben sonst fast sicher Doppler.)
    public static func aufgabe(
        fuer station: MatheStation,
        position: Int,
        gangart: Gangart,
        pfad: Turnierpfad<MatheStation>,
        geschafft: Set<MatheStation>,
        gangarten: [MatheStation: Gangart],
        vermeideFragen: Set<String> = [],
        using rng: inout some RandomNumberGenerator
    ) -> (aufgabe: MatheAufgabe, wiederholungVon: MatheStation?) {
        var versuch = erzeuge(
            fuer: station, position: position, gangart: gangart,
            pfad: pfad, geschafft: geschafft, gangarten: gangarten, using: &rng
        )
        var anlauf = 0
        while anlauf < 12, vermeideFragen.contains(versuch.aufgabe.frage) {
            versuch = erzeuge(
                fuer: station, position: position, gangart: gangart,
                pfad: pfad, geschafft: geschafft, gangarten: gangarten, using: &rng
            )
            anlauf += 1
        }
        return versuch
    }

    private static func erzeuge(
        fuer station: MatheStation,
        position: Int,
        gangart: Gangart,
        pfad: Turnierpfad<MatheStation>,
        geschafft: Set<MatheStation>,
        gangarten: [MatheStation: Gangart],
        using rng: inout some RandomNumberGenerator
    ) -> (aufgabe: MatheAufgabe, wiederholungVon: MatheStation?) {
        if station.mischtWiederholungen,
           wiederholungsPositionen(rundenLaenge: pfad.aufgabenProRunde).contains(position) {
            let quellen = pfad.stationen.filter { geschafft.contains($0) && $0 != station }
            if let quelle = quellen.randomElement(using: &rng) {
                let gemuetlicher = min(gangarten[quelle] ?? .schritt, .trab)
                return (quelle.neueAufgabe(gangart: gemuetlicher, using: &rng), quelle)
            }
        }
        return (station.neueAufgabe(gangart: gangart, using: &rng), nil)
    }
}
