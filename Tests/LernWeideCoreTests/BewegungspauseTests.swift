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
}
