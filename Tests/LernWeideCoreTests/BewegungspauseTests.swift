// BewegungspauseTests.swift
import Testing
@testable import LernWeideCore

@Suite("Bewegungspause (verpflichtend)")
struct BewegungspauseTests {

    @Test("Dauert genau 180 Sekunden und ist erst danach vorbei")
    func ablauf() {
        var pause = Bewegungspause()
        #expect(!pause.istVorbei)
        #expect(pause.verbleibendeSekunden == 180)
        for _ in 1...179 { pause.tick() }
        #expect(!pause.istVorbei)
        #expect(pause.verbleibendeSekunden == 1)
        pause.tick()
        #expect(pause.istVorbei)
    }

    @Test("Weitere Ticks nach Ablauf ändern nichts")
    func stabilNachAblauf() {
        var pause = Bewegungspause()
        for _ in 1...500 { pause.tick() }
        #expect(pause.verbleibendeSekunden == 0)
        #expect(pause.istVorbei)
    }

    @Test("Hintergrund-Zeit wird auf einmal nachgeholt")
    func nachholenNachHintergrund() {
        var pause = Bewegungspause()
        pause.verstreiche(sekunden: 100)
        #expect(pause.verbleibendeSekunden == 80)
        #expect(!pause.istVorbei)
        pause.verstreiche(sekunden: 500) // länger gesperrt als die Pause dauert
        #expect(pause.verbleibendeSekunden == 0)
        #expect(pause.istVorbei)
    }

    @Test("Negative Nachholzeit wird ignoriert")
    func negativeZeit() {
        var pause = Bewegungspause()
        pause.verstreiche(sekunden: -30)
        #expect(pause.verbleibendeSekunden == 180)
    }
}
