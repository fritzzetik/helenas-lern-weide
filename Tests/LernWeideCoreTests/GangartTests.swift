// GangartTests.swift
import Foundation
import Testing
@testable import LernWeideCore

extension Tag {
    /// Tests, die ein Gerät mit Apple Intelligence brauchen – auf CI übersprungen.
    @Tag static var liveLLM: Tag
}

@Suite("Gangarten-Anpassung")
struct GangartTests {

    @Test("2 Erstversuch-Treffer in Folge stufen von Schritt auf Trab hoch (wie im Prototyp)")
    func hochstufen() {
        var tracker = GangartTracker(start: .schritt)
        tracker.verarbeite(richtig: true)
        let geaendert = tracker.verarbeite(richtig: true)
        #expect(geaendert)
        #expect(tracker.gangart == .trab)
    }

    @Test("2 falsche Antworten in Folge stufen von Trab auf Schritt runter")
    func runterstufen() {
        var tracker = GangartTracker(start: .trab)
        tracker.verarbeite(richtig: false)
        let geaendert = tracker.verarbeite(richtig: false)
        #expect(geaendert)
        #expect(tracker.gangart == .schritt)
    }

    @Test("Galopp bleibt Galopp – keine Stufe darüber")
    func obergrenze() {
        var tracker = GangartTracker(start: .galopp)
        for _ in 1...6 { tracker.verarbeite(richtig: true) }
        #expect(tracker.gangart == .galopp)
    }

    @Test("Schritt bleibt Schritt – keine Stufe darunter")
    func untergrenze() {
        var tracker = GangartTracker(start: .schritt)
        for _ in 1...6 { tracker.verarbeite(richtig: false) }
        #expect(tracker.gangart == .schritt)
    }

    @Test("Eine falsche Antwort setzt die Richtig-Serie zurück")
    func serienReset() {
        var tracker = GangartTracker(start: .schritt)
        tracker.verarbeite(richtig: true)
        tracker.verarbeite(richtig: false)
        tracker.verarbeite(richtig: true)
        // Erst der zweite Treffer NACH dem Fehler darf hochstufen
        #expect(tracker.gangart == .schritt)
        tracker.verarbeite(richtig: true)
        #expect(tracker.gangart == .trab)
    }

    @Test("Zweitversuch bricht die Tempo-Serie, zählt aber nicht als Fehler")
    func zweitversuch() {
        var tracker = GangartTracker(start: .trab)
        tracker.verarbeite(.erstversuch)
        tracker.verarbeite(.zweitversuch) // Serie bricht
        tracker.verarbeite(.erstversuch)
        #expect(tracker.gangart == .trab) // noch kein zweiter Treffer in Folge
        tracker.verarbeite(.erstversuch)
        #expect(tracker.gangart == .galopp)

        var nurZweitversuche = GangartTracker(start: .trab)
        for _ in 1...5 { nurZweitversuche.verarbeite(.zweitversuch) }
        #expect(nurZweitversuche.gangart == .trab) // stuft weder hoch noch runter
    }

    @Test("Fehler-Serie überlebt einen Zweitversuch (wie im Prototyp)")
    func fehlerSerieUeberlebtZweitversuch() {
        var tracker = GangartTracker(start: .galopp)
        tracker.verarbeite(.erklaert)
        tracker.verarbeite(.zweitversuch)
        let geaendert = tracker.verarbeite(.erklaert)
        #expect(geaendert)
        #expect(tracker.gangart == .trab)
    }

    // Beispiel für einen Live-LLM-Test: läuft nur lokal, nie auf GitHub Actions
    // (dort ist die Umgebungsvariable CI=true gesetzt).
    @Test(
        "Platzhalter: Bruno-Erklärung via Foundation Models",
        .tags(.liveLLM),
        .enabled(if: ProcessInfo.processInfo.environment["CI"] == nil)
    )
    func liveLLMPlatzhalter() {
        // Hier kommt später der Live-Test mit dem Foundation Models Framework hin.
        #expect(Bool(true))
    }
}
