//
//  RundenView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Eine Runde = 5 Aufgaben. ADHS-freundlich: eine Aufgabe pro Bildschirm,
//  großes Numpad, sofortiges Lob, adaptive Gangart (GangartTracker aus dem
//  getesteten Package). Bei Fehlern erklärt Bruno (On-Device-LLM, sonst
//  regelbasierter Fallback – lautlos). Danach: Sterne, evtl. Schleife 🎀,
//  und auf Wunsch die 3-Minuten-Bewegungspause.
//

import SwiftUI
import SwiftData
import LernWeideCore

private let RUNDEN_LAENGE = 5
private let SCHLEIFE_MIN_STERNE = 4

struct RundenView: View {
    let station: Station

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var tracker = GangartTracker()
    @State private var aufgabe: AppAufgabe?
    @State private var aufgabeNr = 1
    @State private var feldIndex = 0
    @State private var eingaben: [String] = []
    @State private var sterne = 0
    @State private var lob: String?
    @State private var brunoText: String?
    @State private var fertig = false
    @State private var pause = false

    private let brunoService = BrunoErklaerungsService()

    var body: some View {
        NavigationStack {
            Group {
                if fertig { ergebnis }
                else if let a = aufgabe { aufgabenBildschirm(a) }
                else { ProgressView() }
            }
            .navigationTitle("\(station.emoji) \(tracker.gangart.anzeigename)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zur Weide") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Text("\(min(aufgabeNr, RUNDEN_LAENGE)) / \(RUNDEN_LAENGE)").monospacedDigit()
                }
            }
        }
        .onAppear { naechsteAufgabe(); brunoService.aufwaermen() }
        .sheet(item: $brunoText) { text in
            brunoSheet(text)
        }
        .fullScreenCover(isPresented: $pause) { BewegungspauseView() }
    }

    // MARK: Aufgabe

    @ViewBuilder
    private func aufgabenBildschirm(_ a: AppAufgabe) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Text(a.frage)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                ForEach(a.felder.indices, id: \.self) { i in
                    VStack {
                        Text(a.felder[i].label).font(.caption).foregroundStyle(.secondary)
                        Text(eingaben.indices.contains(i) && !eingaben[i].isEmpty ? eingaben[i] : "·")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .frame(minWidth: 90)
                            .padding(.vertical, 6)
                            .background(i == feldIndex ? Color.yellow.opacity(0.35) : Color.gray.opacity(0.12),
                                        in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }

            if let lob { Text(lob).font(.title3.bold()).transition(.scale) }

            Spacer()
            numpad
        }
        .padding()
    }

    private var numpad: some View {
        VStack(spacing: 10) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { reihe in
                HStack(spacing: 10) {
                    ForEach(reihe, id: \.self) { z in taste("\(z)") { tippe("\(z)") } }
                }
            }
            HStack(spacing: 10) {
                taste("⌫") { if !eingaben[feldIndex].isEmpty { eingaben[feldIndex].removeLast() } }
                taste("0") { tippe("0") }
                taste("✓", betont: true) { pruefe() }
            }
        }
    }

    private func taste(_ label: String, betont: Bool = false, aktion: @escaping () -> Void) -> some View {
        Button(action: aktion) {
            Text(label)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 62)
                .background(betont ? Color(red: 0.482, green: 0.714, blue: 0.384) : Color.gray.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(betont ? .white : .primary)
        }
    }

    private func tippe(_ ziffer: String) {
        guard eingaben[feldIndex].count < 6 else { return }
        eingaben[feldIndex] += ziffer
    }

    // MARK: Logik

    private func naechsteAufgabe() {
        let a = station.generator(tracker.gangart)
        aufgabe = a
        eingaben = Array(repeating: "", count: a.felder.count)
        feldIndex = 0
        lob = nil
    }

    private func pruefe() {
        guard let a = aufgabe else { return }
        // Erst alle Felder füllen lassen:
        if feldIndex < a.felder.count - 1, !eingaben[feldIndex].isEmpty {
            feldIndex += 1
            return
        }
        guard eingaben.allSatisfy({ !$0.isEmpty }) else { return }

        let richtig = zip(eingaben, a.felder).allSatisfy { Int($0) == $1.antwort }
        if richtig {
            sterne += 1
            lob = ["Super! ⭐️", "Toll gemacht! 🐴", "Bruno bellt vor Freude! 🐶", "Genau richtig! 🎉"].randomElement()
            tracker.verarbeite(richtig: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { weiter() }
        } else {
            tracker.verarbeite(richtig: false)
            let gangartVorher = tracker.gangart
            let eingabe = Int(eingaben[0]) ?? 0
            let mA = a.alsMatheAufgabe(gangart: gangartVorher, generator: station.generator)
            Task { @MainActor in
                let antwort = await brunoService.erklaere(
                    aufgabe: mA, falscheEingabe: eingabe, richtigeAntwort: a.felder[0].antwort
                )
                brunoText = "Richtig wäre: \(a.antwortText)\n\n\(antwort.erklaerung)"
            }
        }
    }

    private func weiter() {
        if aufgabeNr >= RUNDEN_LAENGE {
            rundeSpeichern()
            fertig = true
        } else {
            aufgabeNr += 1
            naechsteAufgabe()
        }
    }

    private func rundeSpeichern() {
        let schleife = sterne >= SCHLEIFE_MIN_STERNE && tracker.gangart >= .trab
        FortschrittsService(context: context).rundeBeendet(
            stationID: station.id,
            sterne: sterne,
            gangart: tracker.gangart.rawValue,
            schleifeGewonnen: schleife
        )
    }

    // MARK: Bruno-Sheet

    private func brunoSheet(_ text: String) -> some View {
        VStack(spacing: 18) {
            Text("🐶").font(.system(size: 60))
            Text("Bruno erklärt:").font(.headline)
            Text(text).font(.title3).multilineTextAlignment(.center).padding(.horizontal)
            Button {
                brunoText = nil
                weiter()
            } label: {
                Text("Alles klar, weiter!")
                    .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 0.482, green: 0.714, blue: 0.384), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }

    // MARK: Ergebnis

    private var ergebnis: some View {
        let schleife = sterne >= SCHLEIFE_MIN_STERNE && tracker.gangart >= .trab
        return VStack(spacing: 22) {
            Spacer()
            Text(schleife ? "🎀" : "🐴").font(.system(size: 90))
            Text(schleife ? "Schleife gewonnen!" : "Gute Trainingsrunde!")
                .font(.largeTitle.bold())
            Text(String(repeating: "⭐️", count: sterne) + String(repeating: "☆", count: RUNDEN_LAENGE - sterne))
                .font(.title)
            if !schleife {
                Text("Für die Schleife: mindestens \(SCHLEIFE_MIN_STERNE) Sterne im Trab oder Galopp. Du schaffst das!")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal)
            }
            Spacer()
            Button { pause = true } label: {
                Label("3 Minuten hüpfen mit Daisy", systemImage: "figure.jumprope")
                    .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 0.741, green: 0.890, blue: 0.941), in: RoundedRectangle(cornerRadius: 14))
            }
            Button { dismiss() } label: {
                Text("Zurück zur Weide")
                    .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 0.482, green: 0.714, blue: 0.384), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
        }
        .padding()
    }
}

// String als Identifiable fürs Sheet
extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Bewegungspause

struct BewegungspauseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var verbleibend = 180
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 26) {
            Spacer()
            Text("🐴").font(.system(size: 80))
            Text("Bewegungspause!").font(.largeTitle.bold())
            Text("Hüpf, tanz oder galoppier wie Daisy!")
                .font(.title3).foregroundStyle(.secondary)

            Text(String(format: "%d:%02d", verbleibend / 60, verbleibend % 60))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()

            ProgressView(value: Double(180 - verbleibend), total: 180)
                .tint(Color(red: 0.482, green: 0.714, blue: 0.384))
                .padding(.horizontal, 40)

            Spacer()
            Button("Fertig!") { dismiss() }
                .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                .background(Color(red: 0.482, green: 0.714, blue: 0.384), in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
                .padding()
        }
        .onReceive(timer) { _ in
            if verbleibend > 0 { verbleibend -= 1 } else { dismiss() }
        }
    }
}
