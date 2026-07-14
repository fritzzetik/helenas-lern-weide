# Helenas Lern-Weide 🐴🐕

Eine Lern-App für Volksschulkinder in Österreich – mit **Bruno** (Hund) und **Daisy** (Pferd) als Begleiter.

Der erste Stall auf der Weide ist **Mathe** (3./4. Klasse, österreichischer Lehrplan). Weitere Fächer folgen.

## Grundprinzipien

- **Aufmerksamkeitsfreundlich by Design:** eine Aufgabe pro Bildschirm, kurze Runden (5 Aufgaben), sofortiges positives Feedback, sichtbarer Fortschritt. Nach jeder Runde kommt eine **verpflichtende 3-Minuten-Bewegungspause** – sie startet automatisch und kann nicht übersprungen werden.
- **Das LLM rechnet nie:** Alle Aufgaben und Lösungen entstehen deterministisch im Code. KI erzeugt ausschließlich erklärende Texte (Bruno erklärt in 2–3 kurzen Sätzen).
- **Österreichisches Deutsch:** durchgehend – im Code, in Texten und in KI-Prompts (Karotten, Sackerl, Jänner, dag).

## Struktur

| Pfad | Inhalt |
|---|---|
| `Sources/LernWeideCore` | Fachübergreifend: Gangarten & adaptive Schwierigkeit (2 Erstversuch-Treffer → schneller, 2 Fehler → langsamer), Runden mit Sternen & Schleifen-Check 🎀, Turnierpfad-Freischaltung, verpflichtende Bewegungspause |
| `Sources/MatheWeide` | Mathe-Aufgabenlogik für die **1.–4. Klasse Volksschule**: Zählen und Zahlenraum 20/100 (1./2. Klasse, kurze 5er-Runden), alle Stationen der 3. Klasse (inkl. Division mit Rest) und der 4. Klasse (Zahlenraum 100.000 bis Sachaufgaben, 10er-Runden); dazu Turnierpfad-Katalog, Stationen-Metadaten und Wiederholungs-Mix |
| `Tests/` | Swift-Testing-Suite (läuft automatisch per CI) |
| `ios-app/` | iOS-App-Schicht: Bruno-Erklärungsservice (Foundation Models), Tests, SwiftData-Persistenz – wird am Mac ins Xcode-Projekt eingebunden, nicht von der CI kompiliert |
| `web-prototype/` | React-Prototyp `helenas-lern-weide.jsx` (Version 5 mit Daisys Tagesbericht) – sofort testbar |
| `.github/workflows/ci.yml` | CI: baut & testet auf macOS-Runnern bei jedem Push |

## Entwicklung ohne Mac

Die Kernlogik ist ein reines Swift Package und wird bei jedem Push automatisch auf einem
GitHub-macOS-Runner getestet (`swift test`). Live-LLM-Tests (Foundation Models Framework)
tragen den Tag `liveLLM` und laufen nur lokal auf Geräten mit Apple Intelligence.
