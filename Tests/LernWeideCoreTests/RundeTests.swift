// RundeTests.swift
import Testing
@testable import LernWeideCore

@Suite("Runde und Schleife 🎀")
struct RundeTests {

    @Test("Perfekte Runde ab Schritt: 5 Sterne, endet im Galopp, Schleife verdient")
    func perfekteRunde() {
        var runde = Runde(gangart: .schritt)
        for _ in 1...5 { runde.verarbeite(.erstversuch) }
        #expect(runde.istFertig)
        #expect(runde.sterne == 5)
        #expect(runde.gangart == .galopp) // nach 2 Treffern Trab, nach 4 Galopp
        #expect(runde.schleifeVerdient)
    }

    @Test("4 Sterne nur im Schritt: keine Schleife")
    func schrittOhneSchleife() {
        var runde = Runde(gangart: .schritt)
        for _ in 1...4 { runde.verarbeite(.zweitversuch) } // Sterne ja, Tempo-Beweis nein
        runde.verarbeite(.erklaert)
        #expect(runde.istFertig)
        #expect(runde.sterne == 4)
        #expect(runde.gangart == .schritt)
        #expect(!runde.schleifeVerdient)
    }

    @Test("3 Sterne im Galopp: keine Schleife")
    func zuWenigSterne() {
        var runde = Runde(gangart: .galopp)
        runde.verarbeite(.erstversuch)
        runde.verarbeite(.erklaert)
        runde.verarbeite(.erstversuch)
        runde.verarbeite(.erklaert)
        runde.verarbeite(.erstversuch)
        #expect(runde.istFertig)
        #expect(runde.sterne == 3)
        #expect(!runde.schleifeVerdient)
    }

    @Test("Genau 4 Sterne im Trab reichen für die Schleife")
    func grenzfallSchleife() {
        var runde = Runde(gangart: .trab)
        runde.verarbeite(.erklaert) // kein Stern
        for _ in 1...4 { runde.verarbeite(.zweitversuch) }
        #expect(runde.istFertig)
        #expect(runde.sterne == 4)
        #expect(runde.gangart == .trab)
        #expect(runde.schleifeVerdient)
    }

    @Test("Nach 5 Aufgaben ist Schluss – weitere Ergebnisse ändern nichts")
    func fertigIstFertig() {
        var runde = Runde(gangart: .trab)
        for _ in 1...5 { runde.verarbeite(.erstversuch) }
        let sterne = runde.sterne
        let gangart = runde.gangart
        runde.verarbeite(.erstversuch)
        #expect(runde.position == 5)
        #expect(runde.sterne == sterne)
        #expect(runde.gangart == gangart)
    }
}
