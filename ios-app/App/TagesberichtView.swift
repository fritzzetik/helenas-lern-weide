//
//  TagesberichtView.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Daisys Tagesbericht 📸 – SwiftUI-Port des Canvas-Bilds aus dem Prototyp:
//  Himmel je nach Tageszeit (Sonnenaufgang, Mittag mit Jause, Abendrot,
//  Nacht mit Mond und Sternen), Wiese, Daisy als Schimmel, Bruno, Blumen –
//  und fix „eingebranntem" Datum + Uhrzeit. Geteilt wird über das
//  System-Share-Sheet, die App verschickt selbst nichts.
//

import SwiftUI

// MARK: - Sheet mit Vorschau und Teilen-Button

struct TagesberichtSheet: View {
    @Environment(\.dismiss) private var dismiss
    let statistik: Tagesstatistik

    @State private var bild: Image?
    // Kids-Kategorie (Guideline 1.3): Teilen führt aus der App hinaus und
    // liegt darum hinter der Elternschranke. Gilt bei jedem Öffnen neu.
    @State private var teilenFreigegeben = false
    @State private var zeigeSchranke = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TagesberichtKarte(statistik: statistik, jetzt: Date())
                    .frame(width: 320, height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 6)

                if let bild {
                    if teilenFreigegeben {
                        ShareLink(
                            item: bild,
                            preview: SharePreview("Daisys Tagesbericht 📸", image: bild)
                        ) {
                            Label("Per Nachricht teilen 💌", systemImage: "paperplane.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Palette.grass, in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                    } else {
                        Button {
                            zeigeSchranke = true
                        } label: {
                            Label("Teilen – frag einen Erwachsenen 🔒", systemImage: "lock.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Palette.soft.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(Palette.ink)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $zeigeSchranke) {
                            ElternschrankeSheet {
                                teilenFreigegeben = true
                            }
                        }
                    }
                }

                Text("Datum und Uhrzeit sind fix im Bild – so sieht jeder, wann Daisy es gemacht hat. 😉")
                    .font(.caption)
                    .foregroundStyle(Palette.soft)
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
                .frame(width: 400, height: 500)
        )
        renderer.scale = 3
        guard let ui = renderer.uiImage else { return nil }
        return Image(uiImage: ui)
    }
}

// MARK: - Die Berichts-Karte (gemalte Szene wie im Prototyp)

struct TagesberichtKarte: View {
    let statistik: Tagesstatistik
    let jetzt: Date

    private enum Tageszeit { case morgen, mittag, abend, nacht }

    private var zeit: Tageszeit {
        let h = Calendar.current.component(.hour, from: jetzt)
        switch h {
        case 5..<11: return .morgen
        case 11..<15: return .mittag
        case 15..<20: return .abend
        default: return .nacht
        }
    }

    private var gruss: String {
        switch zeit {
        case .morgen: return "Guten Morgen! 🌅"
        case .mittag: return "Mahlzeit! 🥪"
        case .abend: return "Guten Abend! 🌇"
        case .nacht: return "Gute Nacht! 🌙"
        }
    }

    var body: some View {
        ZStack {
            szene
            texte
        }
    }

    // MARK: gemalte Szene (Port von malTagesbericht)

    private var szene: some View {
        Canvas { ctx, size in
            let W = size.width
            let H = size.height
            let horizont = H * 0.576   // wie 720 von 1250 im Prototyp
            func x(_ v: CGFloat) -> CGFloat { v / 1000 * W }
            func y(_ v: CGFloat) -> CGFloat { v / 1250 * H }

            // --- Himmel je nach Tageszeit ---
            let himmel: Gradient
            switch zeit {
            case .morgen:
                himmel = Gradient(stops: [
                    .init(color: Color(red: 0.624, green: 0.847, blue: 0.961), location: 0),
                    .init(color: Color(red: 1.0, green: 0.886, blue: 0.604), location: 0.6),
                    .init(color: Color(red: 1.0, green: 0.702, blue: 0.278), location: 1),
                ])
            case .mittag:
                himmel = Gradient(colors: [Color(red: 0.373, green: 0.725, blue: 0.910), Palette.sky])
            case .abend:
                himmel = Gradient(stops: [
                    .init(color: Color(red: 0.557, green: 0.420, blue: 0.710), location: 0),
                    .init(color: Color(red: 1.0, green: 0.620, blue: 0.478), location: 0.55),
                    .init(color: Palette.coral, location: 1),
                ])
            case .nacht:
                himmel = Gradient(colors: [Color(red: 0.078, green: 0.122, blue: 0.239), Color(red: 0.180, green: 0.263, blue: 0.447)])
            }
            ctx.fill(
                Path(CGRect(x: 0, y: 0, width: W, height: horizont)),
                with: .linearGradient(himmel, startPoint: .zero, endPoint: CGPoint(x: 0, y: horizont))
            )

            // --- Sonne / Mond / Sterne ---
            if zeit == .nacht {
                // Sterne: deterministisch (das Bild bleibt ruhig), aber per
                // Hash gestreut – eine lineare Formel ergab eine Diagonale.
                func streu(_ i: Int, _ salz: UInt64) -> CGFloat {
                    var z = UInt64(i) &* 0x9E3779B97F4A7C15 &+ salz &* 0xBF58476D1CE4E5B9
                    z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
                    z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
                    z ^= z >> 31
                    return CGFloat(z % 100_000) / 100_000
                }
                let sternfarbe = Color(red: 1.0, green: 0.969, blue: 0.867)
                for i in 0..<40 {
                    let sx = streu(i, 1) * W
                    let sy = y(30 + streu(i, 2) * 560)
                    let r = x(i % 5 == 0 ? 4 : 2.5)
                    ctx.fill(Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: 2 * r, height: 2 * r)), with: .color(sternfarbe))
                }
                // Mond mit Sichel
                let mr = x(85)
                ctx.fill(Path(ellipseIn: CGRect(x: x(780) - mr, y: y(180) - mr, width: 2 * mr, height: 2 * mr)),
                         with: .color(Color(red: 1.0, green: 0.957, blue: 0.839)))
                let or2 = x(72)
                ctx.fill(Path(ellipseIn: CGRect(x: x(815) - or2, y: y(160) - or2, width: 2 * or2, height: 2 * or2)),
                         with: .color(Color(red: 0.106, green: 0.165, blue: 0.290)))
            } else {
                let sonne: (x: CGFloat, y: CGFloat, r: CGFloat)
                switch zeit {
                case .morgen: sonne = (x(500), horizont - y(20), x(115))
                case .abend: sonne = (x(500), horizont - y(10), x(105))
                default: sonne = (x(800), y(170), x(95))
                }
                let strahlfarbe = zeit == .abend ? Color(red: 1.0, green: 0.690, blue: 0.478) : Palette.sun
                let kernfarbe = zeit == .abend ? Color(red: 1.0, green: 0.620, blue: 0.310) : Palette.sun
                for i in 0..<12 {
                    let w = CGFloat(i) / 12 * 2 * .pi
                    var strahl = Path()
                    strahl.move(to: CGPoint(x: sonne.x + cos(w) * (sonne.r + x(22)), y: sonne.y + sin(w) * (sonne.r + x(22))))
                    strahl.addLine(to: CGPoint(x: sonne.x + cos(w) * (sonne.r + x(58)), y: sonne.y + sin(w) * (sonne.r + x(58))))
                    ctx.stroke(strahl, with: .color(strahlfarbe), style: StrokeStyle(lineWidth: x(10), lineCap: .round))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: sonne.x - sonne.r, y: sonne.y - sonne.r, width: 2 * sonne.r, height: 2 * sonne.r)),
                         with: .color(kernfarbe))
            }

            // --- Wiese ---
            let wiese = zeit == .nacht
                ? Gradient(colors: [Color(red: 0.243, green: 0.361, blue: 0.204), Color(red: 0.165, green: 0.251, blue: 0.137)])
                : Gradient(colors: [Color(red: 0.561, green: 0.769, blue: 0.435), Palette.grassDark])
            ctx.fill(
                Path(CGRect(x: 0, y: horizont, width: W, height: H - horizont)),
                with: .linearGradient(wiese, startPoint: CGPoint(x: 0, y: horizont), endPoint: CGPoint(x: 0, y: H))
            )

            // --- Tiere & Deko auf der Wiese ---
            // Daisy ist ein Schimmel: Filter macht das Pferde-Emoji weiß
            var daisyCtx = ctx
            daisyCtx.addFilter(.saturation(0))
            daisyCtx.addFilter(.brightness(0.35))
            daisyCtx.draw(Text("🐴").font(.system(size: x(170))), at: CGPoint(x: x(300), y: horizont + y(110)))

            ctx.draw(Text("🐶").font(.system(size: x(120))), at: CGPoint(x: x(620), y: horizont + y(125)))
            ctx.draw(Text("🌼").font(.system(size: x(54))), at: CGPoint(x: x(120), y: horizont + y(50)))
            ctx.draw(Text("🌼").font(.system(size: x(54))), at: CGPoint(x: x(880), y: horizont + y(170)))
            if zeit == .mittag {
                ctx.draw(Text("🧺").font(.system(size: x(100))), at: CGPoint(x: x(820), y: horizont + y(60)))
            }
        }
    }

    // MARK: Titel oben, Statistik-Banner unten

    private var texte: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("Daisys Tagesbericht")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                Text(gruss)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(zeit == .nacht ? Color(red: 1.0, green: 0.969, blue: 0.867) : .white)
            .shadow(color: .black.opacity(0.35), radius: 4)
            .padding(.top, 14)

            Spacer()

            VStack(spacing: 4) {
                Text("Helenas Lern-Weide 🎀")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                Text(Self.datumText(jetzt))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.soft)
                Text("\(statistik.aufgaben) \(statistik.aufgaben == 1 ? "Aufgabe" : "Aufgaben") geübt · \(statistik.sterne) ⭐ · \(statistik.schleifen) 🎀")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
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
