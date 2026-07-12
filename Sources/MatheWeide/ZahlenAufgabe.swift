// ZahlenAufgabe.swift
// Gemeinsames Modell für alle Aufgaben mit genau einer ganzzahligen Antwort.
// Alle Antworten werden hier deterministisch berechnet. Das LLM erklärt nur, es rechnet NIE.

import Foundation

/// Eine Aufgabe mit genau einer ganzzahligen Antwort (Frage, Lösung, Thema, Hinweis).
public struct ZahlenAufgabe: Equatable, Sendable {
    /// Aufgabentext, z. B. „34 + 5 = ?"
    public let frage: String
    /// Die korrekte Antwort – deterministisch im Code berechnet.
    public let antwort: Int
    /// Kurzbezeichnung des Themas – für Fortschritt und Bruno-Erklärungen.
    public let thema: String
    /// Kindgerechter Lösungshinweis (österreichisches Deutsch).
    public let hinweis: String

    public init(frage: String, antwort: Int, thema: String, hinweis: String) {
        self.frage = frage
        self.antwort = antwort
        self.thema = thema
        self.hinweis = hinweis
    }

    /// Antwort mit Tausenderpunkt, z. B. „1.000" (österreichische Schreibweise).
    public var antwortText: String { antwort.mitTausenderpunkt }

    /// Prüft eine Kinderantwort.
    public func istRichtig(_ eingabe: Int) -> Bool {
        eingabe == antwort
    }
}

extension Int {
    /// Formatiert mit Tausenderpunkt (de-AT), bewusst ohne Locale – rein deterministisch.
    var mitTausenderpunkt: String {
        var ziffern = Array(String(Swift.abs(self)))
        var gruppen: [String] = []
        while ziffern.count > 3 {
            gruppen.insert(String(ziffern.suffix(3)), at: 0)
            ziffern.removeLast(3)
        }
        gruppen.insert(String(ziffern), at: 0)
        return (self < 0 ? "-" : "") + gruppen.joined(separator: ".")
    }
}
