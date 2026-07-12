# iOS-App-Schicht (wartet auf den Mac)

Diese Dateien gehören zur nativen iOS-App und werden **bewusst nicht** vom Swift Package
(`Package.swift`) kompiliert – sie brauchen iOS-26-Frameworks (Foundation Models, SwiftData
mit CloudKit), die erst im Xcode-Projekt am Mac sinnvoll eingebunden werden. So bleibt die
CI auf GitHub grün, und nichts geht verloren.

| Datei | Inhalt |
|---|---|
| `BrunoErklaerungsService.swift` | Bruno-Erklärungen via Apple Foundation Models (on-device), LLM hinter `TextFormulierer`-Protokoll (mockbar), regelbasierte Fehleranalyse + Fallback. Prinzip: **Code rechnet, LLM formuliert nur.** |
| `BrunoErklaerungsTests.swift` | Swift-Testing-Suite: parametrisierte Fehlerbild-Tests, Mock-Injection, Textqualitäts-Prüfer mit Ziffern-Check (fängt erfundene Zahlen), Live-LLM-Tests mit Latenz-Wächter (überspringen sich ohne Apple Intelligence selbst) |
| `MatheWeideDaten.swift` | SwiftData-Modelle (`Profil`, `StationsFortschritt`) + `FortschrittsService` mit Freischalt-Logik und CloudKit-Duplikat-Bereinigung. iCloud-Sync kommt später ohne Code-Änderung dazu. |

## Einbindung am Mac (Fahrplan)

1. Xcode 26 → Neues Projekt → iOS App → SwiftUI, „Include Tests" (Swift Testing) anhaken
2. Diese drei Dateien ins Projekt ziehen: Service + Daten ins App-Target,
   `BrunoErklaerungsTests.swift` ins Test-Target (dort `@testable import` an den
   Modulnamen anpassen – siehe Kommentar in der Datei)
3. Die Aufgaben-Logik kommt als lokales Package dazu:
   File → Add Package Dependencies → „Add Local…" → dieses Repo-Verzeichnis
   → Produkte `LernWeideCore` und `MatheWeide` einbinden
4. Minimum Deployment iOS 26 (oder iOS 17 + `#available`-Checks für den Regel-Fallback)

Hinweis: Sowohl `BrunoErklaerungsTests.swift` als auch die Package-Tests definieren einen
Tag `liveLLM` – das ist okay, solange sie in getrennten Test-Targets bleiben (tun sie).
