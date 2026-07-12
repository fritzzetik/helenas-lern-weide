//
//  BrunoErklaerungsService.swift  (v2 – testbar)
//  Helenas Lern-Weide 🐶🐴 – Modul Mathe
//
//  Änderungen gegenüber v1:
//  - Die LLM-Formulierung liegt hinter dem Protokoll `TextFormulierer`
//    → in Unit-Tests kann ein Mock injiziert werden, ohne echtes Modell.
//  - `fallbackErklaerung` ist jetzt eine interne statische Funktion
//    → direkt testbar.
//  - Sonst identisch zu v1 (Prinzip: Code rechnet, LLM formuliert nur).
//

import Foundation
import FoundationModels

// MARK: - Datenmodelle

struct BrunoAufgabe {
    let frage: String          // "47 : 5 = ?  Rest ?"
    let antwortText: String    // "9, Rest 2"
    let thema: String          // "Division mit Rest"
    let hinweis: String        // regelbasierter Tipp aus dem Generator
    let gangart: Int           // 0 = Schritt, 1 = Trab, 2 = Galopp
    let neueAehnlicheAufgabe: (_ gangart: Int) -> BrunoAufgabe
}

struct BrunoAntwort {
    let erklaerung: String
    let quercheck: BrunoAufgabe    // vom Generator erzeugt, NICHT vom LLM
    let quelle: Quelle

    enum Quelle: Equatable { case onDeviceLLM, regelbasiert }
}

// MARK: - Regelbasierte Fehleranalyse

enum Fehlerbild: String, CaseIterable {
    case rechenrichtungVertauscht = "hat Plus und Minus (oder Mal und Geteilt) verwechselt"
    case stellenwertFehler        = "hat sich um eine Zehnerpotenz vertan (Stellenwertfehler)"
    case umEinsDaneben            = "war nur um 1 daneben (kleiner Zählfehler)"
    case einheitNichtUmgerechnet  = "hat die Einheit nicht umgerechnet, sondern die Zahl übernommen"
    case unbekannt                = "unbekanntes Fehlerbild"

    static func analysiere(richtig: Int, eingabe: Int, aufgabe: BrunoAufgabe) -> Fehlerbild {
        if abs(richtig - eingabe) == 1 { return .umEinsDaneben }
        if eingabe == richtig * 10 || eingabe * 10 == richtig
            || eingabe == richtig * 100 || eingabe * 100 == richtig {
            return .stellenwertFehler
        }
        if aufgabe.thema.contains("umwandeln") || aufgabe.thema.contains("Maße") {
            // Kind tippt die Ausgangszahl der Aufgabe einfach ab
            if aufgabe.frage.contains("\(eingabe) ") { return .einheitNichtUmgerechnet }
        }
        if aufgabe.frage.contains("−") || aufgabe.frage.contains("+") {
            return .rechenrichtungVertauscht
        }
        return .unbekannt
    }
}

// MARK: - Guided Generation

@Generable
struct BrunoText {
    @Guide(description: """
        Eine freundliche Mathe-Erklärung für ein Volksschulkind aus Wien.
        Genau 2 bis 3 sehr kurze Sätze. Du-Form. Niemals tadeln.
        Verwende Bruno (Hund) oder Daisy (Pferd) als Beispiel.
        Österreichisches Deutsch: Karotten (nie Möhren), Sackerl (nie Tüte),
        dag, In-Rechnung, Jänner. Keine neuen Rechnungen erfinden –
        nur die genannten Zahlen aus der Aufgabe verwenden.
        """)
    let erklaerung: String
}

// MARK: - Protokoll: macht das LLM in Tests austauschbar

protocol TextFormulierer: Sendable {
    func formuliere(
        aufgabe: BrunoAufgabe,
        falscheEingabe: Int,
        fehlerbild: Fehlerbild
    ) async throws -> String
}

/// Produktiv-Implementierung mit Apples On-Device-Modell.
struct LLMFormulierer: TextFormulierer {

    static let instructions = """
        You are Bruno, a friendly dog who helps Helena, a primary school \
        child from Vienna with ADHD, learn maths. You explain the underlying \
        concept behind a mistake. Always answer in German (Austrian German, \
        Vienna). Be warm, brief and encouraging. Never scold. Never invent \
        new calculations or numbers – only restate the numbers given to you.
        """

    func formuliere(
        aufgabe: BrunoAufgabe,
        falscheEingabe: Int,
        fehlerbild: Fehlerbild
    ) async throws -> String {
        let session = LanguageModelSession(instructions: Self.instructions)
        let prompt = """
            Aufgabe: "\(aufgabe.frage)"
            Richtige Antwort: \(aufgabe.antwortText)
            Helenas Antwort: \(falscheEingabe)
            Thema: \(aufgabe.thema)
            Vermutetes Fehlerbild: Helena \(fehlerbild.rawValue).
            Merksatz zum Thema: \(aufgabe.hinweis)

            Erkläre Helena das zugrundeliegende Wissen.
            """
        let antwort = try await session.respond(to: prompt, generating: BrunoText.self)
        return antwort.content.erklaerung
    }
}

// MARK: - Der Erklärungs-Service

@MainActor
final class BrunoErklaerungsService {

    private let formulierer: TextFormulierer

    /// Produktion: `BrunoErklaerungsService()` → nutzt das On-Device-LLM.
    /// Tests:      `BrunoErklaerungsService(formulierer: MockFormulierer(...))`
    init(formulierer: TextFormulierer = LLMFormulierer()) {
        self.formulierer = formulierer
    }

    var llmVerfuegbar: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }

    func aufwaermen() {
        guard llmVerfuegbar else { return }
        LanguageModelSession(instructions: LLMFormulierer.instructions).prewarm()
    }

    func erklaere(
        aufgabe: BrunoAufgabe,
        falscheEingabe: Int,
        richtigeAntwort: Int,
        llmErlaubt: Bool? = nil          // Tests können erzwingen
    ) async -> BrunoAntwort {

        let fehlerbild = Fehlerbild.analysiere(
            richtig: richtigeAntwort, eingabe: falscheEingabe, aufgabe: aufgabe
        )

        // Quercheck: gleicher Generator, eine Gangart gemütlicher, min. 0.
        let quercheck = aufgabe.neueAehnlicheAufgabe(max(0, aufgabe.gangart - 1))

        let darfLLM = llmErlaubt ?? llmVerfuegbar
        if darfLLM {
            do {
                let text = try await formulierer.formuliere(
                    aufgabe: aufgabe, falscheEingabe: falscheEingabe, fehlerbild: fehlerbild
                )
                return BrunoAntwort(erklaerung: text, quercheck: quercheck, quelle: .onDeviceLLM)
            } catch {
                // lautlos auf Fallback ausweichen
            }
        }
        return BrunoAntwort(
            erklaerung: Self.fallbackErklaerung(aufgabe: aufgabe, fehlerbild: fehlerbild),
            quercheck: quercheck,
            quelle: .regelbasiert
        )
    }

    // MARK: Regelbasierter Fallback (statisch → direkt testbar)

    static func fallbackErklaerung(aufgabe: BrunoAufgabe, fehlerbild: Fehlerbild) -> String {
        let einstieg: String
        switch fehlerbild {
        case .umEinsDaneben:
            einstieg = "Du warst nur ganz knapp daneben – so knapp wie Bruno an der Wurst! 🐶"
        case .stellenwertFehler:
            einstieg = "Schau auf die Nullen – da hat sich eine versteckt oder eine zu viel eingeschlichen."
        case .einheitNichtUmgerechnet:
            einstieg = "Die Zahl stimmt fast – aber die Einheit will noch umgerechnet werden!"
        case .rechenrichtungVertauscht:
            einstieg = "Schau nochmal aufs Rechenzeichen – Bruno verwechselt auch manchmal links und rechts. 🐾"
        case .unbekannt:
            einstieg = "Kein Problem, das schauen wir uns gemeinsam an!"
        }
        return "\(einstieg) Merk dir: \(aufgabe.hinweis) Bruno glaubt an dich! 🐶"
    }
}
