//
//  TurnierpfadView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Der Turnierpfad: Stationen in Lehrplan-Reihenfolge (aus dem Package,
//  identisch zum React-Prototyp). Nur die aktuelle ist offen 🔓,
//  geschaffte 🎀 bleiben als Freies Training offen, kommende sind
//  sichtbar aber gesperrt 🔒. Läuft noch eine Bewegungspause, führt
//  jeder Stationsstart zuerst in die Warteschleife.
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

    private var service: FortschrittsService { FortschrittsService(context: context) }
    private var klasse: String { profile.first?.klasse ?? "klasse3" }
    private var pfad: Turnierpfad<MatheStation> { Pfade.pfad(fuer: klasse) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    kopf
                    ForEach(pfad.stationen) { station in
                        stationsKarte(station)
                    }
                    berichtsKarte
                }
                .padding()
            }
            .background(Color(red: 1.0, green: 0.976, blue: 0.925))   // cream
            .navigationTitle("Helenas Lern-Weide")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("3. Klasse 🏠") { service.setzeKlasse("klasse3") }
                        Button("4. Klasse 🏇") { service.setzeKlasse("klasse4") }
                    } label: {
                        Text(klasse == "klasse4" ? "4. Klasse" : "3. Klasse")
                    }
                }
            }
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

    private var kopf: some View {
        let ids = pfad.stationen.map(\.rawValue)
        let schleifen = fortschritte.filter { $0.schleife && ids.contains($0.stationID) }.count
        return HStack {
            Text("🐶").font(.system(size: 44))
            VStack(alignment: .leading) {
                Text("Hallo \(service.profil().name)!").font(.title2.bold())
                Text("Schleifen: \(schleifen) von \(pfad.stationen.count) 🎀")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text("🐴").font(.system(size: 44))
        }
        .padding()
        .background(Color(red: 0.741, green: 0.890, blue: 0.941), in: RoundedRectangle(cornerRadius: 20))
    }

    private var berichtsKarte: some View {
        Button { zeigeBericht = true } label: {
            HStack(spacing: 14) {
                Text("📸").font(.system(size: 34))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daisys Tagesbericht").font(.headline)
                    Text("heute geübt – zum Herzeigen und Verschicken")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text("💌").font(.title2)
            }
            .padding()
            .background(Color(red: 1.0, green: 0.945, blue: 0.863), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color(red: 0.2, green: 0.16, blue: 0.12))
    }

    @ViewBuilder
    private func stationsKarte(_ station: MatheStation) -> some View {
        let status = service.status(stationID: station.rawValue,
                                    inReihenfolge: pfad.stationen.map(\.rawValue))

        Button {
            guard status != .gesperrt else { return }
            // Bewegungspause ist Pflicht – erst fertig hüpfen, dann rechnen.
            if PausenWaechter.laeuft {
                zeigePause = true
            } else {
                aktiveStation = station
            }
        } label: {
            HStack(spacing: 14) {
                Text(station.emoji).font(.system(size: 34))
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.titel).font(.headline).multilineTextAlignment(.leading)
                    Text(status == .geschafft ? "Freies Training" : station.untertitel)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                switch status {
                case .geschafft: Text("🎀").font(.title)
                case .offen:     Text("🔓").font(.title2)
                case .gesperrt:  Text("🔒").font(.title2).opacity(0.4)
                }
            }
            .padding()
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .opacity(status == .gesperrt ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color(red: 0.2, green: 0.16, blue: 0.12))
        .disabled(status == .gesperrt)
    }
}
