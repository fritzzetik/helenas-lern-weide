//
//  TagesberichtView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Daisys Tagesbericht 📸 – wie im Web-Prototyp: ein Bild mit dem heutigen
//  Fortschritt, einer Tageszeit-Szene (Morgen/Tag/Abend/Nacht) und fix
//  „eingebranntem" Datum + Uhrzeit. Geteilt wird über das System-Share-Sheet
//  (iMessage/SMS) – die App verschickt selbst nichts, Senden bleibt bei Helena.
//

import SwiftUI

private let tinte = Color(red: 0.2, green: 0.16, blue: 0.12)
private let teilenGruen = Color(red: 0.482, green: 0.714, blue: 0.384)

// MARK: - Sheet mit Vorschau und Teilen-Button

struct TagesberichtSheet: View {
    @Environment(\.dismiss) private var dismiss
    let statistik: Tagesstatistik

    @State private var bild: Image?

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TagesberichtKarte(statistik: statistik, jetzt: Date())
                    .frame(width: 330, height: 440)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 6)

                if let bild {
                    ShareLink(
                        item: bild,
                        preview: SharePreview("Daisys Tagesbericht 📸", image: bild)
                    ) {
                        Label("Per Nachricht teilen 💌", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(teilenGruen, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                }

                Text("Datum und Uhrzeit sind fix im Bild – so sieht jeder, wann Daisy es gemacht hat. 😉")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Daisys Tagesbericht 📸")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .onAppear { bild = gerendertesBild() }
        }
    }

    /// Rendert die Karte als Bild (3-fach für scharfe Nachrichten-Vorschau).
    @MainActor
    private func gerendertesBild() -> Image? {
        let renderer = ImageRenderer(
            content: TagesberichtKarte(statistik: statistik, jetzt: Date())
                .frame(width: 360, height: 480)
        )
        renderer.scale = 3
        guard let ui = renderer.uiImage else { return nil }
        return Image(uiImage: ui)
    }
}

// MARK: - Die Berichts-Karte (Vorschau und geteiltes Bild)

struct TagesberichtKarte: View {
    let statistik: Tagesstatistik
    let jetzt: Date

    private var stunde: Int { Calendar.current.component(.hour, from: jetzt) }

    /// Tageszeit-Szene wie im Prototyp: Sonnenaufgang, Tag, Abend, Nacht.
    private var szene: (farben: [Color], symbol: String) {
        switch stunde {
        case 5..<10:
            ([Color(red: 1.0, green: 0.85, blue: 0.62), Color(red: 0.74, green: 0.89, blue: 0.94)], "🌅")
        case 10..<17:
            ([Color(red: 0.74, green: 0.89, blue: 0.94), Color(red: 0.84, green: 0.94, blue: 0.79)], "☀️")
        case 17..<21:
            ([Color(red: 1.0, green: 0.72, blue: 0.48), Color(red: 0.78, green: 0.48, blue: 0.69)], "🌇")
        default:
            ([Color(red: 0.13, green: 0.17, blue: 0.36), Color(red: 0.25, green: 0.30, blue: 0.52)], "🌙")
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: szene.farben, startPoint: .top, endPoint: .bottom)

            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Text(szene.symbol).font(.system(size: 56))
                }

                Spacer()

                HStack(alignment: .bottom, spacing: 6) {
                    Text("🐴").font(.system(size: 76))
                    Text("🐶").font(.system(size: 56))
                }

                Spacer()

                VStack(spacing: 6) {
                    Text("Helenas Lern-Weide 🎀")
                        .font(.title3.bold())
                    Text(Self.datumText(jetzt))
                        .font(.footnote.weight(.semibold))
                        .opacity(0.7)
                    Text("\(statistik.aufgaben) \(statistik.aufgaben == 1 ? "Aufgabe" : "Aufgaben") geübt · \(statistik.sterne) ⭐ · \(statistik.schleifen) 🎀")
                        .font(.subheadline.bold())
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(tinte)
            }
            .padding(18)
        }
    }

    /// Datum + Uhrzeit, österreichisch formatiert – fix im Bild.
    static func datumText(_ d: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_AT")
        df.dateFormat = "EEEE, d. MMMM yyyy · HH:mm 'Uhr'"
        return df.string(from: d)
    }
}
