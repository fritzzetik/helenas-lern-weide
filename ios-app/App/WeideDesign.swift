//
//  WeideDesign.swift
//  Helenas Lern-Weide 🐶🐴
//
//  Gemeinsames Design – exakt die Palette und die Motivations-Elemente
//  des React-Prototyps: Farben, Gangart-Emojis, Stationsfarben, Lob,
//  Bewegungs-Ideen, Weideweg (Bruno wandert zu Daisy) und Gangart-Chip.
//

import SwiftUI
import LernWeideCore
import MatheWeide

// MARK: - Palette (PALETTE aus dem Prototyp)

enum Palette {
    static let sky = Color(red: 0.741, green: 0.890, blue: 0.941)      // #BDE3F0
    static let cream = Color(red: 1.0, green: 0.976, blue: 0.925)      // #FFF9EC
    static let grass = Color(red: 0.482, green: 0.714, blue: 0.384)    // #7BB662
    static let grassDark = Color(red: 0.306, green: 0.541, blue: 0.235) // #4E8A3C
    static let sun = Color(red: 1.0, green: 0.831, blue: 0.286)        // #FFD449
    static let coral = Color(red: 1.0, green: 0.541, blue: 0.361)      // #FF8A5C
    static let brown = Color(red: 0.663, green: 0.443, blue: 0.294)    // #A9714B
    static let ink = Color(red: 0.2, green: 0.161, blue: 0.122)        // #33291F
    static let soft = Color(red: 0.549, green: 0.482, blue: 0.42)      // #8C7B6B
    static let blue = Color(red: 0.478, green: 0.612, blue: 0.776)     // #7A9CC6
    static let lila = Color(red: 0.776, green: 0.478, blue: 0.694)     // #C67AB1
}

// MARK: - Gangarten (GANGARTEN aus dem Prototyp)

extension Gangart {
    var emoji: String {
        switch self {
        case .schritt: return "🌿"
        case .trab: return "🐴"
        case .galopp: return "💨"
        }
    }
}

// MARK: - Stationsfarben (farbe aus TURNIERPFADE)

extension MatheStation {
    var akzentfarbe: Color {
        switch self {
        case .aufwaermenBis100, .plusMinusBis1000, .plusMinusBis100000: return Palette.grass
        case .zahlenraum1000, .divisionMitRest, .zahlenraum100000: return Palette.blue
        case .malreihen, .inRechnungen, .malInBis100000: return Palette.coral
        case .laengenmasse, .gewichte, .geldUndZeit, .neueMasse: return Palette.sun
        case .abschlussturnier3, .abschlussturnier4, .rundenUndUeberschlagen: return Palette.lila
        }
    }
}

// MARK: - Motivations-Texte (LOB und PAUSEN aus dem Prototyp)

enum WeideTexte {
    static func lob(name: String) -> String {
        [
            "Super, \(name)! 🌟",
            "Wuff! Richtig! 🐶",
            "Daisy wiehert vor Freude! 🐴",
            "Stark gerechnet! 💪",
            "Genau richtig! ✨",
        ].randomElement()!
    }

    static let pausen = [
        "Hüpf 10-mal auf der Stelle – so wie Bruno, wenn er sich freut! 🐶",
        "Galoppiere einmal durchs Zimmer wie Daisy! 🐴",
        "Streck dich sooo hoch, wie Daisy groß ist! 🙆",
        "Mach 5 Hampelmänner – Bruno zählt mit! 🐾",
        "Trink einen Schluck Wasser und schüttel dich wie Bruno nach dem Baden! 💦",
    ]

    static func tempoHoch(_ gangart: Gangart) -> String {
        "Wow, du bist richtig schnell! Daisy wechselt in den \(gangart.anzeigename)! \(gangart.emoji)"
    }

    static func tempoRunter(_ gangart: Gangart) -> String {
        "Wir machen es uns ein bisschen gemütlicher – \(gangart.anzeigename)-Tempo. \(gangart.emoji) Das ist super zum Üben!"
    }
}

// MARK: - Daisy als Schimmel (weißes Pferd wie im Prototyp)

/// Das Pferde-Emoji „weiß gefiltert" – Daisy ist ein Schimmel.
struct DaisyText: View {
    var groesse: CGFloat
    var body: some View {
        Text("🐴")
            .font(.system(size: groesse))
            .saturation(0)
            .brightness(0.35)
    }
}

// MARK: - Weideweg (Fortschritt in der Runde)

/// Bruno 🐶 wandert mit jeder Aufgabe näher zu Daisy 🐴, darunter die 🐾-Spur.
struct Weideweg: View {
    let schritt: Int
    let gesamt: Int

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                let anteil = CGFloat(schritt) / CGFloat(max(gesamt, 1))
                ZStack(alignment: .leading) {
                    Capsule().fill(.white)
                    Capsule()
                        .fill(Palette.grass.opacity(0.45))
                        .frame(width: max(30, anteil * geo.size.width))
                    DaisyText(groesse: 22)
                        .position(x: geo.size.width - 16, y: geo.size.height / 2)
                    Text("🐶").font(.system(size: 22))
                        .position(x: 16 + anteil * (geo.size.width - 44), y: geo.size.height / 2)
                }
            }
            .frame(height: 30)
            .animation(.easeInOut(duration: 0.4), value: schritt)

            HStack {
                ForEach(0..<gesamt, id: \.self) { i in
                    Text("🐾").font(.system(size: 13)).opacity(i < schritt ? 1 : 0.25)
                    if i < gesamt - 1 { Spacer() }
                }
            }
            .padding(.horizontal, 6)
        }
    }
}

// MARK: - Gangart-Chip (Daisys Tempo)

struct GangartChip: View {
    let gangart: Gangart

    var body: some View {
        HStack(spacing: 5) {
            ForEach(Gangart.allCases, id: \.self) { g in
                Text(g.emoji)
                    .font(.system(size: 15))
                    .padding(4)
                    .opacity(g == gangart ? 1 : 0.35)
                    .background(g == gangart ? Palette.sun.opacity(0.6) : .clear, in: Circle())
            }
            Text(gangart.anzeigename)
                .font(.caption.bold())
                .foregroundStyle(Palette.ink)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white, in: Capsule())
    }
}
