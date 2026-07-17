//
//  Elternschranke.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Parental Gate für die Kids-Kategorie (App-Review-Guideline 1.3):
//  Bevor etwas die App verlässt (Teilen-Menü), muss ein Erwachsener eine
//  Aufgabe lösen, die über dem Volksschul-Niveau liegt: zweistellig mal
//  zweistellig, in Worten ausgeschrieben (schützt auch vor Mitlesen und
//  Taschenrechner-Abtippen). Die Schranke lässt sich nicht deaktivieren
//  und merkt sich nichts – sie gilt bei jedem Öffnen neu.
//

import SwiftUI

// MARK: - Aufgabe

struct SchrankenAufgabe {
    let frageInWorten: String
    let antwort: Int

    static func neue() -> SchrankenAufgabe {
        let a = Int.random(in: 23...79)
        let b = Int.random(in: 12...29)
        return SchrankenAufgabe(
            frageInWorten: "Wie viel ist \(zahlwort(a)) mal \(zahlwort(b))?",
            antwort: a * b
        )
    }

    /// Deutsches Zahlwort für 10–99, z. B. 34 → „vierunddreißig".
    static func zahlwort(_ n: Int) -> String {
        let einer = ["", "ein", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun"]
        let besondere = [10: "zehn", 11: "elf", 12: "zwölf", 13: "dreizehn", 14: "vierzehn",
                         15: "fünfzehn", 16: "sechzehn", 17: "siebzehn", 18: "achtzehn", 19: "neunzehn"]
        if let wort = besondere[n] { return wort }
        let zehner = ["", "", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig"]
        let z = n / 10
        let e = n % 10
        if e == 0 { return zehner[z] }
        return "\(einer[e])und\(zehner[z])"
    }
}

// MARK: - Die Schranke

/// Sheet, das erst nach gelöster Erwachsenen-Aufgabe `onFreigabe` ruft.
struct ElternschrankeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onFreigabe: () -> Void

    @State private var aufgabe = SchrankenAufgabe.neue()
    @State private var eingabe = ""
    @State private var fehlversuch = false

    var body: some View {
        VStack(spacing: 16) {
            Text("🔒").font(.system(size: 44))
            Text("Frag bitte einen Erwachsenen!")
                .font(.title3.bold())
            Text("Damit nichts ohne Mama oder Papa verschickt wird, ist hier eine Aufgabe für Große:")
                .font(.subheadline)
                .foregroundStyle(Palette.soft)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(aufgabe.frageInWorten)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(eingabe.isEmpty ? "…" : eingabe)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .frame(minWidth: 110)
                .padding(.vertical, 4)
                .background(Palette.sun.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(Palette.ink)

            if fehlversuch {
                Text("Das war nicht richtig – neue Aufgabe!")
                    .font(.caption.bold())
                    .foregroundStyle(Palette.coral)
            }

            schrankenNumpad

            Button("Abbrechen") { dismiss() }
                .font(.subheadline)
                .foregroundStyle(Palette.soft)
        }
        .padding(.vertical, 24)
        .presentationDetents([.large])
    }

    private var schrankenNumpad: some View {
        VStack(spacing: 8) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { reihe in
                HStack(spacing: 8) {
                    ForEach(reihe, id: \.self) { z in taste("\(z)") { tippe("\(z)") } }
                }
            }
            HStack(spacing: 8) {
                taste("⌫") { if !eingabe.isEmpty { eingabe.removeLast() } }
                taste("0") { tippe("0") }
                taste("✓", betont: true) { pruefe() }
            }
        }
        .padding(.horizontal, 40)
    }

    private func taste(_ label: String, betont: Bool = false, aktion: @escaping () -> Void) -> some View {
        Button(action: aktion) {
            Text(label)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(betont ? Palette.grass : Color.gray.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(betont ? .white : Palette.ink)
        }
    }

    private func tippe(_ ziffer: String) {
        guard eingabe.count < 5 else { return }
        eingabe += ziffer
    }

    private func pruefe() {
        guard let zahl = Int(eingabe) else { return }
        if zahl == aufgabe.antwort {
            dismiss()
            onFreigabe()
        } else {
            // Falsche Antwort: neue Aufgabe, kein Durchprobieren möglich.
            aufgabe = SchrankenAufgabe.neue()
            eingabe = ""
            fehlversuch = true
        }
    }
}
