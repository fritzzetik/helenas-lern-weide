import { useState, useEffect, useRef } from "react";

/* ============================================================
   Helenas Lern-Weide 🐶🐴  —  Version 5
   Lern-App Prototyp – Volksschule Österreich (Wien)

   NEU: Daisys Tagesbericht 📸
   - Daisy „macht ein Bild“ mit dem heutigen Fortschritt
   - Tageszeit-Szene: Sonnenaufgang am Morgen, Mittagsbild mit
     Jause, Sonnenuntergang am Abend, Nachtbild mit Mond
   - Datum + Uhrzeit sind fix ins Bild gebrannt (damit man sieht,
     WANN es entstanden ist – auch wenn es mehrmals verschickt wird)
   - Anzahl der heute geübten Aufgaben, Sterne und Schleifen
   - Teilen per iMessage/SMS über das Teilen-Menü des iPhones

   Außerdem: Turnierpfad nach Lehrplan, Schleifen 🎀, adaptive
   Gangarten, Wiederholungs-Mix, verpflichtende 3-Minuten-
   Bewegungspause (startet automatisch, kein Überspringen),
   KI-Erklärung + Quercheck bei Fehlern. ADHS-freundlich.
   ============================================================ */

const PALETTE = {
  sky: "#BDE3F0",
  cream: "#FFF9EC",
  grass: "#7BB662",
  grassDark: "#4E8A3C",
  sun: "#FFD449",
  coral: "#FF8A5C",
  brown: "#A9714B",
  ink: "#33291F",
  soft: "#8C7B6B",
  blue: "#7A9CC6",
  lila: "#C67AB1",
};

const ROUND_LENGTH = 5;
const SCHLEIFE_MIN_STERNE = 4;   // mind. 4 von 5 Sternen …
const SCHLEIFE_MIN_GANGART = 1;  // … in Trab oder Galopp

const GANGARTEN = [
  { name: "Schritt", emoji: "🌿" },
  { name: "Trab", emoji: "🐴" },
  { name: "Galopp", emoji: "💨" },
];

/* ---------- Hilfsfunktionen ---------- */

const rand = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const pick = (arr) => arr[rand(0, arr.length - 1)];
const fmt = (n) => n.toLocaleString("de-AT");

function mach(frage, antwort, thema, hinweis) {
  return { frage, antwort, antwortText: fmt(antwort), thema, hinweis, typ: "zahl" };
}

/* ============================================================
   Generatoren 3. Klasse – in Lehrplan-Reihenfolge
   level: 0 = Schritt, 1 = Trab, 2 = Galopp
   ============================================================ */

/* Station 1: Aufwärmen – Plus & Minus bis 100 (Wiederholung 2. Klasse) */
function genWarm100(level) {
  if (level === 0) {
    // ohne Zehnerübergang
    if (Math.random() < 0.5) {
      const a = rand(2, 7) * 10 + rand(1, 4); const b = rand(1, 5);
      return mach(`${a} + ${b} = ?`, a + b, "Plus bis 100 ohne Übergang", "Nur die Einer ändern sich.");
    }
    const a = rand(2, 8) * 10 + rand(5, 9); const b = rand(1, 4);
    return mach(`${a} − ${b} = ?`, a - b, "Minus bis 100 ohne Übergang", "Nur die Einer ändern sich.");
  }
  if (level === 1) {
    // mit Zehnerübergang
    if (Math.random() < 0.5) {
      const a = rand(15, 60); const b = rand(5, Math.min(39, 100 - a));
      return mach(`${a} + ${b} = ?`, a + b, "Plus bis 100 mit Übergang", "Rechne zuerst bis zum nächsten Zehner, dann den Rest.");
    }
    const a = rand(31, 99); const b = rand(5, 29);
    return mach(`${a} − ${b} = ?`, a - b, "Minus bis 100 mit Übergang", "Zieh zuerst bis zum Zehner ab, dann den Rest.");
  }
  // Ergänzen
  const ziel = pick([50, 70, 80, 100]); const b = rand(11, ziel - 10);
  return mach(`${b} + ? = ${ziel}`, ziel - b, "Ergänzen bis 100", `Wie viel fehlt von ${b} bis ${ziel}?`);
}

/* Station 2: Zahlenraum 1000 entdecken (Stellenwert) */
function genZahlenraum1000(level) {
  if (level === 0) {
    return pick([
      () => { const h = rand(2, 9); const z = rand(1, 9); const e = rand(1, 9); return mach(`${h * 100} + ${z * 10} + ${e} = ?`, h * 100 + z * 10 + e, "Zahlen zusammensetzen", "Hunderter, Zehner und Einer einfach nebeneinander schreiben."); },
      () => { const h = rand(2, 9); return mach(`Wie viele Zehner hat die Zahl ${h * 100}?`, h * 10, "Stellenwert verstehen", `${h * 100} sind ${h} Hunderter – und jeder Hunderter hat 10 Zehner.`); },
      () => { const h = rand(2, 9); const z = rand(1, 9); const e = rand(1, 9); return mach(`Welche Zahl ist das: ${h} H ${z} Z ${e} E?`, h * 100 + z * 10 + e, "Stellenwert verstehen", "H = Hunderter, Z = Zehner, E = Einer."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const start = rand(2, 7) * 100; return mach(`Zähle in Hunderterschritten weiter: ${start}, ${start + 100}, ?`, start + 200, "In Hunderterschritten zählen", "Immer 100 dazu."); },
      () => { const start = rand(15, 88) * 10; return mach(`Zähle in Zehnerschritten weiter: ${start}, ${start + 10}, ?`, start + 20, "In Zehnerschritten zählen", "Immer 10 dazu."); },
      () => { const n = rand(21, 89) * 10 + rand(1, 9); return mach(`Welcher Zehner kommt direkt nach ${n}?`, Math.ceil(n / 10) * 10, "Nachbarzehner finden", "Der nächste Zehner ist die nächste runde Zahl."); },
    ])();
  }
  return pick([
    () => { const a = rand(2, 7) * 100; return mach(`Welche Zahl liegt genau in der Mitte zwischen ${a} und ${a + 200}?`, a + 100, "Zahlen auf dem Zahlenstrahl", "Die Mitte ist gleich weit von beiden entfernt."); },
    () => { const h = rand(3, 9); return mach(`${h * 100} = ? Zehner`, h * 10, "Stellenwerte umdenken", "1 Hunderter sind 10 Zehner."); },
    () => { const n = rand(3, 8) * 100 + rand(1, 9) * 10; return mach(`Welcher Hunderter kommt direkt nach ${n}?`, Math.ceil(n / 100) * 100, "Nachbarhunderter finden", "Der nächste Hunderter ist die nächste runde Hunderterzahl."); },
  ])();
}

/* Station 3: Plus & Minus bis 1000 */
function genPlusMinus1000(level) {
  if (level === 0) {
    // glatte Zehner
    if (Math.random() < 0.5) {
      const a = rand(12, 60) * 10; const b = rand(5, Math.floor((990 - a) / 10)) * 10;
      return mach(`${a} + ${b} = ?`, a + b, "Plus mit glatten Zehnern", "Rechne mit den Zehnern – die Null bleibt.");
    }
    const a = rand(30, 99) * 10; const b = rand(5, Math.floor(a / 10) - 12) * 10;
    return mach(`${a} − ${b} = ?`, a - b, "Minus mit glatten Zehnern", "Rechne mit den Zehnern – die Null bleibt.");
  }
  if (level === 1) {
    if (Math.random() < 0.5) {
      const a = rand(120, 850); const b = rand(15, 999 - a);
      return mach(`${a} + ${b} = ?`, a + b, "Plus im Zahlenraum 1000", "Rechne zuerst die Hunderter, dann die Zehner, dann die Einer.");
    }
    const a = rand(200, 999); const b = rand(15, a - 20);
    return mach(`${a} − ${b} = ?`, a - b, "Minus im Zahlenraum 1000", "Zieh zuerst die Hunderter ab, dann die Zehner, dann die Einer.");
  }
  if (Math.random() < 0.5) {
    const ziel = rand(300, 1000); const b = rand(50, ziel - 50);
    return mach(`? + ${b} = ${ziel}`, ziel - b, "Ergänzen im Zahlenraum 1000", `Rechne rückwärts: ${ziel} minus ${b}.`);
  }
  const a = rand(300, 999); const erg = rand(50, a - 50);
  return mach(`${a} − ? = ${erg}`, a - erg, "Ergänzen im Zahlenraum 1000", `Wie viel fehlt von ${erg} bis ${a}?`);
}

/* Station 4: Malreihen */
function genMalreihen(level) {
  if (level === 0) {
    const a = pick([2, 5, 10]); const b = rand(2, 10);
    return mach(`${a} · ${b} = ?`, a * b, `Malreihe von ${a}`, `Zähl in ${a}er-Schritten: ${a}, ${a * 2}, ${a * 3} …`);
  }
  if (level === 1) {
    const a = rand(2, 10); const b = rand(2, 10);
    return mach(`${a} · ${b} = ?`, a * b, `Malreihe von ${a}`, `Denk an die ${a}er-Reihe: ${a}, ${a * 2}, ${a * 3} …`);
  }
  if (Math.random() < 0.5) {
    const a = rand(2, 9); const b = rand(2, 9) * 10;
    return mach(`${a} · ${b} = ?`, a * b, "Mal-Rechnen mit Zehnerzahlen", `Rechne zuerst ${a} · ${b / 10}, dann häng eine Null an.`);
  }
  const a = rand(3, 9); const b = rand(3, 9);
  return mach(`? · ${a} = ${a * b}`, b, "Fehlenden Faktor finden", `Frag dich: WAS mal ${a} ergibt ${a * b}?`);
}

/* Station 5: In-Rechnungen */
function genInRechnungen(level) {
  if (level === 0) {
    const a = pick([2, 5, 10]); const b = rand(2, 10);
    return mach(`${a * b} : ${a} = ?`, b, "In-Rechnungen mit leichten Reihen", `Frag dich: ${a} mal WAS ergibt ${a * b}?`);
  }
  if (level === 1) {
    const a = rand(2, 10); const b = rand(2, 10);
    return mach(`${a * b} : ${a} = ?`, b, "In-Rechnungen (Dividieren)", `Frag dich: ${a} mal WAS ergibt ${a * b}?`);
  }
  const a = rand(2, 9); const b = rand(2, 9) * 10;
  return mach(`${a * b} : ${a} = ?`, b, "In-Rechnen mit großen Zahlen", `Rechne zuerst ${(a * b) / 10} : ${a}, dann häng eine Null an.`);
}

/* Station 6: Division mit Rest (lt. Lehrplan 3. Klasse!) */
function genRest(level) {
  let teiler, q, rest;
  if (level === 0) {
    teiler = pick([2, 3, 4, 5]); q = rand(2, 9); rest = rand(1, teiler - 1);
  } else if (level === 1) {
    teiler = rand(3, 9); q = rand(4, 10); rest = rand(1, teiler - 1);
  } else {
    teiler = rand(4, 9); q = rand(9, 15); rest = rand(1, teiler - 1);
  }
  const dividend = teiler * q + rest;
  return {
    typ: "rest",
    frage: `${dividend} : ${teiler} = ?  Rest ?`,
    antwort: { q, rest },
    antwortText: `${q}, Rest ${rest}`,
    thema: "Division mit Rest",
    hinweis: `Such die größte Zahl der ${teiler}er-Reihe, die noch in ${dividend} passt (${teiler} · ${q} = ${teiler * q}). Was übrig bleibt, ist der Rest.`,
  };
}

/* Station 7: Längenmaße */
function genLaengen(level) {
  if (level === 0) {
    return pick([
      () => { const m = rand(1, 5); return mach(`${m} m = ? cm`, m * 100, "Längenmaße umwandeln", "1 m sind 100 cm."); },
      () => { const km = rand(1, 5); return mach(`${km} km = ? m`, km * 1000, "Kilometer und Meter", "1 km sind 1000 m."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const m = rand(2, 9); const cm = pick([10, 20, 40, 50]); return mach(`${m} m ${cm} cm = ? cm`, m * 100 + cm, "Längenmaße umwandeln", "1 m sind 100 cm – dann die restlichen cm dazuzählen."); },
      () => { const km = rand(2, 9); const m = pick([200, 500, 250]); return mach(`${km} km ${m} m = ? m`, km * 1000 + m, "Kilometer und Meter", "1 km sind 1000 m – dann die restlichen Meter dazuzählen."); },
    ])();
  }
  return pick([
    () => { const m = rand(2, 9); return mach(`${m * 100} cm = ? m`, m, "Längenmaße rückwärts", "100 cm sind 1 m."); },
    () => { const km = rand(2, 9); return mach(`${fmt(km * 1000)} m = ? km`, km, "Meter rückwärts in Kilometer", "1000 m sind 1 km."); },
  ])();
}

/* Station 8: Gewichte (mit dag!) */
function genGewichte(level) {
  if (level === 0) {
    return pick([
      () => { const kg = rand(1, 5); return mach(`${kg} kg = ? dag`, kg * 100, "Gewichte umwandeln", "1 kg sind 100 dag."); },
      () => { const dag = rand(2, 9); return mach(`${dag} dag = ? g`, dag * 10, "Gewichte umwandeln", "1 dag sind 10 g."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const kg = rand(2, 9); const dag = pick([20, 50, 25, 75]); return mach(`${kg} kg ${dag} dag = ? dag`, kg * 100 + dag, "Gewichte umwandeln", "1 kg sind 100 dag – dann die restlichen dag dazuzählen."); },
      () => { const dag = rand(2, 9); const g = rand(1, 9); return mach(`${dag} dag ${g} g = ? g`, dag * 10 + g, "Gewichte umwandeln", "1 dag sind 10 g – dann die restlichen g dazuzählen."); },
    ])();
  }
  return pick([
    () => { const kg = rand(2, 9); return mach(`${kg * 100} dag = ? kg`, kg, "Gewichte rückwärts", "100 dag sind 1 kg."); },
    () => { const dag = rand(3, 9); return mach(`${dag * 10} g = ? dag`, dag, "Gramm rückwärts in dag", "10 g sind 1 dag."); },
  ])();
}

/* Station 9: Geld & Zeit */
function genGeldZeit(level) {
  if (level === 0) {
    return pick([
      () => { const e = rand(1, 5); return mach(`${e} € = ? c`, e * 100, "Mit Geld rechnen", "1 € sind 100 c."); },
      () => { const h = rand(1, 3); return mach(`${h} h = ? min`, h * 60, "Zeitmaße umwandeln", "1 Stunde sind 60 Minuten."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const e = rand(2, 8); const c = pick([10, 20, 50]); return mach(`${e} € ${c} c = ? c`, e * 100 + c, "Euro und Cent", "1 € sind 100 c."); },
      () => { const h = rand(1, 3); return mach(`${h} h 30 min = ? min`, h * 60 + 30, "Zeitmaße mit halben Stunden", "1 Stunde sind 60 Minuten – die 30 Minuten dazuzählen."); },
    ])();
  }
  return pick([
    () => { const preis = rand(2, 4) * 100 + pick([0, 50]); return mach(`Etwas kostet ${preis} c. Du zahlst mit 5 €. Wie viel Cent bekommst du zurück?`, 500 - preis, "Rückgeld berechnen", "5 € sind 500 c. Zieh den Preis ab."); },
    () => { const min = pick([120, 180, 240]); return mach(`${min} min = ? h`, min / 60, "Zeitmaße rückwärts", "60 Minuten sind 1 Stunde."); },
  ])();
}

/* Station 10: 🏆 Abschlussturnier – gemischte Sachaufgaben */
function genSach3(level) {
  if (level === 0) {
    return pick([
      () => { const a = rand(2, 5); const b = rand(2, 5); return mach(`Bruno bekommt am Vormittag ${a} Leckerlis und am Nachmittag ${b}. Wie viele sind das zusammen?`, a + b, "Sachaufgaben mit Plus", "Zusammen heißt: zusammenzählen."); },
      () => { const a = rand(8, 15); const b = rand(2, 6); return mach(`Im Korb liegen ${a} Hundekekse. Bruno frisst ${b} davon. Wie viele bleiben übrig?`, a - b, "Sachaufgaben mit Minus", "Übrig bleiben heißt: abziehen."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const a = rand(2, 6); const b = rand(5, 9); return mach(`Bruno bekommt jeden Tag ${a} Leckerlis. Wie viele Leckerlis bekommt er in ${b} Tagen?`, a * b, "Sachaufgaben mit Mal-Rechnungen", `Rechne ${a} · ${b}.`); },
      () => { const kinder = pick([2, 3, 4]); const gesamt = rand(3, 9) * kinder; return mach(`${gesamt} Karotten werden gerecht auf ${kinder} Pferde aufgeteilt. Wie viele Karotten bekommt jedes Pferd?`, gesamt / kinder, "Sachaufgaben mit In-Rechnungen", `Rechne ${gesamt} : ${kinder}.`); },
      () => { const a = rand(150, 450); const b = rand(120, 400); return mach(`Beim Spaziergang läuft Bruno zuerst ${a} m, dann noch ${b} m. Wie viele Meter läuft er insgesamt?`, a + b, "Sachaufgaben mit Plus", "Insgesamt heißt: zusammenzählen."); },
    ])();
  }
  return pick([
    () => { const proTag = rand(4, 7); const vorrat = proTag * 7 + rand(3, 9); return mach(`Im Sackerl sind ${vorrat} Karotten. Daisy frisst jeden Tag ${proTag} Karotten. Wie viele Karotten sind nach einer Woche noch im Sackerl?`, vorrat - proTag * 7, "Zwei-Schritt-Sachaufgaben", `Rechne zuerst ${proTag} · 7, dann zieh das von ${vorrat} ab.`); },
    () => { const preis1 = rand(2, 3) * 100; const preis2 = pick([50, 100, 150]); return mach(`Eine Bürste für Daisy kostet ${preis1} c, ein Ball für Bruno ${preis2} c. Du zahlst mit 5 €. Wie viel Cent bekommst du zurück?`, 500 - preis1 - preis2, "Zwei-Schritt-Sachaufgaben mit Geld", "Zähl zuerst beide Preise zusammen. 5 € sind 500 c."); },
    () => { const runde = rand(150, 300); return mach(`Eine Runde um die Koppel ist ${runde} m lang. Daisy galoppiert 3 Runden. Wie viele Meter sind das?`, runde * 3, "Zwei-Schritt-Sachaufgaben", `Rechne ${runde} · 3.`); },
  ])();
}

/* ============================================================
   Generatoren 4. Klasse – in Lehrplan-Reihenfolge
   ============================================================ */

/* Station 1: Zahlenraum 100.000 entdecken */
function genZahlenraum100k(level) {
  if (level === 0) {
    return pick([
      () => { const zt = rand(1, 9); const t = rand(1, 9); const h = rand(1, 9); return mach(`${fmt(zt * 10000)} + ${fmt(t * 1000)} + ${h * 100} = ?`, zt * 10000 + t * 1000 + h * 100, "Große Zahlen zusammensetzen", "Zehntausender, Tausender und Hunderter nebeneinander schreiben."); },
      () => { const t = rand(2, 9); return mach(`Wie viele Hunderter hat die Zahl ${fmt(t * 1000)}?`, t * 10, "Stellenwert verstehen", `${fmt(t * 1000)} sind ${t} Tausender – und jeder Tausender hat 10 Hunderter.`); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const start = rand(23, 88) * 1000; return mach(`Zähle in Tausenderschritten weiter: ${fmt(start)}, ${fmt(start + 1000)}, ?`, start + 2000, "In Tausenderschritten zählen", "Immer 1000 dazu."); },
      () => { const n = rand(21, 89) * 1000 + rand(1, 9) * 100; return mach(`Welcher Tausender kommt direkt nach ${fmt(n)}?`, Math.ceil(n / 1000) * 1000, "Nachbartausender finden", "Der nächste Tausender ist die nächste runde Tausenderzahl."); },
    ])();
  }
  return pick([
    () => { const a = rand(2, 7) * 10000; return mach(`Welche Zahl liegt genau in der Mitte zwischen ${fmt(a)} und ${fmt(a + 20000)}?`, a + 10000, "Zahlen auf dem Zahlenstrahl", "Die Mitte ist gleich weit von beiden entfernt."); },
    () => { const zt = rand(2, 9); return mach(`${fmt(zt * 10000)} = ? Tausender`, zt * 10, "Stellenwerte umdenken", "1 Zehntausender sind 10 Tausender."); },
  ])();
}

/* Station 2: Plus & Minus bis 100.000 */
function genPlusMinus100k(level) {
  if (level === 0) {
    if (Math.random() < 0.5) {
      const a = rand(12, 68) * 100; const b = rand(11, Math.floor((9900 - a) / 100)) * 100;
      return mach(`${fmt(a)} + ${fmt(b)} = ?`, a + b, "Plus im Zahlenraum 10.000", "Rechne mit den Tausendern und Hundertern – die Nullen bleiben.");
    }
    const a = rand(40, 99) * 100; const b = rand(11, Math.floor(a / 100) - 15) * 100;
    return mach(`${fmt(a)} − ${fmt(b)} = ?`, a - b, "Minus im Zahlenraum 10.000", "Zieh die Tausender und Hunderter ab – die Nullen bleiben.");
  }
  if (level === 1) {
    if (Math.random() < 0.5) {
      const a = rand(120, 750) * 100; const b = rand(50, Math.floor((99000 - a) / 100)) * 100;
      return mach(`${fmt(a)} + ${fmt(b)} = ?`, a + b, "Plus im Zahlenraum 100.000", "Denk in Hunderterschritten: die letzten zwei Nullen bleiben.");
    }
    const a = rand(300, 990) * 100; const b = rand(50, Math.floor(a / 100) - 60) * 100;
    return mach(`${fmt(a)} − ${fmt(b)} = ?`, a - b, "Minus im Zahlenraum 100.000", "Denk in Hunderterschritten: die letzten zwei Nullen bleiben.");
  }
  return pick([
    () => { const ziel = rand(20, 100) * 1000; const b = rand(5, ziel / 1000 - 4) * 1000; return mach(`? + ${fmt(b)} = ${fmt(ziel)}`, ziel - b, "Ergänzen im Zahlenraum 100.000", `Rechne rückwärts: ${fmt(ziel)} minus ${fmt(b)}.`); },
    () => { const b = rand(10, 90) * 1000; return mach(`${fmt(b)} + ? = ${fmt(100000)}`, 100000 - b, "Ergänzen auf 100.000", `Wie viel fehlt von ${fmt(b)} bis ${fmt(100000)}?`); },
  ])();
}

/* Station 3: Runden & Überschlagen */
function genRunden(level) {
  if (level === 0) {
    let n; do { n = rand(21, 289); } while (n % 10 === 0);
    const gerundet = Math.round(n / 10) * 10;
    return mach(`Runde ${n} auf Zehner.`, gerundet, "Auf Zehner runden", "Schau auf die Einerstelle: 0–4 → abrunden, 5–9 → aufrunden.");
  }
  if (level === 1) {
    let n; do { n = rand(210, 8900); } while (n % 100 === 0);
    const gerundet = Math.round(n / 100) * 100;
    return mach(`Runde ${fmt(n)} auf Hunderter.`, gerundet, "Auf Hunderter runden", "Schau auf die Zehnerstelle: 0–4 → abrunden, 5–9 → aufrunden.");
  }
  return pick([
    () => { let n; do { n = rand(2100, 89000); } while (n % 1000 === 0); const g = Math.round(n / 1000) * 1000; return mach(`Runde ${fmt(n)} auf Tausender.`, g, "Auf Tausender runden", "Schau auf die Hunderterstelle: 0–4 → abrunden, 5–9 → aufrunden."); },
    () => { const a = rand(180, 640); const b = rand(180, 640); const g = Math.round(a / 100) * 100 + Math.round(b / 100) * 100; return mach(`Überschlage: ${a} + ${b} ≈ ?  (beide Zahlen auf Hunderter runden)`, g, "Überschlagsrechnen", `Runde zuerst: ${a} ≈ ${Math.round(a / 100) * 100} und ${b} ≈ ${Math.round(b / 100) * 100}. Dann zusammenzählen.`); },
    () => { const a = rand(21, 78); const b = rand(3, 6); const g = Math.round(a / 10) * 10 * b; return mach(`Überschlage: ${a} · ${b} ≈ ?  (${a} auf Zehner runden)`, g, "Überschlagsrechnen", `Runde zuerst: ${a} ≈ ${Math.round(a / 10) * 10}. Dann mal ${b}.`); },
  ])();
}

/* Station 4: Mal & In mit großen Zahlen */
function genMalIn100k(level) {
  if (level === 0) {
    return pick([
      () => { const a = rand(12, 25); const b = rand(2, 4); return mach(`${a} · ${b} = ?`, a * b, "Mal-Rechnen mit zweistelligen Zahlen", `Zerlege: ${Math.floor(a / 10) * 10} · ${b} und ${a % 10} · ${b}, dann zusammenzählen.`); },
      () => { const a = rand(12, 89); return mach(`${a} · 10 = ?`, a * 10, "Mal 10 rechnen", "Mal 10 heißt: eine Null anhängen."); },
      () => { const a = rand(3, 9); return mach(`${a} · 100 = ?`, a * 100, "Mal 100 rechnen", "Mal 100 heißt: zwei Nullen anhängen."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const a = rand(13, 48); const b = rand(3, 9); return mach(`${a} · ${b} = ?`, a * b, "Mal-Rechnen mit zweistelligen Zahlen", `Zerlege: ${Math.floor(a / 10) * 10} · ${b} plus ${a % 10} · ${b}.`); },
      () => { const b = rand(3, 9); const q = rand(11, 24); return mach(`${b * q} : ${b} = ?`, q, "In-Rechnen über das Einmaleins hinaus", `Zerlege ${b * q} in Teile, die du durch ${b} teilen kannst.`); },
      () => { const a = rand(120, 890); return mach(`${fmt(a)} · 10 = ?`, a * 10, "Mal 10 mit großen Zahlen", "Mal 10 heißt: eine Null anhängen."); },
    ])();
  }
  return pick([
    () => { const a = pick([120, 150, 210, 240, 320, 250]); const b = rand(3, 4); return mach(`${a} · ${b} = ?`, a * b, "Mal-Rechnen mit dreistelligen Zahlen", `Rechne zuerst ${a / 10} · ${b}, dann häng eine Null an.`); },
    () => { const a = rand(12, 89) * 100; return mach(`${fmt(a)} : 100 = ?`, a / 100, "Durch 100 dividieren", "Durch 100 heißt: zwei Nullen wegnehmen."); },
    () => { const b = rand(3, 9); const q = rand(3, 9) * 10; return mach(`? · ${b} = ${fmt(b * q)}`, q, "Fehlenden Faktor mit Zehnerzahlen finden", `Frag dich: WAS mal ${b} ergibt ${fmt(b * q)}? Denk in Zehnern.`); },
  ])();
}

/* Station 5: Neue Maße (t, mm, s) */
function genMasseNeu(level) {
  if (level === 0) {
    return pick([
      () => { const t = rand(1, 5); return mach(`${t} t = ? kg`, t * 1000, "Tonnen und Kilogramm", "1 t sind 1000 kg. Daisy wiegt ungefähr eine halbe Tonne!"); },
      () => { const cm = rand(2, 9); return mach(`${cm} cm = ? mm`, cm * 10, "Zentimeter und Millimeter", "1 cm sind 10 mm."); },
      () => { const min = rand(1, 4); return mach(`${min} min = ? s`, min * 60, "Minuten und Sekunden", "1 Minute sind 60 Sekunden."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const t = rand(1, 4); const kg = pick([200, 500, 250, 750]); return mach(`${t} t ${kg} kg = ? kg`, t * 1000 + kg, "Tonnen und Kilogramm", "1 t sind 1000 kg – dann die restlichen kg dazuzählen."); },
      () => { const cm = rand(2, 9); const mm = rand(1, 9); return mach(`${cm} cm ${mm} mm = ? mm`, cm * 10 + mm, "Zentimeter und Millimeter", "1 cm sind 10 mm – dann die restlichen mm dazuzählen."); },
      () => { const min = rand(1, 3); const s = pick([15, 30, 45]); return mach(`${min} min ${s} s = ? s`, min * 60 + s, "Minuten und Sekunden", "1 Minute sind 60 Sekunden – dann die restlichen Sekunden dazuzählen."); },
    ])();
  }
  return pick([
    () => { const t = rand(2, 9); return mach(`${fmt(t * 1000)} kg = ? t`, t, "Kilogramm rückwärts in Tonnen", "1000 kg sind 1 t."); },
    () => { const cm = rand(3, 9); return mach(`${cm * 10} mm = ? cm`, cm, "Millimeter rückwärts", "10 mm sind 1 cm."); },
    () => { const min = rand(2, 4); return mach(`${min * 60} s = ? min`, min, "Sekunden rückwärts", "60 Sekunden sind 1 Minute."); },
  ])();
}

/* Station 6: 🏆 Abschlussturnier 4. Klasse */
function genSach4(level) {
  if (level === 0) {
    return pick([
      () => { const a = rand(15, 35); const b = rand(3, 6); return mach(`Ein Sack Pferdefutter wiegt ${a} kg. Wie viel wiegen ${b} Säcke?`, a * b, "Sachaufgaben mit Mal", `Rechne ${a} · ${b}.`); },
      () => { const a = rand(12, 45) * 100; const b = rand(11, 40) * 100; return mach(`Der Reiterhof kauft Heu um ${fmt(a)} c und Stroh um ${fmt(b)} c. Wie viel Cent kostet das zusammen?`, a + b, "Sachaufgaben mit Plus", "Zusammen heißt: zusammenzählen."); },
    ])();
  }
  if (level === 1) {
    return pick([
      () => { const runde = rand(350, 850); return mach(`Eine große Runde um die Koppel ist ${runde} m. Daisy läuft sie 4-mal. Wie viele Meter sind das?`, runde * 4, "Sachaufgaben mit Mal", `Rechne ${runde} · 4 – zerlege in Hunderter und Rest.`); },
      () => { const kg = rand(4, 8); return mach(`Daisy frisst ${kg} kg Heu am Tag. Wie viele kg sind das in 2 Wochen?`, kg * 14, "Zwei-Schritt-Sachaufgaben", "2 Wochen sind 14 Tage."); },
      () => { const preis = rand(45, 95) * 100; const bezahlt = 10000; return mach(`Ein neuer Sattel kostet ${fmt(preis)} c. Du zahlst mit 100 €. Wie viel Cent bekommst du zurück?`, bezahlt - preis, "Sachaufgaben mit Geld", "100 € sind 10.000 c. Zieh den Preis ab."); },
    ])();
  }
  return pick([
    () => { const proTag = rand(5, 8); const tage = 14; const vorrat = proTag * tage + rand(5, 20); return mach(`Im Lager sind ${vorrat} kg Heu. Daisy frisst ${proTag} kg am Tag. Wie viele kg bleiben nach 2 Wochen übrig?`, vorrat - proTag * tage, "Zwei-Schritt-Sachaufgaben", `Rechne zuerst ${proTag} · 14, dann zieh das von ${vorrat} ab.`); },
    () => { const a = rand(180, 420); return mach(`Bruno läuft jeden Tag ungefähr ${a} m beim Gassigehen – und das 2-mal am Tag. Wie viele Meter sind das in einer Woche?`, a * 2 * 7, "Zwei-Schritt-Sachaufgaben", `Rechne zuerst ${a} · 2 für einen Tag, dann mal 7.`); },
    () => { const saecke = rand(3, 6); const proSack = rand(15, 25); const geliefert = saecke * proSack + rand(10, 30); return mach(`Der Hof bestellt ${saecke} Säcke Futter zu je ${proSack} kg. Geliefert werden aber ${geliefert} kg. Wie viele kg sind das zu viel?`, geliefert - saecke * proSack, "Zwei-Schritt-Sachaufgaben", `Rechne zuerst ${saecke} · ${proSack}, dann den Unterschied.`); },
  ])();
}

/* ============================================================
   Turnierpfade – Stationen in Lehrplan-Reihenfolge
   mix: true → Station mischt Wiederholungsaufgaben aus
   bereits geschafften Stationen bei (jede 3. Station)
   ============================================================ */

const TURNIERPFADE = [
  {
    id: "klasse3",
    titel: "3. Klasse",
    emoji: "🏠",
    stationen: [
      { id: "s3_warm", emoji: "🐾", titel: "Aufwärmen: Plus & Minus bis 100", sub: "Wiederholung", gen: genWarm100, farbe: PALETTE.grass },
      { id: "s3_zr", emoji: "🔢", titel: "Zahlenraum 1000 entdecken", sub: "Hunderter, Zehner, Einer", gen: genZahlenraum1000, farbe: PALETTE.blue },
      { id: "s3_pm", emoji: "➕", titel: "Plus & Minus bis 1000", sub: "rechnen im großen Raum", gen: genPlusMinus1000, farbe: PALETTE.grass, mix: true },
      { id: "s3_mal", emoji: "✖️", titel: "Malreihen sichern", sub: "das Einmaleins", gen: genMalreihen, farbe: PALETTE.coral },
      { id: "s3_in", emoji: "🍏", titel: "In-Rechnungen", sub: "Teilen lernen", gen: genInRechnungen, farbe: PALETTE.coral },
      { id: "s3_rest", emoji: "➗", titel: "Division mit Rest", sub: "z. B. 47 : 5", gen: genRest, farbe: PALETTE.blue, mix: true },
      { id: "s3_laenge", emoji: "📏", titel: "Längenmaße", sub: "m, cm, km", gen: genLaengen, farbe: PALETTE.sun },
      { id: "s3_gewicht", emoji: "⚖️", titel: "Gewichte", sub: "kg, dag, g", gen: genGewichte, farbe: PALETTE.sun },
      { id: "s3_geld", emoji: "💶", titel: "Geld & Zeit", sub: "€, c, h, min", gen: genGeldZeit, farbe: PALETTE.sun, mix: true },
      { id: "s3_final", emoji: "🏆", titel: "Abschlussturnier", sub: "gemischte Sachaufgaben", gen: genSach3, farbe: PALETTE.lila, mix: true },
    ],
  },
  {
    id: "klasse4",
    titel: "4. Klasse",
    emoji: "🏇",
    stationen: [
      { id: "s4_zr", emoji: "🔢", titel: "Zahlenraum 100.000 entdecken", sub: "große Zahlen verstehen", gen: genZahlenraum100k, farbe: PALETTE.blue },
      { id: "s4_pm", emoji: "➕", titel: "Plus & Minus bis 100.000", sub: "rechnen im großen Raum", gen: genPlusMinus100k, farbe: PALETTE.grass },
      { id: "s4_rund", emoji: "🎯", titel: "Runden & Überschlagen", sub: "≈ ungefähr rechnen", gen: genRunden, farbe: PALETTE.lila, mix: true },
      { id: "s4_mal", emoji: "✖️", titel: "Mal & In mit großen Zahlen", sub: "geschickt zerlegen", gen: genMalIn100k, farbe: PALETTE.coral },
      { id: "s4_masse", emoji: "⚖️", titel: "Neue Maße", sub: "t, mm, s", gen: genMasseNeu, farbe: PALETTE.sun },
      { id: "s4_final", emoji: "🏆", titel: "Abschlussturnier", sub: "gemischte Sachaufgaben", gen: genSach4, farbe: PALETTE.lila, mix: true },
    ],
  },
];

const ALLE_STATION_IDS = TURNIERPFADE.flatMap((p) => p.stationen.map((s) => s.id));

const PAUSEN = [
  "Hüpf 10-mal auf der Stelle – so wie Bruno, wenn er sich freut! 🐶",
  "Galoppiere einmal durchs Zimmer wie Daisy! 🐴",
  "Streck dich sooo hoch, wie Daisy groß ist! 🙆",
  "Mach 5 Hampelmänner – Bruno zählt mit! 🐾",
  "Trink einen Schluck Wasser und schüttel dich wie Bruno nach dem Baden! 💦",
];

const LOB = ["Super, Helena! 🌟", "Wuff! Richtig! 🐶", "Daisy wiehert vor Freude! 🐴", "Stark gerechnet! 💪", "Genau richtig! ✨"];

/* ---------- KI-Erklärung + Quercheck ---------- */

async function holeErklaerung(task, falscheAntwortText) {
  const prompt = `Du bist Bruno, ein freundlicher Hund, und hilfst Helena (Volksschülerin aus Wien, sie hat ADHS) beim Mathe-Lernen.

Aufgabe war: "${task.frage}"
Richtige Antwort: ${task.antwortText}
Helenas Antwort: ${falscheAntwortText}
Thema: ${task.thema}

Erkläre das zugrundeliegende Wissen. Regeln:
- Maximal 3 sehr kurze Sätze, einfache Wörter für ein Volksschulkind
- Du-Form, freundlich, niemals tadeln
- Nutze wenn möglich Bruno (Hund) oder Daisy (Pferd) als Beispiel
- Österreichisches Deutsch (Wien): z. B. dag, In-Rechnung, Karotten (nie Möhren), Sackerl (nie Tüte), Jänner (nie Januar), Jause, Paradeiser
- Erstelle danach EINE neue, ähnliche Quercheck-Aufgabe zum selben Wissen mit einer einzelnen ZAHL als Antwort (keine Division mit Rest, keine zwei Zahlen!)

Antworte NUR mit JSON, ohne Markdown, exakt so:
{"erklaerung":"...","quercheckFrage":"...","quercheckAntwort":123}`;

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "claude-sonnet-4-6",
      max_tokens: 1000,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  const data = await response.json();
  const text = data.content
    .filter((b) => b.type === "text")
    .map((b) => b.text)
    .join("\n")
    .replace(/```json|```/g, "")
    .trim();
  const parsed = JSON.parse(text);
  if (!parsed.erklaerung || !parsed.quercheckFrage || typeof parsed.quercheckAntwort !== "number") {
    throw new Error("Unvollständige KI-Antwort");
  }
  return parsed;
}

function fallbackErklaerung(task) {
  return {
    erklaerung: `Kein Problem! Merk dir: ${task.hinweis} Bruno glaubt an dich! 🐶`,
    quercheckFrage: null,
    quercheckAntwort: null,
  };
}

/* ---------- Ziffernblock ---------- */

function NumPad({ value, onChange, onSubmit, disabled, maxLen = 6 }) {
  const keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  return (
    <div className="numpad">
      <div className="numpad-display" aria-live="polite">
        {value === "" ? <span className="numpad-placeholder">Deine Zahl…</span> : fmt(parseInt(value, 10))}
      </div>
      <div className="numpad-grid">
        {keys.map((k) => (
          <button key={k} className="numpad-key" disabled={disabled} onClick={() => value.length < maxLen && onChange(value + k)}>
            {k}
          </button>
        ))}
        <button className="numpad-key numpad-del" disabled={disabled} onClick={() => onChange(value.slice(0, -1))}>
          ⌫
        </button>
        <button className="numpad-key numpad-ok" disabled={disabled || value === ""} onClick={onSubmit}>
          ✓
        </button>
      </div>
    </div>
  );
}

/* ---------- Doppel-Eingabe für Division mit Rest ---------- */

function RestPad({ onSubmit, disabled }) {
  const [q, setQ] = useState("");
  const [rest, setRest] = useState("");
  const [feld, setFeld] = useState("q");
  const keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  const aktiv = feld === "q" ? q : rest;
  const setAktiv = feld === "q" ? setQ : setRest;

  return (
    <div className="numpad">
      <div className="rest-row">
        <button className={feld === "q" ? "rest-feld on" : "rest-feld"} onClick={() => setFeld("q")}>
          <span className="rest-label">Ergebnis</span>
          <span className="rest-wert">{q === "" ? "…" : q}</span>
        </button>
        <button className={feld === "rest" ? "rest-feld on" : "rest-feld"} onClick={() => setFeld("rest")}>
          <span className="rest-label">Rest</span>
          <span className="rest-wert">{rest === "" ? "…" : rest}</span>
        </button>
      </div>
      <div className="numpad-grid">
        {keys.map((k) => (
          <button key={k} className="numpad-key" disabled={disabled} onClick={() => aktiv.length < 3 && setAktiv(aktiv + k)}>
            {k}
          </button>
        ))}
        <button className="numpad-key numpad-del" disabled={disabled} onClick={() => setAktiv(aktiv.slice(0, -1))}>
          ⌫
        </button>
        <button
          className="numpad-key numpad-ok"
          disabled={disabled || (feld === "q" ? q === "" : rest === "")}
          onClick={() => {
            if (feld === "q") {
              setFeld("rest");
            } else if (q !== "" && rest !== "") {
              onSubmit({ q: parseInt(q, 10), rest: parseInt(rest, 10) });
              setQ(""); setRest(""); setFeld("q");
            }
          }}
        >
          ✓
        </button>
      </div>
      <p className="rest-tipp">Zuerst das Ergebnis eintippen und ✓ drücken – dann den Rest. 🐾</p>
    </div>
  );
}

/* ---------- Daisys Tagesbericht 📸 (Canvas-Bild zum Teilen) ---------- */

function rundesRechteck(x, y, w, h, r, ctx) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

/* Erzeugt das Berichts-Canvas. Datum/Uhrzeit werden fest ins Bild
   gezeichnet – so ist immer erkennbar, wann der Bericht entstand,
   auch wenn Helena ihn dreimal verschickt. 😄 */
function malTagesbericht(stats) {
  const W = 1000, H = 1250;
  const c = document.createElement("canvas");
  c.width = W; c.height = H;
  const ctx = c.getContext("2d");

  const jetzt = new Date();
  const stunde = jetzt.getHours();
  const zeit = stunde >= 5 && stunde < 11 ? "morgen"
    : stunde < 15 ? "mittag"
    : stunde < 20 ? "abend" : "nacht";

  const HORIZONT = 720;

  /* --- Himmel je nach Tageszeit --- */
  const himmel = ctx.createLinearGradient(0, 0, 0, HORIZONT);
  if (zeit === "morgen") {
    himmel.addColorStop(0, "#9FD8F5"); himmel.addColorStop(0.6, "#FFE29A"); himmel.addColorStop(1, "#FFB347");
  } else if (zeit === "mittag") {
    himmel.addColorStop(0, "#5FB9E8"); himmel.addColorStop(1, "#BDE3F0");
  } else if (zeit === "abend") {
    himmel.addColorStop(0, "#8E6BB5"); himmel.addColorStop(0.55, "#FF9E7A"); himmel.addColorStop(1, "#FF8A5C");
  } else {
    himmel.addColorStop(0, "#141F3D"); himmel.addColorStop(1, "#2E4372");
  }
  ctx.fillStyle = himmel;
  ctx.fillRect(0, 0, W, HORIZONT);

  /* --- Sonne / Mond / Sterne --- */
  if (zeit === "nacht") {
    // Sterne (deterministisch verteilt, damit das Bild ruhig wirkt)
    ctx.fillStyle = "#FFF7DD";
    for (let i = 0; i < 40; i++) {
      const sx = ((i * 173) % W);
      const sy = ((i * 97) % (HORIZONT - 160)) + 30;
      const gr = i % 5 === 0 ? 4 : 2.5;
      ctx.beginPath(); ctx.arc(sx, sy, gr, 0, Math.PI * 2); ctx.fill();
    }
    // Mond mit Sichel
    ctx.fillStyle = "#FFF4D6";
    ctx.beginPath(); ctx.arc(780, 180, 85, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#1B2A4A";
    ctx.beginPath(); ctx.arc(815, 160, 72, 0, Math.PI * 2); ctx.fill();
  } else {
    const sonne = { morgen: { x: 500, y: HORIZONT - 20, r: 115 }, mittag: { x: 800, y: 170, r: 95 }, abend: { x: 500, y: HORIZONT - 10, r: 105 } }[zeit];
    // Strahlen
    ctx.strokeStyle = zeit === "abend" ? "#FFB07A" : "#FFD449";
    ctx.lineWidth = 10; ctx.lineCap = "round";
    for (let i = 0; i < 12; i++) {
      const w = (i / 12) * Math.PI * 2;
      ctx.beginPath();
      ctx.moveTo(sonne.x + Math.cos(w) * (sonne.r + 22), sonne.y + Math.sin(w) * (sonne.r + 22));
      ctx.lineTo(sonne.x + Math.cos(w) * (sonne.r + 58), sonne.y + Math.sin(w) * (sonne.r + 58));
      ctx.stroke();
    }
    ctx.fillStyle = zeit === "abend" ? "#FF9E4F" : "#FFD449";
    ctx.beginPath(); ctx.arc(sonne.x, sonne.y, sonne.r, 0, Math.PI * 2); ctx.fill();
  }

  /* --- Wiese --- */
  const wiese = ctx.createLinearGradient(0, HORIZONT, 0, H);
  if (zeit === "nacht") {
    wiese.addColorStop(0, "#3E5C34"); wiese.addColorStop(1, "#2A4023");
  } else {
    wiese.addColorStop(0, "#8FC46F"); wiese.addColorStop(1, "#4E8A3C");
  }
  ctx.fillStyle = wiese;
  ctx.fillRect(0, HORIZONT, W, H - HORIZONT);

  /* --- Titel-Banner oben --- */
  ctx.textAlign = "center";
  ctx.fillStyle = zeit === "nacht" ? "#FFF7DD" : "#FFFFFF";
  ctx.shadowColor = "rgba(0,0,0,0.35)"; ctx.shadowBlur = 10;
  ctx.font = "bold 56px 'Baloo 2', 'Arial Rounded MT Bold', sans-serif";
  ctx.fillText("Daisys Tagesbericht", W / 2, 92);
  ctx.font = "bold 34px 'Baloo 2', sans-serif";
  const gruss = { morgen: "Guten Morgen! 🌅", mittag: "Mahlzeit! 🥪", abend: "Guten Abend! 🌇", nacht: "Gute Nacht! 🌙" }[zeit];
  ctx.fillText(gruss, W / 2, 148);
  ctx.shadowBlur = 0;

  /* --- Tiere & Deko auf der Wiese --- */
  // Daisy ist ein Schimmel: Filter macht das Pferde-Emoji weiß
  ctx.save();
  ctx.filter = "grayscale(1) brightness(1.85)";
  ctx.font = "170px serif";
  ctx.fillText("🐴", 300, HORIZONT + 170);
  ctx.restore();
  ctx.font = "120px serif";
  ctx.fillText("🐶", 620, HORIZONT + 175);
  ctx.font = "54px serif";
  ctx.fillText("🌼", 120, HORIZONT + 70);
  ctx.fillText("🌼", 880, HORIZONT + 190);
  if (zeit === "mittag") {
    ctx.font = "100px serif";
    ctx.fillText("🧺", 820, HORIZONT + 90);   // die Jause!
    ctx.font = "56px serif";
    ctx.fillText("🍎", 890, HORIZONT + 130);
  }

  /* --- Statistik-Karte unten (mit eingebranntem Datum) --- */
  ctx.fillStyle = "rgba(255, 249, 236, 0.96)";
  rundesRechteck(60, 950, W - 120, 240, 34, ctx);
  ctx.fill();

  ctx.fillStyle = "#33291F";
  ctx.font = "bold 42px 'Baloo 2', sans-serif";
  ctx.fillText("Helenas Lern-Weide 🎀", W / 2, 1015);

  const datumText = jetzt.toLocaleDateString("de-AT", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
  const zeitText = jetzt.toLocaleTimeString("de-AT", { hour: "2-digit", minute: "2-digit" });
  ctx.font = "600 32px 'Nunito', sans-serif";
  ctx.fillStyle = "#8C7B6B";
  ctx.fillText(`${datumText} · ${zeitText} Uhr`, W / 2, 1068);

  ctx.fillStyle = "#33291F";
  ctx.font = "bold 38px 'Baloo 2', sans-serif";
  ctx.fillText(
    `${stats.aufgaben} ${stats.aufgaben === 1 ? "Aufgabe" : "Aufgaben"} geübt  ·  ${stats.sterne} ⭐  ·  ${stats.schleifen} 🎀`,
    W / 2, 1140
  );

  return c;
}

/* ---------- Bewegungspausen-Timer (3 Minuten, verpflichtend) ----------
   Startet automatisch und kann nicht übersprungen werden: Bewegung ist
   Teil des Lernens, keine Option. Erst wenn die Pause vorbei ist,
   erscheinen die Weiter-Buttons (siehe done-Screen). */

const PAUSE_SEKUNDEN = 180;

function PausenTimer({ onFertig }) {
  const [status, setStatus] = useState("laeuft"); // laeuft | fertig
  const [restzeit, setRestzeit] = useState(PAUSE_SEKUNDEN);
  // Das Pausenende ist ein fixer Zeitpunkt, keine Tick-Zählung:
  // So läuft die Pause auch weiter, wenn das Display gesperrt oder die
  // App im Hintergrund ist (dort friert der Browser setInterval ein).
  const endeRef = useRef(Date.now() + PAUSE_SEKUNDEN * 1000);

  useEffect(() => {
    if (status !== "laeuft") return;
    const aktualisiere = () => {
      const rest = Math.max(0, Math.ceil((endeRef.current - Date.now()) / 1000));
      setRestzeit(rest);
      if (rest <= 0) setStatus("fertig");
    };
    const intervall = setInterval(aktualisiere, 1000);
    // Beim Entsperren/Zurückkehren sofort nachziehen statt auf den nächsten Tick zu warten:
    document.addEventListener("visibilitychange", aktualisiere);
    window.addEventListener("focus", aktualisiere);
    aktualisiere();
    return () => {
      clearInterval(intervall);
      document.removeEventListener("visibilitychange", aktualisiere);
      window.removeEventListener("focus", aktualisiere);
    };
  }, [status]);

  useEffect(() => {
    if (status === "fertig" && onFertig) onFertig();
  }, [status, onFertig]);

  const min = Math.floor(restzeit / 60);
  const sek = String(restzeit % 60).padStart(2, "0");
  const pct = ((PAUSE_SEKUNDEN - restzeit) / PAUSE_SEKUNDEN) * 100;

  if (status === "fertig") {
    return (
      <div className="timer-fertig pop">
        <span className="timer-fertig-emoji">🐴🎉</span>
        <span>Pause vorbei – Daisy ruft dich zurück auf den Pfad!</span>
      </div>
    );
  }

  return (
    <div className="timer">
      <div className="timer-zeit" aria-live="polite">
        {min}:{sek}
      </div>
      <div className="timer-track">
        <div className="timer-fill" style={{ width: `${pct}%` }} />
        <div className="timer-daisy weiss" style={{ left: `calc(${pct}% - 14px)` }}>🐴</div>
      </div>
      <p className="pause-hinweis">Wenn Daisy am Ziel ist, geht&rsquo;s weiter!</p>
    </div>
  );
}

/* ---------- Weideweg (Fortschritt in der Runde) ---------- */

function Weideweg({ step, total }) {
  const pct = (step / total) * 100;
  return (
    <div className="weide" aria-label={`Aufgabe ${step} von ${total}`}>
      <div className="weide-track">
        <div className="weide-fill" style={{ width: `${pct}%` }} />
        <div className="weide-bruno" style={{ left: `calc(${pct}% - 16px)` }}>🐶</div>
        <div className="weide-daisy weiss">🐴</div>
      </div>
      <div className="weide-paws">
        {Array.from({ length: total }).map((_, i) => (
          <span key={i} className={i < step ? "paw done" : "paw"}>🐾</span>
        ))}
      </div>
    </div>
  );
}

/* ---------- Gangart-Anzeige ---------- */

function GangartChip({ level }) {
  const g = GANGARTEN[level];
  return (
    <div className="gangart-chip" title="Daisys Tempo – passt sich automatisch an dich an">
      {GANGARTEN.map((x, i) => (
        <span key={x.name} className={`gang ${i === level ? "on" : ""} ${x.emoji === "🐴" ? "weiss" : ""}`}>{x.emoji}</span>
      ))}
      <span className="gang-name">{g.name}</span>
    </div>
  );
}

/* ---------- Haupt-App ---------- */

export default function HelenasLernWeide() {
  const [screen, setScreen] = useState("home");
  const [klasse, setKlasse] = useState("klasse3"); // wird später ein Profil-Setting
  const [station, setStation] = useState(null);
  const [task, setTask] = useState(null);
  const [taskNr, setTaskNr] = useState(0);
  const [phase, setPhase] = useState("frage");
  const [input, setInput] = useState("");
  const [stars, setStars] = useState(0);
  const [ai, setAi] = useState(null);
  const [aiLoading, setAiLoading] = useState(false);
  const [lob, setLob] = useState(LOB[0]);
  const [quercheckRichtig, setQuercheckRichtig] = useState(null);
  const [pause, setPause] = useState(PAUSEN[0]);
  const [pauseFertig, setPauseFertig] = useState(false); // Weiter erst nach der Bewegungspause
  const [rundenErgebnis, setRundenErgebnis] = useState(null); // { sterne, level, schleifeNeu }

  // Heutige Statistik für Daisys Tagesbericht 📸
  // (im Web-Prototyp pro Sitzung – in der Swift-Version aus SwiftData)
  const [heute, setHeute] = useState({ aufgaben: 0, sterne: 0, schleifen: 0 });
  const [berichtUrl, setBerichtUrl] = useState(null);
  const berichtCanvasRef = useRef(null);

  // Turnier-Fortschritt: welche Stationen haben schon eine Schleife 🎀?
  const [schleifen, setSchleifen] = useState(() => Object.fromEntries(ALLE_STATION_IDS.map((id) => [id, false])));

  // Gangart pro Station (bleibt in der Sitzung erhalten)
  const [levels, setLevels] = useState(() => Object.fromEntries(ALLE_STATION_IDS.map((id) => [id, 0])));
  const [level, setLevel] = useState(0);
  const [upStreak, setUpStreak] = useState(0);
  const [downStreak, setDownStreak] = useState(0);
  const [levelMsg, setLevelMsg] = useState(null);

  const timerRef = useRef(null);
  useEffect(() => () => clearTimeout(timerRef.current), []);

  const pfad = TURNIERPFADE.find((p) => p.id === klasse);

  /* Eine Station ist offen, wenn sie die erste ist oder die vorige
     eine Schleife hat. Geschaffte Stationen bleiben immer offen. */
  function stationStatus(p, idx) {
    const s = p.stationen[idx];
    if (schleifen[s.id]) return "geschafft";
    if (idx === 0 || schleifen[p.stationen[idx - 1].id]) return "offen";
    return "gesperrt";
  }

  /* Wiederholungsaufgabe aus einer zufälligen, bereits geschafften
     Station desselben Pfads – eine Gangart gemütlicher. */
  function wiederholungsAufgabe() {
    const geschafft = pfad.stationen.filter((s) => schleifen[s.id] && s.id !== station.id);
    if (geschafft.length === 0) return null;
    const quelle = pick(geschafft);
    const t = quelle.gen(Math.min(levels[quelle.id] ?? 0, 1));
    return { ...t, wiederholung: quelle.titel };
  }

  /* Aufgabe für Position nr erzeugen. Bei Misch-Stationen sind die
     Positionen 2 und 4 Wiederholungen (falls es Geschafftes gibt). */
  function erzeugeAufgabe(nr, lvl) {
    if (station.mix && (nr === 1 || nr === 3)) {
      const w = wiederholungsAufgabe();
      if (w) return w;
    }
    return station.gen(lvl);
  }

  function startRound(s) {
    const startLevel = levels[s.id] ?? 0;
    setStation(s);
    setLevel(startLevel);
    setUpStreak(0);
    setDownStreak(0);
    setLevelMsg(null);
    setTaskNr(0);
    setStars(0);
    setInput("");
    setPhase("frage");
    setAi(null);
    setRundenErgebnis(null);
    setPause(pick(PAUSEN));
    setScreen("round");
    // Erste Aufgabe (nr 0) kommt nie aus der Wiederholung:
    setTask(s.gen(startLevel));
  }

  function passeGangartAn(outcome) {
    let neuesLevel = level;
    let up = upStreak;
    let down = downStreak;
    let msg = null;

    if (outcome === "erstversuch") {
      up += 1; down = 0;
      if (up >= 2 && level < 2) {
        neuesLevel = level + 1; up = 0;
        msg = `Wow, du bist richtig schnell! Daisy wechselt in den ${GANGARTEN[neuesLevel].name}! ${GANGARTEN[neuesLevel].emoji}`;
      }
    } else if (outcome === "zweitversuch") {
      up = 0;
    } else {
      up = 0; down += 1;
      if (down >= 2 && level > 0) {
        neuesLevel = level - 1; down = 0;
        msg = `Wir machen es uns ein bisschen gemütlicher – ${GANGARTEN[neuesLevel].name}-Tempo. ${GANGARTEN[neuesLevel].emoji} Das ist super zum Üben!`;
      }
    }

    setLevel(neuesLevel);
    setUpStreak(up);
    setDownStreak(down);
    setLevelMsg(msg);
    setLevels((l) => ({ ...l, [station.id]: neuesLevel }));
    return neuesLevel;
  }

  function naechsteAufgabe(mitStern, outcome) {
    const finaleSterne = stars + (mitStern ? 1 : 0);
    if (mitStern) setStars((s) => s + 1);
    const neuesLevel = passeGangartAn(outcome);
    setInput("");
    setAi(null);
    setQuercheckRichtig(null);

    let schleifeNeu = false;
    if (taskNr + 1 >= ROUND_LENGTH) {
      // Runde fertig → Schleifen-Check 🎀
      const bestanden = finaleSterne >= SCHLEIFE_MIN_STERNE && neuesLevel >= SCHLEIFE_MIN_GANGART;
      schleifeNeu = bestanden && !schleifen[station.id];
      if (schleifeNeu) {
        setSchleifen((s) => ({ ...s, [station.id]: true }));
      }
      setRundenErgebnis({ sterne: finaleSterne, level: neuesLevel, schleifeNeu, hatSchleife: schleifen[station.id] || schleifeNeu });
      setPauseFertig(false); // Bewegungspause ist Pflicht – Buttons erst danach
      setScreen("done");
    } else {
      const nr = taskNr + 1;
      setTaskNr(nr);
      setTask(erzeugeAufgabe(nr, neuesLevel));
      setPhase("frage");
    }

    // Tages-Statistik für Daisys Bericht 📸
    setHeute((h) => ({
      aufgaben: h.aufgaben + 1,
      sterne: h.sterne + (mitStern ? 1 : 0),
      schleifen: h.schleifen + (schleifeNeu ? 1 : 0),
    }));
  }

  function istRichtig(eingabe) {
    if (task.typ === "rest") {
      return eingabe.q === task.antwort.q && eingabe.rest === task.antwort.rest;
    }
    return eingabe === task.antwort;
  }

  function eingabeText(eingabe) {
    if (task.typ === "rest") return `${eingabe.q}, Rest ${eingabe.rest}`;
    return String(eingabe);
  }

  function pruefeAntwort(eingabeRoh) {
    const eingabe = task.typ === "rest" ? eingabeRoh : parseInt(input, 10);
    if (istRichtig(eingabe)) {
      const outcome = phase === "frage" ? "erstversuch" : "zweitversuch";
      setLob(pick(LOB));
      setPhase("richtig");
      timerRef.current = setTimeout(() => naechsteAufgabe(true, outcome), 1600);
    } else if (phase === "frage") {
      setPhase("nochmal");
      setInput("");
    } else {
      setPhase("erklaerung");
      setAiLoading(true);
      holeErklaerung(task, eingabeText(eingabe))
        .then(setAi)
        .catch(() => setAi(fallbackErklaerung(task)))
        .finally(() => setAiLoading(false));
      setInput("");
    }
  }

  function pruefeQuercheck() {
    const zahl = parseInt(input, 10);
    setQuercheckRichtig(zahl === ai.quercheckAntwort);
    setPhase("quercheckErgebnis");
    setInput("");
  }

  /* Nächste offene (noch nicht geschaffte) Station im Pfad */
  const naechsteOffeneStation = pfad.stationen.find((s, i) => stationStatus(pfad, i) === "offen");

  /* ---------- Daisys Tagesbericht ---------- */

  function zeigeBericht() {
    const canvas = malTagesbericht(heute);
    berichtCanvasRef.current = canvas;
    setBerichtUrl(canvas.toDataURL("image/png"));
    setScreen("bericht");
  }

  function teileBericht() {
    const canvas = berichtCanvasRef.current;
    if (!canvas) return;
    canvas.toBlob(async (blob) => {
      const datei = new File([blob], "daisys-tagesbericht.png", { type: "image/png" });
      // Teilen-Menü des iPhones (iMessage, WhatsApp, Mail …)
      if (navigator.canShare && navigator.canShare({ files: [datei] })) {
        try {
          await navigator.share({ files: [datei], title: "Daisys Tagesbericht 🐴" });
          return;
        } catch { /* abgebrochen → nichts tun */ }
      } else {
        // Fallback (z. B. am Desktop): Bild herunterladen
        const a = document.createElement("a");
        a.href = canvas.toDataURL("image/png");
        a.download = "daisys-tagesbericht.png";
        a.click();
      }
    }, "image/png");
  }

  return (
    <div className="app">
      <style>{css}</style>

      {screen === "home" && (
        <div className="screen">
          <div className="hero">
            <div className="hero-friends">
              <span className="wiggle">🐶</span>
              <span className="wiggle delay weiss">🐴</span>
            </div>
            <h1>Hallo Helena!</h1>
            <p className="hero-sub">Dein Turnierpfad wartet – Station für Station zur nächsten Schleife! 🎀</p>
          </div>

          {/* Daisys Tagesbericht */}
          <button className="btn-bericht" onClick={zeigeBericht}>
            📸 Daisys Tagesbericht
            {heute.aufgaben > 0 && <span className="bericht-zaehler">{heute.aufgaben} Aufgaben heute</span>}
          </button>

          {/* Klassen-Schalter – wird später ins Profil wandern */}
          <div className="klassen-schalter" role="tablist" aria-label="Klasse wählen">
            {TURNIERPFADE.map((p) => (
              <button
                key={p.id}
                role="tab"
                aria-selected={klasse === p.id}
                className={klasse === p.id ? "klasse-btn on" : "klasse-btn"}
                onClick={() => setKlasse(p.id)}
              >
                {p.emoji} {p.titel}
              </button>
            ))}
          </div>

          {/* Turnierpfad */}
          <div className="pfad">
            {pfad.stationen.map((s, i) => {
              const status = stationStatus(pfad, i);
              const istAktuell = naechsteOffeneStation?.id === s.id;
              return (
                <div key={s.id} className="pfad-eintrag">
                  {i > 0 && <div className={status === "gesperrt" ? "pfad-linie" : "pfad-linie aktiv"}>🐾</div>}
                  <button
                    className={`station ${status} ${istAktuell ? "aktuell" : ""}`}
                    style={{ "--accent": s.farbe }}
                    disabled={status === "gesperrt"}
                    onClick={() => startRound(s)}
                  >
                    <span className="station-emoji">{s.emoji}</span>
                    <span className="station-text">
                      <span className="station-titel">{s.titel}</span>
                      <span className="station-sub">
                        {status === "geschafft" && "Freies Training – jederzeit üben!"}
                        {status === "offen" && s.sub}
                        {status === "gesperrt" && "Noch verschlossen"}
                      </span>
                    </span>
                    <span className="station-status">
                      {status === "geschafft" && "🎀"}
                      {status === "offen" && (istAktuell ? "▶️" : "")}
                      {status === "gesperrt" && "🔒"}
                    </span>
                  </button>
                </div>
              );
            })}
          </div>

          <p className="footnote">
            🎀 Schleife = mindestens {SCHLEIFE_MIN_STERNE} von {ROUND_LENGTH} Sternen im {GANGARTEN[SCHLEIFE_MIN_GANGART].name} oder schneller.
            <br />
            Geschaffte Stationen bleiben als Freies Training offen. 🐾
          </p>
        </div>
      )}

      {screen === "round" && task && (
        <div className="screen">
          <div className="round-top">
            <div className="round-bar">
              <button className="btn-back" onClick={() => setScreen("home")}>← Pfad</button>
              <GangartChip level={level} />
            </div>
            <Weideweg step={taskNr} total={ROUND_LENGTH} />
          </div>

          <div className="card">
            <div className="thema-chip" style={{ background: station.farbe }}>
              {station.emoji} {station.titel}
            </div>

            {task.wiederholung && (phase === "frage" || phase === "nochmal") && (
              <div className="wdh-chip">🔁 Wiederholung: {task.wiederholung}</div>
            )}

            {levelMsg && (phase === "frage" || phase === "nochmal") && (
              <div className="level-banner">{levelMsg}</div>
            )}

            {(phase === "frage" || phase === "nochmal") && (
              <>
                <p className={task.frage.length > 40 ? "frage frage-klein" : "frage"}>{task.frage}</p>
                {phase === "nochmal" && (
                  <div className="hint">
                    <span>🐶</span> Fast! Probier's noch einmal. Tipp: {task.hinweis}
                  </div>
                )}
                {task.typ === "rest" ? (
                  <RestPad onSubmit={(e) => pruefeAntwort(e)} />
                ) : (
                  <NumPad value={input} onChange={setInput} onSubmit={() => pruefeAntwort()} />
                )}
              </>
            )}

            {phase === "richtig" && (
              <div className="feedback-ok">
                <div className="big-emoji pop">🌟</div>
                <p className="lob">{lob}</p>
              </div>
            )}

            {phase === "erklaerung" && (
              <div className="erklaerung">
                <div className="bruno-bubble">
                  <span className="bruno-face">🐶</span>
                  {aiLoading ? (
                    <p className="denkt">Bruno überlegt, wie er dir das am besten erklärt<span className="dots">…</span></p>
                  ) : (
                    <p>{ai?.erklaerung}</p>
                  )}
                </div>
                {!aiLoading && ai?.quercheckFrage && (
                  <button className="btn-primary" onClick={() => setPhase("quercheck")}>
                    Verstanden – ich probier's! 💪
                  </button>
                )}
                {!aiLoading && !ai?.quercheckFrage && (
                  <>
                    <p className="aufloesung">
                      Die richtige Antwort war <strong>{task.antwortText}</strong>.
                    </p>
                    <button className="btn-primary" onClick={() => naechsteAufgabe(false, "erklaert")}>
                      Weiter 🐾
                    </button>
                  </>
                )}
              </div>
            )}

            {phase === "quercheck" && ai && (
              <>
                <div className="quercheck-chip">Quercheck 🔎</div>
                <p className="frage frage-klein">{ai.quercheckFrage}</p>
                <NumPad value={input} onChange={setInput} onSubmit={pruefeQuercheck} />
              </>
            )}

            {phase === "quercheckErgebnis" && ai && (
              <div className="feedback-ok">
                {quercheckRichtig ? (
                  <>
                    <div className="big-emoji pop">🎉</div>
                    <p className="lob">Jetzt hast du's! Daisy ist stolz auf dich! 🐴</p>
                  </>
                ) : (
                  <>
                    <div className="big-emoji weiss">🐴</div>
                    <p className="lob lob-sanft">
                      Knapp daneben – die Antwort war <strong>{fmt(ai.quercheckAntwort)}</strong>. Das üben wir einfach nochmal, kein Stress!
                    </p>
                  </>
                )}
                <p className="aufloesung">
                  Und die erste Aufgabe? {task.frage} → <strong>{task.antwortText}</strong>
                </p>
                <button
                  className="btn-primary"
                  onClick={() => naechsteAufgabe(quercheckRichtig, quercheckRichtig ? "zweitversuch" : "erklaert")}
                >
                  Weiter 🐾
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {screen === "done" && rundenErgebnis && (
        <div className="screen">
          <div className="card done-card">
            {rundenErgebnis.schleifeNeu ? (
              <>
                <div className="big-emoji pop">🎀</div>
                <h2>Schleife gewonnen!</h2>
                <p className="done-text">
                  „{station.titel}“ ist geschafft, Helena!
                  {naechsteOffeneStation && naechsteOffeneStation.id !== station.id
                    ? " Die nächste Station ist jetzt offen!"
                    : ""}
                </p>
              </>
            ) : (
              <>
                <div className="big-emoji pop">🏆</div>
                <h2>Runde geschafft!</h2>
                {!rundenErgebnis.hatSchleife && (
                  <p className="done-text">
                    Starke Trainingsrunde! Für die Schleife 🎀 brauchst du{" "}
                    {SCHLEIFE_MIN_STERNE} Sterne im {GANGARTEN[SCHLEIFE_MIN_GANGART].name} – du schaffst das!
                  </p>
                )}
              </>
            )}

            <div className="stars" aria-label={`${rundenErgebnis.sterne} von ${ROUND_LENGTH} Sternen`}>
              {Array.from({ length: ROUND_LENGTH }).map((_, i) => (
                <span key={i} className={i < rundenErgebnis.sterne ? "star on" : "star"}>★</span>
              ))}
            </div>
            <p className="done-gangart">
              Daisys Tempo: {GANGARTEN[rundenErgebnis.level].emoji} <strong>{GANGARTEN[rundenErgebnis.level].name}</strong>
            </p>
            <div className="pause-box">
              <p className="pause-titel">Bewegungspause! 🤸</p>
              <p>{pause}</p>
              <PausenTimer onFertig={() => setPauseFertig(true)} />
            </div>
            {pauseFertig && (
              <div className="done-buttons">
                {rundenErgebnis.schleifeNeu && naechsteOffeneStation && naechsteOffeneStation.id !== station.id ? (
                  <button className="btn-primary" onClick={() => startRound(naechsteOffeneStation)}>
                    Nächste Station {naechsteOffeneStation.emoji}
                  </button>
                ) : (
                  <button className="btn-primary" onClick={() => startRound(station)}>
                    Nochmal {station.emoji}
                  </button>
                )}
                <button className="btn-secondary" onClick={() => setScreen("home")}>
                  Zum Pfad <span className="weiss">🐴</span>
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {screen === "bericht" && berichtUrl && (
        <div className="screen">
          <div className="card bericht-card">
            <h2 className="bericht-titel">Daisys Tagesbericht 📸</h2>
            <img src={berichtUrl} alt="Daisys Tagesbericht mit Helenas heutigem Fortschritt" className="bericht-bild" />
            <div className="done-buttons">
              <button className="btn-primary" onClick={teileBericht}>
                💌 Per Nachricht teilen
              </button>
              <button className="btn-secondary" onClick={() => setScreen("home")}>
                Zurück <span className="weiss">🐴</span>
              </button>
            </div>
            <p className="bericht-hinweis">
              Datum und Uhrzeit sind fix im Bild – so sieht jeder, wann Daisy es gemacht hat. 😉
            </p>
          </div>
        </div>
      )}
    </div>
  );
}

/* ---------- Styles ---------- */

const css = `
@import url('https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;800&family=Nunito:wght@600;800&display=swap');

.app {
  min-height: 100vh;
  background: linear-gradient(180deg, ${PALETTE.sky} 0%, #E8F6EC 55%, #D6EFC9 100%);
  font-family: 'Nunito', 'Segoe UI Rounded', system-ui, sans-serif;
  color: ${PALETTE.ink};
  display: flex; justify-content: center;
  padding: 16px;
}
.screen { width: 100%; max-width: 460px; display: flex; flex-direction: column; gap: 16px; }

.hero { text-align: center; margin-top: 8px; }
.hero-friends { font-size: 56px; }
.wiggle { display: inline-block; animation: wiggle 2.4s ease-in-out infinite; }
.wiggle.delay { animation-delay: 1.2s; }
@keyframes wiggle { 0%,100% { transform: rotate(-6deg); } 50% { transform: rotate(6deg); } }
.hero h1 { font-family: 'Baloo 2', cursive; font-size: 34px; margin: 4px 0 2px; }
.hero-sub { color: ${PALETTE.soft}; font-weight: 600; margin: 0; }

/* --- Daisy ist ein Schimmel! Filter macht das Pferde-Emoji weiß --- */
.weiss {
  filter: grayscale(1) brightness(1.85) drop-shadow(0 0 1px rgba(51,41,31,.4));
}

/* --- Daisys Tagesbericht --- */
.btn-bericht {
  display: flex; align-items: center; justify-content: center; gap: 10px;
  background: ${PALETTE.cream};
  border: 3px dashed ${PALETTE.brown};
  border-radius: 20px;
  padding: 12px 16px;
  font-family: 'Baloo 2', cursive; font-size: 18px;
  color: ${PALETTE.ink}; cursor: pointer;
}
.btn-bericht:active { transform: scale(.98); }
.bericht-zaehler {
  background: ${PALETTE.sun}; border-radius: 999px;
  font-size: 12px; font-weight: 800; padding: 3px 10px;
  font-family: 'Nunito', sans-serif;
}
.bericht-card { text-align: center; align-items: center; }
.bericht-titel { font-family: 'Baloo 2', cursive; margin: 0; font-size: 24px; }
.bericht-bild {
  width: 100%; border-radius: 20px;
  box-shadow: 0 6px 16px rgba(51,41,31,0.25);
}
.bericht-hinweis { font-size: 12px; font-weight: 700; color: ${PALETTE.soft}; margin: 0; }

/* --- Klassen-Schalter (später Profil-Setting) --- */
.klassen-schalter {
  display: flex; gap: 8px;
  background: #EFE7D6;
  border-radius: 999px;
  padding: 6px;
}
.klasse-btn {
  flex: 1;
  border: 3px solid transparent;
  background: transparent;
  border-radius: 999px;
  padding: 10px 8px;
  font-family: 'Baloo 2', cursive;
  font-size: 16px;
  color: ${PALETTE.soft};
  cursor: pointer;
  transition: transform .12s ease;
}
.klasse-btn.on {
  background: ${PALETTE.cream};
  border-color: ${PALETTE.brown};
  color: ${PALETTE.ink};
  box-shadow: 0 3px 0 rgba(51,41,31,0.12);
}
.klasse-btn:active { transform: scale(.97); }

/* --- Turnierpfad --- */
.pfad { display: flex; flex-direction: column; }
.pfad-eintrag { display: flex; flex-direction: column; }
.pfad-linie {
  align-self: center;
  padding: 2px 0;
  font-size: 14px;
  opacity: .25;
  transform: rotate(90deg);
}
.pfad-linie.aktiv { opacity: .8; }

.station {
  display: flex; align-items: center; gap: 12px;
  background: ${PALETTE.cream};
  border: 4px solid var(--accent);
  border-radius: 20px;
  padding: 12px 14px;
  cursor: pointer; font-family: inherit; text-align: left;
  box-shadow: 0 4px 0 rgba(51,41,31,0.12);
  transition: transform .12s ease;
}
.station:active:not(:disabled) { transform: scale(.98); }
.station.gesperrt {
  background: #EFE9DD;
  border-color: #D8CFBE;
  box-shadow: none;
  cursor: default;
  opacity: .75;
}
.station.geschafft { border-style: solid; }
.station.aktuell {
  outline: 4px solid ${PALETTE.sun};
  outline-offset: 3px;
  animation: pulsieren 2.2s ease-in-out infinite;
}
@keyframes pulsieren {
  0%, 100% { outline-color: ${PALETTE.sun}; }
  50% { outline-color: #FFE9A0; }
}
.station-emoji { font-size: 32px; }
.station-text { flex: 1; display: flex; flex-direction: column; gap: 1px; }
.station-titel { font-family: 'Baloo 2', cursive; font-size: 16px; line-height: 1.2; }
.station-sub { font-size: 12px; color: ${PALETTE.soft}; font-weight: 700; }
.station-status { font-size: 24px; min-width: 30px; text-align: center; }

.footnote { text-align: center; font-size: 13px; color: ${PALETTE.soft}; font-weight: 600; line-height: 1.6; }

.round-top { display: flex; flex-direction: column; gap: 8px; }
.round-bar { display: flex; justify-content: space-between; align-items: center; }
.btn-back {
  background: ${PALETTE.cream}; border: 2px solid ${PALETTE.soft};
  border-radius: 999px; padding: 6px 14px; font-family: inherit; font-weight: 800; cursor: pointer;
}

.gangart-chip {
  display: flex; align-items: center; gap: 4px;
  background: ${PALETTE.cream}; border: 2px solid ${PALETTE.sun};
  border-radius: 999px; padding: 4px 12px; font-weight: 800; font-size: 13px;
}
.gang { opacity: .25; font-size: 16px; }
.gang.on { opacity: 1; font-size: 18px; }
.gang-name { margin-left: 2px; }

.weide-track {
  position: relative; height: 34px; background: #EFE7D6;
  border-radius: 999px; overflow: visible;
}
.weide-fill {
  position: absolute; inset: 0 auto 0 0; background: ${PALETTE.grass};
  border-radius: 999px; transition: width .5s ease;
}
.weide-bruno { position: absolute; top: -4px; font-size: 30px; transition: left .5s ease; }
.weide-daisy { position: absolute; right: 2px; top: -4px; font-size: 30px; }
.weide-paws { display: flex; justify-content: space-between; padding: 4px 8px 0; }
.paw { opacity: .25; font-size: 14px; }
.paw.done { opacity: 1; }

.card {
  background: ${PALETTE.cream};
  border-radius: 28px;
  padding: 20px;
  box-shadow: 0 6px 0 rgba(51,41,31,0.12);
  display: flex; flex-direction: column; gap: 14px;
}
.thema-chip {
  align-self: center; color: #fff; font-weight: 800; font-size: 13px;
  padding: 4px 14px; border-radius: 999px; text-shadow: 0 1px 2px rgba(0,0,0,.15);
}
.wdh-chip {
  align-self: center; background: #E7F0FA; border: 2px solid ${PALETTE.blue};
  font-weight: 800; font-size: 12px; padding: 3px 12px; border-radius: 999px;
}
.quercheck-chip {
  align-self: center; background: ${PALETTE.sun}; font-weight: 800; font-size: 13px;
  padding: 4px 14px; border-radius: 999px;
}
.level-banner {
  background: #FFF6D6; border: 2px solid ${PALETTE.sun}; border-radius: 16px;
  padding: 10px 14px; font-weight: 800; font-size: 14px; text-align: center;
}
.frage {
  font-family: 'Baloo 2', cursive; font-size: 30px; text-align: center; margin: 4px 0; line-height: 1.3;
}
.frage-klein { font-size: 22px; }

.hint {
  background: #FFF1DC; border: 2px dashed ${PALETTE.coral}; border-radius: 16px;
  padding: 10px 14px; font-weight: 700; display: flex; gap: 8px; align-items: flex-start; font-size: 15px;
}

.numpad { display: flex; flex-direction: column; gap: 10px; }
.numpad-display {
  background: #fff; border: 3px solid ${PALETTE.grass}; border-radius: 16px;
  min-height: 54px; display: flex; align-items: center; justify-content: center;
  font-family: 'Baloo 2', cursive; font-size: 30px;
}
.numpad-placeholder { color: #C9BFB2; font-size: 18px; font-family: 'Nunito', sans-serif; font-weight: 700; }
.numpad-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
.numpad-key {
  font-family: 'Baloo 2', cursive; font-size: 24px; padding: 12px 0;
  background: #fff; border: 3px solid #E4DBC9; border-radius: 16px; cursor: pointer;
  box-shadow: 0 3px 0 rgba(51,41,31,0.10); color: ${PALETTE.ink};
}
.numpad-key:active { transform: translateY(2px); box-shadow: none; }
.numpad-del { background: #FBE9E1; border-color: ${PALETTE.coral}; }
.numpad-ok { background: ${PALETTE.grass}; border-color: ${PALETTE.grassDark}; color: #fff; }
.numpad-key:disabled { opacity: .5; cursor: default; }

.rest-row { display: flex; gap: 10px; }
.rest-feld {
  flex: 1; background: #fff; border: 3px solid #E4DBC9; border-radius: 16px;
  padding: 8px; display: flex; flex-direction: column; align-items: center; gap: 2px;
  cursor: pointer; font-family: inherit;
}
.rest-feld.on { border-color: ${PALETTE.grass}; background: #F4FAEF; }
.rest-label { font-size: 12px; font-weight: 800; color: ${PALETTE.soft}; }
.rest-wert { font-family: 'Baloo 2', cursive; font-size: 26px; min-height: 32px; }
.rest-tipp { text-align: center; font-size: 12px; font-weight: 700; color: ${PALETTE.soft}; margin: 0; }

.feedback-ok { text-align: center; display: flex; flex-direction: column; gap: 8px; align-items: center; }
.big-emoji { font-size: 64px; }
.pop { animation: pop .5s ease; }
@keyframes pop { 0% { transform: scale(.3); } 70% { transform: scale(1.15); } 100% { transform: scale(1); } }
.lob { font-family: 'Baloo 2', cursive; font-size: 22px; margin: 0; }
.lob-sanft { font-size: 18px; }
.aufloesung { font-weight: 700; color: ${PALETTE.soft}; margin: 0; }

.erklaerung { display: flex; flex-direction: column; gap: 12px; }
.bruno-bubble {
  background: #fff; border: 3px solid ${PALETTE.coral}; border-radius: 20px;
  padding: 14px; display: flex; gap: 10px; align-items: flex-start;
  font-weight: 700; font-size: 17px; line-height: 1.45;
}
.bruno-face { font-size: 32px; }
.denkt { margin: 0; color: ${PALETTE.soft}; }
.dots::after { content: ''; animation: dots 1.4s steps(4) infinite; }
@keyframes dots { 0% { content: ''; } 25% { content: '.'; } 50% { content: '..'; } 75% { content: '...'; } }

.btn-primary {
  background: ${PALETTE.grass}; color: #fff; border: none; border-radius: 999px;
  font-family: 'Baloo 2', cursive; font-size: 20px; padding: 12px 20px; cursor: pointer;
  box-shadow: 0 4px 0 ${PALETTE.grassDark};
}
.btn-primary:active { transform: translateY(3px); box-shadow: none; }
.btn-secondary {
  background: ${PALETTE.cream}; border: 3px solid ${PALETTE.grass}; color: ${PALETTE.grassDark};
  border-radius: 999px; font-family: 'Baloo 2', cursive; font-size: 20px; padding: 10px 20px; cursor: pointer;
}

.done-card { text-align: center; align-items: center; }
.done-card h2 { font-family: 'Baloo 2', cursive; margin: 0; font-size: 28px; }
.done-text { font-weight: 700; margin: 0; }
.stars { font-size: 40px; letter-spacing: 6px; }
.star { color: #E2D8C6; }
.star.on { color: ${PALETTE.sun}; text-shadow: 0 2px 0 rgba(0,0,0,.08); }
.done-gangart { font-weight: 700; margin: 0; }
.pause-box {
  background: #FFF1DC; border-radius: 20px; padding: 14px 16px; font-weight: 700; width: 100%;
}
.pause-titel { font-family: 'Baloo 2', cursive; font-size: 20px; margin: 0 0 4px; }

/* --- Pausen-Timer --- */
.timer { display: flex; flex-direction: column; gap: 8px; align-items: center; margin-top: 10px; }
.pause-hinweis { font-size: 13px; color: ${PALETTE.soft}; margin: 0; }
.timer-zeit {
  font-family: 'Baloo 2', cursive; font-size: 44px; line-height: 1;
  font-variant-numeric: tabular-nums;
}
.timer-track {
  position: relative; width: 100%; height: 26px;
  background: #fff; border-radius: 999px; overflow: visible;
}
.timer-fill {
  position: absolute; inset: 0 auto 0 0; background: ${PALETTE.sun};
  border-radius: 999px; transition: width 1s linear;
}
.timer-daisy { position: absolute; top: -3px; font-size: 26px; transition: left 1s linear; }
.timer-fertig {
  margin-top: 10px; display: flex; flex-direction: column; align-items: center; gap: 4px;
  font-family: 'Baloo 2', cursive; font-size: 17px; text-align: center;
}
.timer-fertig-emoji { font-size: 36px; }
.done-buttons { display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; }

@media (prefers-reduced-motion: reduce) {
  .wiggle, .pop, .dots::after, .station.aktuell { animation: none; }
  .weide-fill, .weide-bruno { transition: none; }
}
`;
