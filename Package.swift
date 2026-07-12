// swift-tools-version: 6.0
// Helenas Lern-Weide – Kernlogik als Swift Package
// Plattformunabhängig testbar (CI auf macOS-Runnern, später eingebunden in die iOS-App).

import PackageDescription

let package = Package(
    name: "LernWeide",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Fachübergreifende Logik: Gangarten, Schwierigkeitsanpassung, Fortschritt
        .library(name: "LernWeideCore", targets: ["LernWeideCore"]),
        // Mathe-spezifische Aufgabenlogik (3./4. Klasse, österreichischer Lehrplan)
        .library(name: "MatheWeide", targets: ["MatheWeide"])
    ],
    targets: [
        .target(name: "LernWeideCore"),
        .target(name: "MatheWeide", dependencies: ["LernWeideCore"]),
        .testTarget(name: "LernWeideCoreTests", dependencies: ["LernWeideCore"]),
        .testTarget(name: "MatheWeideTests", dependencies: ["MatheWeide"])
    ]
)
