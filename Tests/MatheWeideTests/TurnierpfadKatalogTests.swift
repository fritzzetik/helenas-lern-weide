// TurnierpfadKatalogTests.swift
// Tests für Stationen-Katalog, MatheAufgabe und den Aufgabenplaner (Wiederholungs-Mix).

import Testing
import LernWeideCore
@testable import MatheWeide

@Suite("Stationen-Katalog und Aufgabenplaner")
struct TurnierpfadKatalogTests {

    @Test("Alle Pfade zusammen enthalten alle Stationen genau einmal")
    func vollstaendig() {
        let alle = Turnierpfade.alle.flatMap(\.stationen)
        #expect(Turnierpfade.klasse1.stationen.count == 8)
        #expect(Turnierpfade.klasse2.stationen.count == 8)
        #expect(Turnierpfade.klasse3.stationen.count == 11)
        #expect(Turnierpfade.klasse4.stationen.count == 11)
        #expect(alle.count == MatheStation.allCases.count)
        #expect(Set(alle).count == alle.count)
    }

    @Test("Rundenlängen: 5 für die Kleinen, 10 für die Großen")
    func rundenLaengen() {
        #expect(Turnierpfade.klasse1.aufgabenProRunde == 5)
        #expect(Turnierpfade.klasse2.aufgabenProRunde == 5)
        #expect(Turnierpfade.klasse3.aufgabenProRunde == 10)
        #expect(Turnierpfade.klasse4.aufgabenProRunde == 10)
        #expect(AufgabenPlaner.wiederholungsPositionen(rundenLaenge: 5) == [1, 3])
        #expect(AufgabenPlaner.wiederholungsPositionen(rundenLaenge: 10) == [1, 3, 5, 7])
    }

    @Test("1. Klasse: Antworten bleiben im Zahlenraum 20", arguments: Gangart.allCases)
    func klasse1Zahlenraum(gangart: Gangart) {
        var rng = SeedRNG(seed: 11)
        for station in Turnierpfade.klasse1.stationen {
            for _ in 1...100 {
                guard case .zahl(let z) = station.neueAufgabe(gangart: gangart, using: &rng) else {
                    Issue.record("Die 1. Klasse hat nur Zahl-Aufgaben")
                    return
                }
                #expect(z.antwort >= 0, "\(z.frage)")
                #expect(z.antwort <= 20, "\(z.frage)")
            }
        }
    }

    @Test("2. Klasse: Antworten bleiben im Zahlenraum 100", arguments: Gangart.allCases)
    func klasse2Zahlenraum(gangart: Gangart) {
        var rng = SeedRNG(seed: 12)
        for station in Turnierpfade.klasse2.stationen {
            for _ in 1...100 {
                guard case .zahl(let z) = station.neueAufgabe(gangart: gangart, using: &rng) else {
                    Issue.record("Die 2. Klasse hat nur Zahl-Aufgaben")
                    return
                }
                #expect(z.antwort >= 0, "\(z.frage)")
                #expect(z.antwort <= 100, "\(z.frage)")
            }
        }
    }

    @Test(
        "Jede Station erzeugt wohlgeformte Aufgaben",
        arguments: MatheStation.allCases, Gangart.allCases
    )
    func alleStationen(station: MatheStation, gangart: Gangart) {
        var rng = SeedRNG(seed: 21)
        for _ in 1...20 {
            let a = station.neueAufgabe(gangart: gangart, using: &rng)
            #expect(!a.frage.isEmpty)
            #expect(!a.thema.isEmpty)
            #expect(!a.hinweis.isEmpty)
            #expect(!a.antwortText.isEmpty)
        }
        #expect(!station.titel.isEmpty)
        #expect(!station.untertitel.isEmpty)
        #expect(!station.emoji.isEmpty)
    }

    @Test("Die Rest-Station liefert Division-mit-Rest-Aufgaben")
    func restStation() {
        var rng = SeedRNG(seed: 3)
        let a = MatheStation.divisionMitRest.neueAufgabe(gangart: .trab, using: &rng)
        guard case .divisionMitRest(let d) = a else {
            Issue.record("Erwartet: divisionMitRest, war: \(a)")
            return
        }
        #expect(a.frage.contains("Rest ?"))
        #expect(a.antwortText == "\(d.ergebnis), Rest \(d.rest)")
        #expect(a.thema == "Division mit Rest")
    }

    @Test("Schriftliche Division (4. Klasse): große Zahlen, Rest darf 0 sein", arguments: Gangart.allCases)
    func schriftlicheDivision(gangart: Gangart) {
        var rng = SeedRNG(seed: 19)
        var restNullGesehen = false
        for _ in 1...200 {
            let d = SchriftlichDividierenGenerator.neueAufgabe(gangart: gangart, using: &rng)
            #expect(d.ergebnis * d.divisor + d.rest == d.dividend)
            #expect(d.rest >= 0)
            #expect(d.rest < d.divisor)
            #expect(d.ergebnis >= 21)
            if d.rest == 0 { restNullGesehen = true }
        }
        #expect(restNullGesehen, "Rest 0 gehört zur schriftlichen Division dazu")
    }

    @Test("Erste Aufgabe ist nie eine Wiederholung")
    func ersteAufgabe() {
        var rng = SeedRNG(seed: 5)
        let geschafft = Set(Turnierpfade.klasse3.stationen).subtracting([.abschlussturnier3])
        let (_, quelle) = AufgabenPlaner.aufgabe(
            fuer: .abschlussturnier3, position: 0, gangart: .trab,
            pfad: Turnierpfade.klasse3, geschafft: geschafft,
            gangarten: [:], using: &rng
        )
        #expect(quelle == nil)
    }

    @Test("Misch-Station wiederholt an Position 2, 4, 6 und 8 aus geschafften Stationen")
    func wiederholungsMix() {
        var rng = SeedRNG(seed: 8)
        let geschafft: Set<MatheStation> = [.aufwaermenBis100, .zahlenraum1000]
        for position in [1, 3, 5, 7] {
            let (aufgabe, quelle) = AufgabenPlaner.aufgabe(
                fuer: .plusMinusBis1000, position: position, gangart: .galopp,
                pfad: Turnierpfade.klasse3, geschafft: geschafft,
                gangarten: [.aufwaermenBis100: .galopp, .zahlenraum1000: .schritt],
                using: &rng
            )
            guard let quelle else {
                Issue.record("Position \(position) sollte eine Wiederholung sein")
                continue
            }
            #expect(quelle != .plusMinusBis1000)
            #expect(geschafft.contains(quelle))
            #expect(!aufgabe.frage.isEmpty)
        }
    }

    @Test("Ohne geschaffte Stationen gibt es keine Wiederholung")
    func keineQuellen() {
        var rng = SeedRNG(seed: 13)
        let (_, quelle) = AufgabenPlaner.aufgabe(
            fuer: .plusMinusBis1000, position: 1, gangart: .trab,
            pfad: Turnierpfade.klasse3, geschafft: [],
            gangarten: [:], using: &rng
        )
        #expect(quelle == nil)
    }

    @Test("Stationen ohne Mix wiederholen nie")
    func ohneMix() {
        var rng = SeedRNG(seed: 17)
        let (_, quelle) = AufgabenPlaner.aufgabe(
            fuer: .malreihen, position: 1, gangart: .trab,
            pfad: Turnierpfade.klasse3, geschafft: [.aufwaermenBis100],
            gangarten: [:], using: &rng
        )
        #expect(quelle == nil)
    }

    @Test("Keine Frage doppelt in einer Runde (kleiner Zahlenraum)", arguments: Gangart.allCases)
    func keineDoppler(gangart: Gangart) {
        var rng = SeedRNG(seed: 23)
        // 20 Runden à 5 Aufgaben in der Station mit dem kleinsten Fragenpool:
        for _ in 1...20 {
            var gestellt: Set<String> = []
            for position in 0..<Turnierpfade.klasse1.aufgabenProRunde {
                let (aufgabe, _) = AufgabenPlaner.aufgabe(
                    fuer: .zerlegenErgaenzen, position: position, gangart: gangart,
                    pfad: Turnierpfade.klasse1, geschafft: [], gangarten: [:],
                    vermeideFragen: gestellt, using: &rng
                )
                #expect(!gestellt.contains(aufgabe.frage), "Doppelte Frage: \(aufgabe.frage)")
                gestellt.insert(aufgabe.frage)
            }
        }
    }

    @Test("Gleicher Seed erzeugt exakt den gleichen Rundenplan")
    func reproduzierbarkeit() {
        var rng1 = SeedRNG(seed: 7)
        var rng2 = SeedRNG(seed: 7)
        let geschafft: Set<MatheStation> = [.aufwaermenBis100, .malreihen]
        for position in 0..<5 {
            let (a1, q1) = AufgabenPlaner.aufgabe(
                fuer: .divisionMitRest, position: position, gangart: .trab,
                pfad: Turnierpfade.klasse3, geschafft: geschafft,
                gangarten: [.aufwaermenBis100: .trab], using: &rng1
            )
            let (a2, q2) = AufgabenPlaner.aufgabe(
                fuer: .divisionMitRest, position: position, gangart: .trab,
                pfad: Turnierpfade.klasse3, geschafft: geschafft,
                gangarten: [.aufwaermenBis100: .trab], using: &rng2
            )
            #expect(a1 == a2)
            #expect(q1 == q2)
        }
    }
}
