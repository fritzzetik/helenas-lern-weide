//
//  RundenView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Eine Runde im Prototyp-Look: Weideweg (Bruno wandert zu Daisy),
//  Gangart-Chip, Themen-Chip in Stationsfarbe, Tempo-Meldungen, Lob mit
//  großem 🌟, Zweitversuch mit Tipp, Bruno-Erklärung + Quercheck mit
//  Auflösung. Die Spielregeln kommen aus `Runde` im getesteten Package.
//  Danach: verpflichtende 3-Minuten-Bewegungspause.
//

import SwiftUI
import SwiftData
import LernWeideCore
import MatheWeide

struct RundenView: View {
    let station: MatheStation
    let pfad: Turnierpfad<MatheStation>

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profile: [Profil]

    private enum Phase { case frage, nochmal, quercheck, quercheckErgebnis }

    @State private var runde = Runde()
    @State private var phase: Phase = .frage
    @State private var aufgabe: AppAufgabe?
    @State private var originalAufgabe: AppAufgabe?     // für die Auflösung nach dem Quercheck
    @State private var wiederholungVon: MatheStation?
    @State private var feldIndex = 0
    @State private var eingaben: [String] = []
    @State private var lob: String?
    @State private var levelMsg: String?
    @State private var brunoText: String?
    @State private var quercheckRichtig = false
    @State private var fertig = false
    @State private var hatteSchleife = false
    @State private var pausenText = WeideTexte.pausen[0]

    // Kontext für den Wiederholungs-Mix (einmal beim Start geladen).
    @State private var geschafft: Set<MatheStation> = []
    @State private var gangarten: [MatheStation: Gangart] = [:]

    private let brunoService = BrunoErklaerungsService()
    private var name: String { profile.first?.name ?? "Helena" }

    var body: some View {
        Group {
            if fertig {
                ergebnis
            } else {
                rundenInhalt
            }
        }
        .background(Palette.cream)
        .onAppear(perform: starten)
        .sheet(item: $brunoText) { text in
            brunoSheet(text)
        }
    }

    // MARK: Runden-Bildschirm

    private var rundenInhalt: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("← Pfad")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(.white, in: Capsule())
                        .foregroundStyle(Palette.ink)
                }
                Spacer()
                GangartChip(gangart: runde.gangart)
            }

            Weideweg(schritt: runde.position, gesamt: Runde.aufgabenProRunde)

            ScrollView {
                karte
            }
        }
        .padding()
    }

    @ViewBuilder
    private var karte: some View {
        VStack(spacing: 14) {
            // Themen-Chip in Stationsfarbe
            Text("\((wiederholungVon ?? station).emoji) \((wiederholungVon ?? station).titel)")
                .font(.caption.bold())
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background((wiederholungVon ?? station).akzentfarbe.opacity(0.85), in: Capsule())
                .foregroundStyle(.white)

            if wiederholungVon != nil, phase == .frage || phase == .nochmal {
                Text("🔁 Wiederholung aus einer geschafften Station")
                    .font(.caption.bold())
                    .foregroundStyle(Palette.soft)
            }

            if let levelMsg, phase == .frage || phase == .nochmal {
                Text(levelMsg)
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Palette.sun.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
            }

            if let lob {
                feedbackRichtig(lob)
            } else if let a = aufgabe {
                switch phase {
                case .frage, .nochmal:
                    frageBlock(a)
                    if phase == .nochmal {
                        hinweisBox(a)
                    }
                    eingabeBlock(a)
                case .quercheck:
                    Text("Quercheck 🔎")
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Palette.blue.opacity(0.3), in: Capsule())
                    frageBlock(a)
                    eingabeBlock(a)
                case .quercheckErgebnis:
                    quercheckErgebnisBlock(a)
                }
            } else {
                ProgressView().padding()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private func frageBlock(_ a: AppAufgabe) -> some View {
        Text(a.frage)
            .font(.system(size: a.frage.count > 40 ? 22 : 30, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 4)
    }

    private func hinweisBox(_ a: AppAufgabe) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("🐶")
            Text("Fast! Probier's noch einmal. Tipp: \(a.hinweis)")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Palette.ink)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.sun.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }

    private func feedbackRichtig(_ text: String) -> some View {
        VStack(spacing: 10) {
            Text("🌟").font(.system(size: 64))
            Text(text)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.ink)
        }
        .padding(.vertical, 30)
    }

    private func quercheckErgebnisBlock(_ a: AppAufgabe) -> some View {
        VStack(spacing: 12) {
            if quercheckRichtig {
                Text("🎉").font(.system(size: 64))
                Text("Jetzt hast du's! Daisy ist stolz auf dich! 🐴")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
            } else {
                DaisyText(groesse: 64)
                Text("Knapp daneben – die Antwort war \(a.antwortText). Das üben wir einfach nochmal, kein Stress!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            if let original = originalAufgabe {
                Text("Und die erste Aufgabe? \(original.frage) → \(original.antwortText)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.soft)
            }
            grossKnopf("Weiter 🐾") {
                verbuche(quercheckRichtig ? .zweitversuch : .erklaert)
            }
        }
        .foregroundStyle(Palette.ink)
        .padding(.vertical, 8)
    }

    // MARK: Eingabe

    @ViewBuilder
    private func eingabeBlock(_ a: AppAufgabe) -> some View {
        HStack(spacing: 16) {
            ForEach(a.felder.indices, id: \.self) { i in
                VStack(spacing: 2) {
                    Text(a.felder[i].label).font(.caption.bold()).foregroundStyle(Palette.soft)
                    Text(eingaben.indices.contains(i) && !eingaben[i].isEmpty ? eingaben[i] : "…")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .frame(minWidth: 84)
                        .padding(.vertical, 4)
                        .background(i == feldIndex ? Palette.sun.opacity(0.4) : Color.gray.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .foregroundStyle(Palette.ink)

        numpad

        if a.felder.count == 2 {
            Text("Zuerst das Ergebnis eintippen und ✓ drücken – dann den Rest. 🐾")
                .font(.caption)
                .foregroundStyle(Palette.soft)
                .multilineTextAlignment(.center)
        }
    }

    private var numpad: some View {
        VStack(spacing: 8) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { reihe in
                HStack(spacing: 8) {
                    ForEach(reihe, id: \.self) { z in taste("\(z)") { tippe("\(z)") } }
                }
            }
            HStack(spacing: 8) {
                taste("⌫") { if !eingaben[feldIndex].isEmpty { eingaben[feldIndex].removeLast() } }
                taste("0") { tippe("0") }
                taste("✓", betont: true) { pruefe() }
            }
        }
    }

    private func taste(_ label: String, betont: Bool = false, aktion: @escaping () -> Void) -> some View {
        Button(action: aktion) {
            Text(label)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(betont ? Palette.grass : Color.gray.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(betont ? .white : Palette.ink)
        }
    }

    private func tippe(_ ziffer: String) {
        guard eingaben.indices.contains(feldIndex), eingaben[feldIndex].count < 6 else { return }
        eingaben[feldIndex] += ziffer
    }

    private func grossKnopf(_ titel: String, aktion: @escaping () -> Void) -> some View {
        Button(action: aktion) {
            Text(titel)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Palette.grass, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
        }
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
        hatteSchleife = geschafft.contains(station)
        runde = Runde(gangart: gangarten[station] ?? .schritt)
        levelMsg = nil
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
        originalAufgabe = nil
        zeige(AppAufgabe(geplant.aufgabe), phase: .frage)
    }

    private func zeige(_ a: AppAufgabe, phase neuePhase: Phase) {
        aufgabe = a
        phase = neuePhase
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

        switch (phase, richtig) {
        case (.frage, true):
            richtigFeedback(.erstversuch)
        case (.frage, false):
            // Zweite Chance – wie im Prototyp, mit Tipp.
            zeige(a, phase: .nochmal)
        case (.nochmal, true):
            richtigFeedback(.zweitversuch)
        case (.nochmal, false):
            brunoErklaert(a)
        case (.quercheck, _):
            quercheckRichtig = richtig
            phase = .quercheckErgebnis
        default:
            break
        }
    }

    /// Großes 🌟 + Lob zeigen, dann verbuchen und weiter.
    private func richtigFeedback(_ ergebnis: AntwortErgebnis) {
        lob = WeideTexte.lob(name: name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            verbuche(ergebnis)
        }
    }

    /// Verbucht das Ergebnis in der Runde (Stern + Gangart) und geht weiter.
    private func verbuche(_ ergebnis: AntwortErgebnis) {
        let vorher = runde.gangart
        let geaendert = runde.verarbeite(ergebnis)
        levelMsg = geaendert
            ? (runde.gangart > vorher ? WeideTexte.tempoHoch(runde.gangart) : WeideTexte.tempoRunter(runde.gangart))
            : nil

        if runde.istFertig {
            rundeSpeichern()
            fertig = true
        } else {
            naechsteAufgabe()
        }
    }

    private func brunoErklaert(_ a: AppAufgabe) {
        originalAufgabe = a
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
        let original = originalAufgabe
        zeige(quelle.appAufgabe(gangart: runde.gangart.langsamer), phase: .quercheck)
        originalAufgabe = original   // Auflösung nach dem Quercheck zeigen
    }

    private func rundeSpeichern() {
        FortschrittsService(context: context).rundeBeendet(
            stationID: station.rawValue,
            aufgaben: Runde.aufgabenProRunde,
            sterne: runde.sterne,
            gangart: runde.gangart.rawValue,
            schleifeGewonnen: runde.schleifeVerdient
        )
        pausenText = WeideTexte.pausen.randomElement() ?? WeideTexte.pausen[0]
        // Bewegungspause ist Pflicht – ab jetzt läuft die Uhr (übersteht Neustart).
        PausenWaechter.starten()
    }

    // MARK: Bruno-Sheet

    private func brunoSheet(_ text: String) -> some View {
        VStack(spacing: 18) {
            Text("🐶").font(.system(size: 60))
            Text("Bruno erklärt:").font(.headline)
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
                Text("Verstanden – ich probier's! 💪")
                    .font(.headline).frame(maxWidth: .infinity, minHeight: 52)
                    .background(Palette.grass, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        // 80 % Höhe: Brunos 2–3 Sätze passen ohne Aufziehen komplett hin.
        .presentationDetents([.fraction(0.8), .large])
        .interactiveDismissDisabled()
    }

    // MARK: Ergebnis (mit Pausen-Pflicht)

    private var ergebnis: some View {
        let schleifeNeu = runde.schleifeVerdient && !hatteSchleife
        return TimelineView(.periodic(from: .now, by: 1)) { _ in
            let rest = PausenWaechter.restSekunden
            VStack(spacing: 16) {
                Spacer()

                if schleifeNeu {
                    Text("🎀").font(.system(size: 84))
                    Text("Schleife gewonnen!").font(.largeTitle.bold())
                    Text("„\(station.titel)\u{201C} ist geschafft, \(name)! Die nächste Station ist jetzt offen!")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Palette.soft)
                        .multilineTextAlignment(.center).padding(.horizontal)
                } else {
                    Text("🏆").font(.system(size: 84))
                    Text("Runde geschafft!").font(.largeTitle.bold())
                    if !hatteSchleife {
                        Text("Starke Trainingsrunde! Für die Schleife 🎀 brauchst du \(Runde.schleifeMinSterne) Sterne im \(Runde.schleifeMinGangart.anzeigename) – du schaffst das!")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.soft)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                }

                HStack(spacing: 3) {
                    // 10 Sterne müssen in eine Zeile passen
                    ForEach(0..<Runde.aufgabenProRunde, id: \.self) { i in
                        Text("★")
                            .font(.system(size: 26))
                            .foregroundStyle(i < runde.sterne ? Palette.sun : Color(red: 0.886, green: 0.847, blue: 0.776))
                    }
                }

                Text("Daisys Tempo: \(runde.gangart.emoji) \(runde.gangart.anzeigename)")
                    .font(.subheadline.bold())

                Spacer()

                if rest > 0 {
                    // Luftig wie die Warteschleife – die enge Box wirkte gequetscht.
                    VStack(spacing: 10) {
                        Text("🤸").font(.system(size: 54))
                        Text("Bewegungspause!").font(.title2.bold())
                        Text(pausenText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.soft)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text(String(format: "%d:%02d", rest / 60, rest % 60))
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        ProgressView(value: Double(Bewegungspause.dauerSekunden - rest),
                                     total: Double(Bewegungspause.dauerSekunden))
                            .tint(Palette.grass)
                            .padding(.horizontal, 30)
                        Text("Wenn Daisy fertig ist, geht's weiter!")
                            .font(.caption).foregroundStyle(Palette.soft)
                    }
                    .padding(.bottom, 8)
                } else {
                    grossKnopf("Nochmal \(station.emoji)") {
                        fertig = false
                        starten()
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Zum Pfad 🐴")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(Palette.ink)
                    }
                }
            }
            .foregroundStyle(Palette.ink)
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
    // Jedes Mal eine andere Bewegungs-Idee – wie im Prototyp.
    @State private var pausenText = WeideTexte.pausen.randomElement() ?? WeideTexte.pausen[0]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let rest = PausenWaechter.restSekunden
            VStack(spacing: 24) {
                Spacer()
                Text(rest > 0 ? "🤸" : "🐴🎉").font(.system(size: 76))
                Text(rest > 0 ? "Erst fertig hüpfen!" : "Pause vorbei!")
                    .font(.largeTitle.bold())
                Text(rest > 0 ? pausenText : "Daisy ruft dich zurück auf den Pfad!")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Palette.soft)
                    .multilineTextAlignment(.center).padding(.horizontal)

                if rest > 0 {
                    Text(String(format: "%d:%02d", rest / 60, rest % 60))
                        .font(.system(size: 58, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    ProgressView(value: Double(Bewegungspause.dauerSekunden - rest),
                                 total: Double(Bewegungspause.dauerSekunden))
                        .tint(Palette.grass)
                        .padding(.horizontal, 40)
                }

                Spacer()
                if rest <= 0 {
                    Button {
                        dismiss()
                    } label: {
                        Text("Weiter geht's! 🐾")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Palette.grass, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.cream)
        }
    }
}
