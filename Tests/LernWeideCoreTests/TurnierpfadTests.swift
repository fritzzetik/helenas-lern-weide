// TurnierpfadTests.swift
import Testing
@testable import LernWeideCore

@Suite("Turnierpfad-Freischaltung")
struct TurnierpfadTests {

    let pfad = Turnierpfad(stationen: ["a", "b", "c"])

    @Test("Am Anfang ist nur die erste Station offen")
    func start() {
        #expect(pfad.status("a", geschafft: []) == .offen)
        #expect(pfad.status("b", geschafft: []) == .gesperrt)
        #expect(pfad.status("c", geschafft: []) == .gesperrt)
        #expect(pfad.naechsteOffene(geschafft: []) == "a")
    }

    @Test("Eine Schleife öffnet die nächste Station")
    func freischalten() {
        let geschafft: Set = ["a"]
        #expect(pfad.status("a", geschafft: geschafft) == .geschafft)
        #expect(pfad.status("b", geschafft: geschafft) == .offen)
        #expect(pfad.status("c", geschafft: geschafft) == .gesperrt)
        #expect(pfad.naechsteOffene(geschafft: geschafft) == "b")
    }

    @Test("Geschaffte Stationen bleiben geschafft, auch mit Lücke davor")
    func geschafftBleibt() {
        // "b" wurde geschafft, "a" (noch) nicht – "b" bleibt geschafft, "c" wird offen.
        let geschafft: Set = ["b"]
        #expect(pfad.status("a", geschafft: geschafft) == .offen)
        #expect(pfad.status("b", geschafft: geschafft) == .geschafft)
        #expect(pfad.status("c", geschafft: geschafft) == .offen)
    }

    @Test("Alle geschafft: keine offene Station mehr")
    func allesGeschafft() {
        let geschafft: Set = ["a", "b", "c"]
        #expect(pfad.naechsteOffene(geschafft: geschafft) == nil)
    }

    @Test("Unbekannte Station ist gesperrt")
    func unbekannt() {
        #expect(pfad.status("x", geschafft: ["a"]) == .gesperrt)
    }
}
