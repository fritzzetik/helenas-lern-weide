# iOS-App-Schicht

Diese Dateien gehören zur nativen iOS-App und werden **bewusst nicht** vom Swift Package
(`Package.swift`) kompiliert – sie brauchen iOS-26-Frameworks (Foundation Models, SwiftData
mit CloudKit). Das Xcode-Projekt entsteht aus `project.yml` per **XcodeGen**
(`xcodegen generate` – lokal am Mac genauso wie auf dem CI-Runner).

| Datei | Inhalt |
|---|---|
| `App/LernWeideApp.swift` | App-Einstieg, SwiftData-Container (CloudKit-Sync kommt später per Capability dazu) |
| `App/TurnierpfadView.swift` | Turnierpfad mit Freischaltung (🔓/🎀/🔒), Klassen-Umschalter, Pausen-Gate |
| `App/RundenView.swift` | Runde mit Numpad, Zweitversuch, Bruno-Erklärung + Quercheck, Ergebnis mit verpflichtender Bewegungspause |
| `App/Stationen.swift` | Dünne Brücke zum Package: `AppAufgabe` (1–2 Eingabefelder), Pfad-Auswahl, `PausenWaechter` (UserDefaults-Zeitstempel) |
| `BrunoErklaerungsService.swift` | Bruno-Erklärungen via Apple Foundation Models (on-device), LLM hinter `TextFormulierer`-Protokoll (mockbar), regelbasierte Fehleranalyse + Fallback. Modell heißt `BrunoAufgabe`. Prinzip: **Code rechnet, LLM formuliert nur.** |
| `BrunoErklaerungsTests.swift` | Swift-Testing-Suite für den Bruno-Service (nicht im App-Target; kommt am Mac in ein Test-Target) |
| `MatheWeideDaten.swift` | SwiftData-Modelle (`Profil`, `StationsFortschritt`) + `FortschrittsService` mit Freischalt-Logik und CloudKit-Duplikat-Bereinigung |

## Architektur-Regel

**Alle Spiellogik kommt aus dem Package** (`LernWeideCore` + `MatheWeide`): Generatoren,
`Runde` (Sterne/Schleife), `GangartTracker`, `Turnierpfad`, `AufgabenPlaner`
(Wiederholungs-Mix), `Bewegungspause`. Die App-Schicht rendert nur und persistiert.
Hier werden **keine Aufgaben neu erfunden** – sonst driften Web-Prototyp und App auseinander.

## CI ohne Mac

- `.github/workflows/ios-build.yml` – Simulator-Build-Check bei jedem Push (ohne Signing)
- `.github/workflows/testflight.yml` – manueller TestFlight-Upload mit Cloud Signing
  (App-Store-Connect-API-Key in den GitHub Secrets)
