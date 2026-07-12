//
//  RundenView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Eine Runde = 5 Aufgaben, Ablauf identisch zum React-Prototyp:
//  1. Versuch richtig → Stern (Tempo-Beweis). 2. Versuch richtig → Stern.
//  Sonst erklärt Bruno (On-Device-LLM, lautloser Fallback) und es folgt
//  ein Quercheck – eine Gangart gemütlicher; richtig → Stern.
//  Die Spielregeln (Sterne, Gangart, Schleife) kommen aus `Runde` im
//  getesteten Package. Danach: verpflichtende 3-Minuten-Bewegungspause –
//  „Zurück zur Weide" erscheint erst, wenn sie vorbei ist.
//

import SwiftUI
import SwiftData
import LernWeideCore
import MatheWeide

private let gruen = Color(red: 0.482, green: 0.714, blue: 0.384)
private let himmelblau = Color(red: 0.741, green: 0.890, blue: 0.941)

struct RundenView: View {
    let station: MatheStation
    let pfad: Turnierpfad<MatheStation>

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private enum Phase { case frage, nochmal, quercheck }

    @State private var runde = Runde()
    @State private var phase: Phase = .frage
    @State private var aufgabe: AppAufgabe?
    @State private var wiederholungVon: MatheStation?
    @State private var feldIndex = 0
    @State private var eingaben: [String] = []
    @State private var lob: String?
    @State private var mutmacher: String?
    @State private var brunoText: String?
    @State private var fertig = false

    // Kontext für den Wiederholungs-Mix (einmal beim Start geladen).
    @State private var geschafft: Set<MatheStation> = []
    @State private var gangarten: [MatheStation: Gangart] = [:]

    private let brunoService = BrunoErklaerungsService()

    var body: some View {
        NavigationStack {
            Group {
                if fertig { ergebnis }
                else if let a = aufgabe { aufgabenBildschirm(a) }
                else { ProgressView() }
            }
            .navigationTitle("\(station.emoji) \(runde.gangart.anzeigename)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Nach der Runde führt nur noch der große Button unter dem
                // Pausen-Timer zurück – sonst gäbe es einen Seitenausgang
                // aus der Pflicht-Pause (der dann doch in der Warteschleife
                // endet, aber das verwirrt nur).
                if !fertig {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Zur Weide") { dismiss() }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Text("\(min(runde.position + 1, Runde.aufgabenProRunde)) / \(Runde.aufgabenProRunde)")
                        .monospacedDigit()
                }
            }
        }
        .onAppear(perform: starten)
        .sheet(item: $brunoText) { text in
            brunoSheet(text)
        }
    }

    // MARK: Aufgabe

    @ViewBuilder
    private func aufgabenBildschirm(_ a: AppAufgabe) -> some View {
        VStack(spacing: 20) {
            Spacer()

            if let w = wiederholungVon, phase == .frage {
                Text("Wiederholung: \(w.titel)")
                    .font(.caption.bold())
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(himmelblau, in: Capsule())
            }

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

            if let mutmacher { Text(mutmacher).font(.headline).foregroundStyle(.orange).multilineTextAlignment(.center).padding(.horizontal) }
            if let lob { Text(lob).font(.title3.bold()).multilineTextAlignment(.center).padding(.horizontal).transition(.scale) }

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
                .background(betont ? gruen : Color.gray.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(betont ? .white : .primary)
        }
    }

    private func tippe(_ ziffer: String) {
        guard eingaben[feldIndex].count < 6 else { return }
        eingaben[feldIndex] += ziffer
    }

    // MARK: Logik

    private func starten() {
        let service = FortschrittsService(context: context)
        let ids = pfad.stationen.map(\.rawValue)
        geschafft = Set(service.geschaffteStationen(inReihenfolge: ids)
            .compactMap(MatheStation.init(rawValue:)))
        gangarten = Dictionary(uniqueKeysWithValues: pfad.stationen.map {
            ($0, Gangart(rawValue: service.fortschritt(fuer: $0.rawValue).gangart) ?? .schritt)
        })
        runde = Runde(gangart: gangarten[station] ?? .schritt)
        brunoService.aufwaermen()
        naechsteAufgabe()
    }

    private func naechsteAufgabe() {
        var rng = SystemRandomNumberGenerator()
        let geplant = AufgabenPlaner.aufgabe(
            fuer: station, position: runde.position, gangart: runde.gangart,
            pfad: pfad, geschafft: geschafft, gangarten: gangarten, using: &rng
        )
        wiederholungVon = geplant.wiederholungVon
        zeige(AppAufgabe(geplant.aufgabe), phase: .frage)
    }

    private func zeige(_ a: AppAufgabe, phase neuePhase: Phase) {
        aufgabe = a
        phase = neuePhase
        eingaben = Array(repeating: "", count: a.felder.count)
        feldIndex = 0
        lob = nil
        if neuePhase == .frage { mutmacher = nil }
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

        switch (phase, richtig) {
        case (.frage, true):
            beende(mit: .erstversuch)
        case (.frage, false):
            // Zweite Chance – wie im Prototyp.
            zeige(a, phase: .nochmal)
            mutmacher = "Fast! Probier's gleich noch einmal. 💪"
        case (.nochmal, true), (.quercheck, true):
            beende(mit: .zweitversuch)
        case (.nochmal, false):
            brunoErklaert(a)
        case (.quercheck, false):
            lob = "Knapp daneben – die Antwort war \(a.antwortText). Das üben wir einfach nochmal, kein Stress!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { beende(mit: .erklaert) }
        }
    }

    /// Verbucht das Ergebnis in der Runde (Stern + Gangart) und geht weiter.
    private func beende(mit ergebnis: AntwortErgebnis) {
        if ergebnis.verdientStern {
            lob = ["Super! ⭐️", "Toll gemacht! 🐴", "Bruno bellt vor Freude! 🐶", "Genau richtig! 🎉"].randomElement()
        }
        runde.verarbeite(ergebnis)
        let wartezeit = ergebnis.verdientStern ? 0.9 : 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + wartezeit) {
            if runde.istFertig {
                rundeSpeichern()
                fertig = true
            } else {
                naechsteAufgabe()
            }
        }
    }

    private func brunoErklaert(_ a: AppAufgabe) {
        mutmacher = nil
        let eingabe = Int(eingaben[0]) ?? 0
        let quelle = wiederholungVon ?? station
        let bruno = a.alsBrunoAufgabe(gangart: runde.gangart, station: quelle)
        Task { @MainActor in
            let antwort = await brunoService.erklaere(
                aufgabe: bruno, falscheEingabe: eingabe, richtigeAntwort: a.felder[0].antwort
            )
            brunoText = "Richtig wäre: \(a.antwortText)\n\n\(antwort.erklaerung)"
        }
    }

    /// Nach Brunos Erklärung: ähnliche Aufgabe, eine Gangart gemütlicher.
    private func quercheckStarten() {
        let quelle = wiederholungVon ?? station
        zeige(quelle.appAufgabe(gangart: runde.gangart.langsamer), phase: .quercheck)
        mutmacher = "Quercheck: Zeig Bruno, dass du's kannst! 🐾"
    }

    private func rundeSpeichern() {
        FortschrittsService(context: context).rundeBeendet(
            stationID: station.rawValue,
            aufgaben: Runde.aufgabenProRunde,
            sterne: runde.sterne,
            gangart: runde.gangart.rawValue,
            schleifeGewonnen: runde.schleifeVerdient
        )
        // Bewegungspause ist Pflicht – ab jetzt läuft die Uhr (übersteht Neustart).
        PausenWaechter.starten()
    }

    // MARK: Bruno-Sheet

    private func brunoSheet(_ text: String) -> some View {
        VStack(spacing: 18) {
            Text("🐶").font(.system(size: 60))
            Text("Bruno erklärt:").font(.headline)
            // Scrollbar statt fixer Höhe – längere Erklärungen wurden
            // sonst vom Sheet mit „…" abgeschnitten.
            ScrollView {
                Text(text)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
            Button {
                brunoText = nil
                quercheckStarten()
            } label: {
                Text("Alles klar – ich zeig's dir!")
                    .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                    .background(gruen, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }

    // MARK: Ergebnis (mit Pausen-Pflicht)

    private var ergebnis: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let rest = PausenWaechter.restSekunden
            let schleife = runde.schleifeVerdient
            VStack(spacing: 22) {
                Spacer()
                Text(schleife ? "🎀" : "🐴").font(.system(size: 90))
                Text(schleife ? "Schleife gewonnen!" : "Gute Trainingsrunde!")
                    .font(.largeTitle.bold())
                Text(String(repeating: "⭐️", count: runde.sterne)
                     + String(repeating: "☆", count: Runde.aufgabenProRunde - runde.sterne))
                    .font(.title)
                if !schleife {
                    Text("Für die Schleife: mindestens \(Runde.schleifeMinSterne) Sterne im Trab oder Galopp. Du schaffst das!")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }
                Spacer()
                if rest > 0 {
                    VStack(spacing: 10) {
                        Text("Bewegungspause! 🤸").font(.headline)
                        Text("Hüpf, tanz oder galoppier wie Daisy!")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text(String(format: "%d:%02d", rest / 60, rest % 60))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        ProgressView(value: Double(Bewegungspause.dauerSekunden - rest),
                                     total: Double(Bewegungspause.dauerSekunden))
                            .tint(gruen)
                        Text("Wenn Daisy fertig ist, geht's weiter!")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(red: 1.0, green: 0.945, blue: 0.863), in: RoundedRectangle(cornerRadius: 20))
                } else {
                    Button { dismiss() } label: {
                        Text("Zurück zur Weide")
                            .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                            .background(gruen, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
        }
    }
}

// String als Identifiable fürs Sheet
extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Bewegungspause (Warteschleife auf dem Pfad)

/// Wird gezeigt, wenn während einer laufenden Pause eine Station gestartet
/// wird – auch nach App-Neustart. Kein Überspringen: Der Weiter-Button
/// erscheint erst, wenn die Pause vorbei ist. Die Restzeit kommt aus der
/// echten Uhr (PausenWaechter), Hintergrund/Sperren ändern nichts.
struct BewegungspauseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let rest = PausenWaechter.restSekunden
            VStack(spacing: 26) {
                Spacer()
                Text(rest > 0 ? "🤸" : "🐴🎉").font(.system(size: 80))
                Text(rest > 0 ? "Erst fertig hüpfen!" : "Pause vorbei!")
                    .font(.largeTitle.bold())
                Text(rest > 0 ? "Hüpf, tanz oder galoppier wie Daisy!"
                              : "Daisy ruft dich zurück auf den Pfad!")
                    .font(.title3).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal)

                if rest > 0 {
                    Text(String(format: "%d:%02d", rest / 60, rest % 60))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    ProgressView(value: Double(Bewegungspause.dauerSekunden - rest),
                                 total: Double(Bewegungspause.dauerSekunden))
                        .tint(gruen)
                        .padding(.horizontal, 40)
                }

                Spacer()
                if rest <= 0 {
                    Button("Weiter geht's! 🐾") { dismiss() }
                        .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                        .background(gruen, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                        .padding()
                }
            }
        }
    }
}
