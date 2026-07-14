// RundeTests.swift
import Testing
@testable import LernWeideCore

@Suite("Runde und Schleife 🎀")
struct RundeTests {

    @Test("Standard-Runde: 10 Aufgaben, Schleife ab 8 Sternen (80 %)")
    func standardLaenge() {
        let runde = Runde()
        #expect(runde.aufgabenProRunde == 10)
        #expect(runde.schleifeMinSterne == 8)
    }

    @Test("Kurze Runde (1./2. Klasse): 5 Aufgaben, Schleife ab 4 Sternen")
    func kurzeRunde() {
        var runde = Runde(gangart: .trab, aufgabenProRunde: 5)
        #expect(runde.schleifeMinSterne == 4)
        runde.verarbeite(.erklaert)                       // kein Stern
        for _ in 1...4 { runde.verarbeite(.zweitversuch) } // 4 Sterne, Tempo bleibt Trab
        #expect(runde.istFertig)
        #expect(runde.sterne == 4)
        #expect(runde.gangart == .trab)
        #expect(runde.schleifeVerdient)
    }

    @Test("Perfekte Runde ab Schritt: 10 Sterne, endet im Galopp, Schleife verdient")
    func perfekteRunde() {
        var runde = Runde(gangart: .schritt)
        for _ in 1...10 { runde.verarbeite(.erstversuch) }
        #expect(runde.istFertig)
        #expect(runde.sterne == 10)
        #expect(runde.gangart == .galopp) // nach 2 Treffern Trab, nach 4 Galopp
        #expect(runde.schleifeVerdient)
    }

    @Test("Viele Sterne nur im Schritt: keine Schleife")
    func schrittOhneSchleife() {
        var runde = Runde(gangart: .schritt)
        for _ in 1...9 { runde.verarbeite(.zweitversuch) } // Sterne ja, Tempo-Beweis nein
        runde.verarbeite(.erklaert)
        #expect(runde.istFertig)
        #expect(runde.sterne == 9)
        #expect(runde.gangart == .schritt)
        #expect(!runde.schleifeVerdient)
    }

    @Test("7 Sterne im Galopp: keine Schleife")
    func zuWenigSterne() {
        var runde = Runde(gangart: .galopp)
        // 7 Treffer, 3 Fehler – nie zwei Fehler in Folge, Galopp bleibt.
        let folge: [AntwortErgebnis] = [
            .erstversuch, .erklaert, .erstversuch, .erklaert, .erstversuch,
            .erklaert, .erstversuch, .erstversuch, .erstversuch, .erstversuch,
        ]
        for e in folge { runde.verarbeite(e) }
        #expect(runde.istFertig)
        #expect(runde.sterne == 7)
        #expect(runde.gangart == .galopp)
        #expect(!runde.schleifeVerdient)
    }

    @Test("Genau 8 Sterne im Trab reichen für die Schleife")
    func grenzfallSchleife() {
        var runde = Runde(gangart: .trab)
        // Fehler, dann Erstversuch (bricht die Fehler-Serie), dann 7 Zweitversuche
        // (kein Tempo-Beweis, kein Fehler), zum Schluss noch ein Fehler:
        runde.verarbeite(.erklaert)
        runde.verarbeite(.erstversuch)
        for _ in 1...7 { runde.verarbeite(.zweitversuch) }
        runde.verarbeite(.erklaert)
        #expect(runde.istFertig)
        #expect(runde.sterne == 8)
        #expect(runde.gangart == .trab)
        #expect(runde.schleifeVerdient)
    }

    @Test("Nach 10 Aufgaben ist Schluss – weitere Ergebnisse ändern nichts")
    func fertigIstFertig() {
        var runde = Runde(gangart: .trab)
        for _ in 1...10 { runde.verarbeite(.erstversuch) }
        let sterne = runde.sterne
        let gangart = runde.gangart
        runde.verarbeite(.erstversuch)
        #expect(runde.position == 10)
        #expect(runde.sterne == sterne)
        #expect(runde.gangart == gangart)
    }
}
