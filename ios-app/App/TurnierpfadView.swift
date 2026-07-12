//
//  TurnierpfadView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Der Turnierpfad: Stationen in Lehrplan-Reihenfolge. Nur die aktuelle
//  ist offen 🔓, geschaffte 🎀 bleiben als Freies Training offen,
//  kommende sind sichtbar aber gesperrt 🔒. ADHS-freundlich: klare
//  Struktur, sichtbarer Fortschritt, kein "Durchgefallen".
//

import SwiftUI
import SwiftData

struct TurnierpfadView: View {
    @Environment(\.modelContext) private var context
    @Query private var fortschritte: [StationsFortschritt]

    @State private var aktiveStation: Station?

    private var service: FortschrittsService { FortschrittsService(context: context) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    kopf
                    ForEach(Turnierpfad.klasse3) { station in
                        stationsKarte(station)
                    }
                }
                .padding()
            }
            .background(Color(red: 1.0, green: 0.976, blue: 0.925))   // cream
            .navigationTitle("Helenas Lern-Weide")
            .fullScreenCover(item: $aktiveStation) { station in
                RundenView(station: station)
            }
        }
    }

    private var kopf: some View {
        let schleifen = fortschritte.filter(\.schleife).count
        return HStack {
            Text("🐶").font(.system(size: 44))
            VStack(alignment: .leading) {
                Text("Hallo \(service.profil().name)!").font(.title2.bold())
                Text("Schleifen: \(schleifen) von \(Turnierpfad.klasse3.count) 🎀")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text("🐴").font(.system(size: 44))
        }
        .padding()
        .background(Color(red: 0.741, green: 0.890, blue: 0.941), in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func stationsKarte(_ station: Station) -> some View {
        let status = service.status(stationID: station.id, inReihenfolge: Turnierpfad.alleIDs)

        Button {
            if status != .gesperrt { aktiveStation = station }
        } label: {
            HStack(spacing: 14) {
                Text(station.emoji).font(.system(size: 34))
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.titel).font(.headline).multilineTextAlignment(.leading)
                    Text(status == .geschafft ? "Freies Training" : station.sub)
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

extension Station: Hashable {
    static func == (lhs: Station, rhs: Station) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
