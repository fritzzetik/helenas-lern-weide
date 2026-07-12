//
//  BrunoErklaerungsTests.swift
//  Helenas Lern-Weide 🐶🐴 – Modul Mathe – Tests
//
//  Framework: Swift Testing (Xcode 16+/26, `import Testing`)
//
//  Aufbau:
//  1. Fixtures            – Beispielaufgaben zum Testen
//  2. Fehlerbild-Tests    – regelbasierte Fehleranalyse (parametrisiert)
//  3. Service-Tests       – mit Mock-LLM: Fallback, Quercheck-Gangart
//  4. Textqualitäts-Check – wiederverwendbarer Prüfer für Bruno-Texte
//                           (Satzanzahl, verbotene Wörter, Ziffern-Check)
//  5. Live-LLM-Tests      – laufen NUR auf Geräten mit Apple Intelligence,
//                           schicken echte Fehlerfälle durchs Modell
//
//  Ausführen:  ⌘U in Xcode, oder gezielt:
//    xcodebuild test -only-testing:MatheWeideTests/FehlerbildTests
//  Live-Tests überspringen sich selbst, wenn kein Modell verfügbar ist.
//

import Testing
import Foundation
@testable import MatheWeide   // ← an deinen Modulnamen anpassen!

// MARK: - 1. Fixtures

enum Fixture {

    /// Baut eine Aufgabe inkl. rekursivem Quercheck-Generator.
    /// Der Quercheck merkt sich die Gangart, mit der er erzeugt wurde –
    /// so können Tests prüfen, ob wirklich „eine Gangart gemütlicher“ gilt.
    static func aufgabe(
        frage: String = "47 : 5 = ?  Rest ?",
        antwortText: String = "9, Rest 2",
        thema: String = "Division mit Rest",
        hinweis: String = "Such die größte Zahl der 5er-Reihe, die noch in 47 passt.",
        gangart: Int = 1
    ) -> BrunoAufgabe {
        BrunoAufgabe(
            frage: frage,
            antwortText: antwortText,
            thema: thema,
            hinweis: hinweis,
            gangart: gangart,
            neueAehnlicheAufgabe: { neueGangart in
                Fixture.aufgabe(
                    frage: "QUERCHECK",
                    antwortText: antwortText,
                    thema: thema,
                    hinweis: hinweis,
                    gangart: neueGangart
                )
            }
        )
    }

    static let umwandlung = aufgabe(
        frage: "3 kg = ? dag",
        antwortText: "300",
        thema: "Gewichte umwandeln",
        hinweis: "1 kg sind 100 dag.",
        gangart: 0
    )

    static let plusMinus = aufgabe(
        frage: "347 + 285 = ?",
        antwortText: "632",
        thema: "Plus und Minus im Zahlenraum 1000",
        hinweis: "Rechne zuerst die Hunderter, dann die Zehner, dann die Einer.",
        gangart: 2
    )
}

// MARK: - 2. Fehlerbild-Tests (regelbasiert, parametrisiert)

@Suite("Fehlerbild-Analyse")
struct FehlerbildTests {

    @Test("Um 1 daneben wird erkannt", arguments: [(45, 44), (45, 46), (100, 99)])
    func umEinsDaneben(fall: (richtig: Int, eingabe: Int)) {
        let f = Fehlerbild.analysiere(
            richtig: fall.richtig, eingabe: fall.eingabe, aufgabe: Fixture.aufgabe()
        )
        #expect(f == .umEinsDaneben)
    }

    @Test("Stellenwertfehler wird erkannt", arguments: [(300, 30), (30, 300), (5, 500), (500, 5)])
    func stellenwert(fall: (richtig: Int, eingabe: Int)) {
        let f = Fehlerbild.analysiere(
            richtig: fall.richtig, eingabe: fall.eingabe, aufgabe: Fixture.aufgabe()
        )
        #expect(f == .stellenwertFehler)
    }

    @Test("Einheit nicht umgerechnet: Kind tippt die Ausgangszahl ab")
    func einheitNichtUmgerechnet() {
        // Aufgabe "3 kg = ? dag", richtig 300, Kind tippt 3
        let f = Fehlerbild.analysiere(richtig: 300, eingabe: 3, aufgabe: Fixture.umwandlung)
        // Achtung: 3 → 300 ist AUCH ein Zehnerpotenz-Verhältnis (×100).
        // Die Analyse priorisiert Stellenwert – beides ist hier vertretbar,
        // der Test dokumentiert das gewollte Verhalten:
        #expect(f == .stellenwertFehler || f == .einheitNichtUmgerechnet)
    }

    @Test("Völlig anderer Wert bei Plus-Aufgabe → Rechenrichtung geprüft")
    func rechenrichtung() {
        // 347 + 285 = 632, Kind rechnet 347 − 285 = 62 → kein Zehnerpotenz-Muster
        let f = Fehlerbild.analysiere(richtig: 632, eingabe: 62, aufgabe: Fixture.plusMinus)
        #expect(f == .rechenrichtungVertauscht)
    }
}

// MARK: - 3. Service-Tests mit Mock-LLM

/// Mock: liefert einen festen Text oder wirft einen Fehler.
struct MockFormulierer: TextFormulierer {
    var text: String = "Mock-Erklärung von Bruno. 🐶"
    var wirftFehler: Bool = false

    struct MockFehler: Error {}

    func formuliere(aufgabe: BrunoAufgabe, falscheEingabe: Int, fehlerbild: Fehlerbild) async throws -> String {
        if wirftFehler { throw MockFehler() }
        return text
    }
}

@Suite("BrunoErklaerungsService")
@MainActor
struct ServiceTests {

    @Test("LLM verfügbar → Erklärung kommt vom Modell")
    func llmWirdGenutzt() async {
        let service = BrunoErklaerungsService(formulierer: MockFormulierer())
        let antwort = await service.erklaere(
            aufgabe: Fixture.aufgabe(), falscheEingabe: 8, richtigeAntwort: 9,
            llmErlaubt: true
        )
        #expect(antwort.quelle == .onDeviceLLM)
        #expect(antwort.erklaerung == "Mock-Erklärung von Bruno. 🐶")
    }

    @Test("LLM wirft Fehler → lautloser Fallback, Kind merkt nichts")
    func fallbackBeiFehler() async {
        let service = BrunoErklaerungsService(formulierer: MockFormulierer(wirftFehler: true))
        let antwort = await service.erklaere(
            aufgabe: Fixture.aufgabe(), falscheEingabe: 8, richtigeAntwort: 9,
            llmErlaubt: true
        )
        #expect(antwort.quelle == .regelbasiert)
        #expect(antwort.erklaerung.contains("Bruno glaubt an dich"))
    }

    @Test("Kein Apple Intelligence → regelbasierte Erklärung")
    func fallbackOhneLLM() async {
        let service = BrunoErklaerungsService(formulierer: MockFormulierer())
        let antwort = await service.erklaere(
            aufgabe: Fixture.aufgabe(), falscheEingabe: 8, richtigeAntwort: 9,
            llmErlaubt: false
        )
        #expect(antwort.quelle == .regelbasiert)
    }

    @Test("Quercheck ist eine Gangart gemütlicher")
    func quercheckGangart() async {
        let service = BrunoErklaerungsService(formulierer: MockFormulierer())
        let antwort = await service.erklaere(
            aufgabe: Fixture.aufgabe(gangart: 2), falscheEingabe: 8, richtigeAntwort: 9,
            llmErlaubt: false
        )
        #expect(antwort.quercheck.gangart == 1)
    }

    @Test("Quercheck-Gangart geht nie unter 0 (Schritt bleibt Schritt)")
    func quercheckMinimum() async {
        let service = BrunoErklaerungsService(formulierer: MockFormulierer())
        let antwort = await service.erklaere(
            aufgabe: Fixture.aufgabe(gangart: 0), falscheEingabe: 8, richtigeAntwort: 9,
            llmErlaubt: false
        )
        #expect(antwort.quercheck.gangart == 0)
    }

    @Test("Fallback-Erklärung enthält immer den Merksatz des Generators")
    func fallbackEnthaeltHinweis() {
        for fehlerbild in Fehlerbild.allCases {
            let text = BrunoErklaerungsService.fallbackErklaerung(
                aufgabe: Fixture.umwandlung, fehlerbild: fehlerbild
            )
            #expect(text.contains("1 kg sind 100 dag."))
        }
    }
}

// MARK: - 4. Textqualitäts-Prüfer (für Fallback UND Live-LLM)

enum TextQualitaet {

    static let verboteneWoerter = [
        "Möhre", "Tüte", "Januar", "Februar", // bundesdeutsch (Jänner/Feber!)
        "dumm", "falsch gemacht", "leider",   // tadelnder Ton
        "Sie ",                               // Sie-Form statt Du-Form
    ]

    /// Zerlegt in Sätze (Emoji & Auslassungspunkte werden ignoriert).
    static func satzAnzahl(_ text: String) -> Int {
        text.replacingOccurrences(of: "…", with: ".")
            .split(whereSeparator: { ".!?".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 1 }
            .count
    }

    /// Ziffern-Check: Jede mehrstellige Zahl in der Erklärung muss aus dem
    /// Prompt-Kontext stammen (Aufgabe, Antwort, Eingabe, Hinweis).
    /// So fliegt jede „erfundene Rechnung“ des Modells automatisch auf.
    static func alleZahlenBekannt(text: String, aufgabe: BrunoAufgabe, eingabe: Int) -> Bool {
        let kontext = "\(aufgabe.frage) \(aufgabe.antwortText) \(aufgabe.hinweis) \(eingabe)"
        let erlaubt = Set(zahlen(in: kontext))
        // Einstellige Zahlen (1–10) sind als Füllwörter ok („zwei Nullen“ etc.)
        let gefunden = zahlen(in: text).filter { $0.count >= 2 }
        return gefunden.allSatisfy { erlaubt.contains($0) }
    }

    private static func zahlen(in text: String) -> [String] {
        text.replacingOccurrences(of: ".", with: "")   // 45.230 → 45230
            .matches(of: /\d+/)
            .map { String($0.output) }
    }

    /// Der Gesamt-Check – wirft aussagekräftige #expect-Fehler.
    static func pruefe(_ text: String, aufgabe: BrunoAufgabe, eingabe: Int) {
        #expect(!text.isEmpty, "Erklärung ist leer")
        #expect(satzAnzahl(text) <= 4, "Zu lang (\(satzAnzahl(text)) Sätze): \(text)")
        for wort in verboteneWoerter {
            #expect(!text.contains(wort), "Verbotenes Wort „\(wort)“ in: \(text)")
        }
        #expect(
            alleZahlenBekannt(text: text, aufgabe: aufgabe, eingabe: eingabe),
            "Erfundene Zahl in: \(text)"
        )
    }
}

@Suite("Textqualität des Fallbacks")
struct FallbackQualitaetTests {

    @Test("Alle Fallback-Erklärungen bestehen den Qualitäts-Check")
    func fallbackQualitaet() {
        for fehlerbild in Fehlerbild.allCases {
            let text = BrunoErklaerungsService.fallbackErklaerung(
                aufgabe: Fixture.umwandlung, fehlerbild: fehlerbild
            )
            TextQualitaet.pruefe(text, aufgabe: Fixture.umwandlung, eingabe: 3)
        }
    }
}

// MARK: - 5. Live-LLM-Tests (nur mit Apple Intelligence)

import FoundationModels

extension Tag {
    @Tag static var liveLLM: Self
}

/// Läuft nur, wenn das On-Device-Modell wirklich verfügbar ist –
/// sonst wird die ganze Suite sauber übersprungen (kein Fehlschlag).
@Suite(
    "Live: echtes On-Device-Modell",
    .tags(.liveLLM),
    .enabled(if: {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }())
)
@MainActor
struct LiveLLMTests {

    /// Typische Fehlerfälle quer durch beide Ställe.
    static let faelle: [(BrunoAufgabe, eingabe: Int, richtig: Int)] = [
        (Fixture.aufgabe(), 8, 9),                                    // Division mit Rest
        (Fixture.umwandlung, 3, 300),                                 // Einheit vergessen
        (Fixture.plusMinus, 62, 632),                                 // Rechenrichtung
        (Fixture.aufgabe(frage: "7 · 8 = ?", antwortText: "56",
                         thema: "Malreihe von 7",
                         hinweis: "Denk an die 7er-Reihe.", gangart: 1), 54, 56),
        (Fixture.aufgabe(frage: "Runde 4.683 auf Hunderter.", antwortText: "4.700",
                         thema: "Auf Hunderter runden",
                         hinweis: "Schau auf die Zehnerstelle: 0–4 abrunden, 5–9 aufrunden.",
                         gangart: 1), 4600, 4700),
    ]

    @Test("Modell-Erklärungen bestehen den Qualitäts-Check", arguments: Self.faelle.indices)
    func liveQualitaet(index: Int) async throws {
        let (aufgabe, eingabe, richtig) = Self.faelle[index]
        let service = BrunoErklaerungsService()   // echtes LLM

        let start = ContinuousClock.now
        let antwort = await service.erklaere(
            aufgabe: aufgabe, falscheEingabe: eingabe, richtigeAntwort: richtig
        )
        let dauer = start.duration(to: .now)

        #expect(antwort.quelle == .onDeviceLLM, "Fallback statt LLM – Modell nicht bereit?")
        TextQualitaet.pruefe(antwort.erklaerung, aufgabe: aufgabe, eingabe: eingabe)

        // Latenz-Wächter: > 6 s wäre selbst ohne prewarm() zu träge für ein
        // ADHS-Kind. (Erster Aufruf lädt das Modell – deshalb großzügig.)
        #expect(dauer < .seconds(6), "Zu langsam: \(dauer)")

        // Zum manuellen Gegenlesen im Test-Log:
        print("🐶 Bruno sagt: \(antwort.erklaerung)")
    }

    @Test("prewarm() beschleunigt den zweiten Aufruf")
    func prewarmWirkt() async {
        let service = BrunoErklaerungsService()
        service.aufwaermen()
        try? await Task.sleep(for: .seconds(2))   // Modell laden lassen

        let start = ContinuousClock.now
        _ = await service.erklaere(
            aufgabe: Fixture.aufgabe(), falscheEingabe: 8, richtigeAntwort: 9
        )
        let dauer = start.duration(to: .now)
        #expect(dauer < .seconds(4), "Trotz prewarm zu langsam: \(dauer)")
    }
}
