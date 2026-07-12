//
//  TurnierpfadView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Der Turnierpfad im Prototyp-Look: Hero mit Daisy und Bruno,
//  Daisys Tagesbericht, Klassen-Schalter, Stationen mit Akzentfarben
//  und 🐾-Verbindungen, ▶️ an der aktuellen Station. Läuft noch eine
//  Bewegungspause, führt jeder Stationsstart zuerst in die Warteschleife.
//

import SwiftUI
import SwiftData
import LernWeideCore
import MatheWeide

struct TurnierpfadView: View {
    @Environment(\.modelContext) private var context
    @Query private var fortschritte: [StationsFortschritt]
    @Query private var profile: [Profil]

    @State private var aktiveStation: MatheStation?
    @State private var zeigePause = false
    @State private var zeigeBericht = false
    @State private var zeigeNamensDialog = false
    @State private var neuerName = ""

    private var service: FortschrittsService { FortschrittsService(context: context) }
    private var name: String { profile.first?.name ?? "Helena" }
    private var klasse: String { profile.first?.klasse ?? "klasse3" }
    private var pfad: Turnierpfad<MatheStation> { Pfade.pfad(fuer: klasse) }

    /// Geschaffte Stationen – reaktiv aus der Query, Logik aus dem Core.
    private var geschafft: Set<MatheStation> {
        Set(fortschritte.filter(\.schleife).compactMap { MatheStation(rawValue: $0.stationID) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    hero
                    berichtsKarte
                    klassenSchalter
                    stationen
                    fussnote
                }
                .padding()
            }
            .background(Palette.cream)
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(item: $aktiveStation) { station in
                RundenView(station: station, pfad: pfad)
            }
            .fullScreenCover(isPresented: $zeigePause) {
                BewegungspauseView()
            }
            .sheet(isPresented: $zeigeBericht) {
                TagesberichtSheet(statistik: service.heutigeStatistik())
            }
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Text("🐶").font(.system(size: 52))
                DaisyText(groesse: 52)
            }
            Text("Hallo \(name)!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Dein Turnierpfad wartet – Station für Station zur nächsten Schleife! 🎀")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Palette.soft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .contentShape(Rectangle())
        // Auf die Begrüßung tippen → Namen ändern. (Die Apple-ID darf eine
        // App aus Datenschutzgründen nicht auslesen – deshalb einmal fragen.)
        .onTapGesture {
            neuerName = name
            zeigeNamensDialog = true
        }
        .alert("Wie heißt du?", isPresented: $zeigeNamensDialog) {
            TextField("Dein Vorname", text: $neuerName)
            Button("Speichern") { service.setzeName(neuerName) }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Daisy und Bruno merken sich deinen Namen.")
        }
    }

    // MARK: Daisys Tagesbericht

    private var berichtsKarte: some View {
        Button { zeigeBericht = true } label: {
            HStack(spacing: 12) {
                Text("📸").font(.system(size: 28))
                Text("Daisys Tagesbericht").font(.headline)
                Spacer()
                let heute = service.heutigeStatistik()
                if heute.aufgaben > 0 {
                    Text("\(heute.aufgaben) Aufgaben heute")
                        .font(.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Palette.sun.opacity(0.5), in: Capsule())
                }
                Text("💌").font(.title3)
            }
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Palette.ink)
    }

    // MARK: Klassen-Schalter

    private var klassenSchalter: some View {
        HStack(spacing: 8) {
            klassenKnopf("klasse3", titel: "🏠 3. Klasse")
            klassenKnopf("klasse4", titel: "🏇 4. Klasse")
        }
    }

    private func klassenKnopf(_ id: String, titel: String) -> some View {
        Button { service.setzeKlasse(id) } label: {
            Text(titel)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(klasse == id ? Palette.grass : .white, in: Capsule())
                .foregroundStyle(klasse == id ? .white : Palette.ink)
        }
        .buttonStyle(.plain)
    }

    // MARK: Stationen mit 🐾-Verbindungen

    private var stationen: some View {
        let offen = geschafft
        let aktuelle = pfad.naechsteOffene(geschafft: offen)
        return VStack(spacing: 0) {
            ForEach(Array(pfad.stationen.enumerated()), id: \.element) { index, station in
                if index > 0 {
                    Text("🐾")
                        .font(.system(size: 15))
                        .opacity(pfad.status(station, geschafft: offen) == .gesperrt ? 0.2 : 0.7)
                        .padding(.vertical, 3)
                }
                stationsKarte(station, status: pfad.status(station, geschafft: offen), istAktuell: station == aktuelle)
            }
        }
    }

    private func stationsKarte(_ station: MatheStation, status: StationsStatus, istAktuell: Bool) -> some View {
        Button {
            guard status != .gesperrt else { return }
            // Bewegungspause ist Pflicht – erst fertig hüpfen, dann rechnen.
            if PausenWaechter.laeuft {
                zeigePause = true
            } else {
                aktiveStation = station
            }
        } label: {
            HStack(spacing: 12) {
                Text(station.emoji)
                    .font(.system(size: 26))
                    .frame(width: 48, height: 48)
                    .background(station.akzentfarbe.opacity(0.25), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.titel).font(.headline).multilineTextAlignment(.leading)
                    Text(untertitel(station, status: status))
                        .font(.caption).foregroundStyle(Palette.soft)
                }
                Spacer()
                switch status {
                case .geschafft: Text("🎀").font(.title2)
                case .offen: Text(istAktuell ? "▶️" : "").font(.title3)
                case .gesperrt: Text("🔒").font(.title3).opacity(0.4)
                }
            }
            .padding(12)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(istAktuell ? station.akzentfarbe : .clear, lineWidth: 3)
            )
            .opacity(status == .gesperrt ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Palette.ink)
        .disabled(status == .gesperrt)
    }

    private func untertitel(_ station: MatheStation, status: StationsStatus) -> String {
        switch status {
        case .geschafft: return "Freies Training – jederzeit üben!"
        case .offen: return station.untertitel
        case .gesperrt: return "Noch verschlossen"
        }
    }

    // MARK: Fußnote

    private var fussnote: some View {
        Text("🎀 Schleife = mindestens \(Runde.schleifeMinSterne) von \(Runde.aufgabenProRunde) Sternen im \(Runde.schleifeMinGangart.anzeigename) oder schneller.\nGeschaffte Stationen bleiben als Freies Training offen. 🐾")
            .font(.caption)
            .foregroundStyle(Palette.soft)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }
}
