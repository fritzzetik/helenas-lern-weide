// AufgabenPlaner.swift
// Plant die Aufgaben einer Runde inklusive Wiederholungs-Mix – wie im Prototyp:
// Bei Misch-Stationen sind die Positionen 2, 4, 6 und 8 (Index 1, 3, 5, 7)
// Wiederholungen aus einer zufälligen, bereits geschafften Station desselben
// Pfads – eine Gangart gemütlicher (höchstens Trab). Die erste und die letzte
// Aufgabe sind nie Wiederholungen.

import Foundation
import LernWeideCore

public enum AufgabenPlaner {

    /// Positionen (0-basiert), an denen Misch-Stationen wiederholen.
    public static let wiederholungsPositionen: Set<Int> = [1, 3, 5, 7]

    /// Erzeugt die Aufgabe für eine Position der Runde.
    /// Liefert zusätzlich die Quellstation, wenn es eine Wiederholung ist.
    public static func aufgabe(
        fuer station: MatheStation,
        position: Int,
        gangart: Gangart,
        pfad: Turnierpfad<MatheStation>,
        geschafft: Set<MatheStation>,
        gangarten: [MatheStation: Gangart],
        using rng: inout some RandomNumberGenerator
    ) -> (aufgabe: MatheAufgabe, wiederholungVon: MatheStation?) {
        if station.mischtWiederholungen, wiederholungsPositionen.contains(position) {
            let quellen = pfad.stationen.filter { geschafft.contains($0) && $0 != station }
            if let quelle = quellen.randomElement(using: &rng) {
                let gemuetlicher = min(gangarten[quelle] ?? .schritt, .trab)
                return (quelle.neueAufgabe(gangart: gemuetlicher, using: &rng), quelle)
            }
        }
        return (station.neueAufgabe(gangart: gangart, using: &rng), nil)
    }
}
