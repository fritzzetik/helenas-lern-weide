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

// Rundenlänge hängt vom Pfad ab: 1./2. Klasse üben 5 Aufgaben, 3./4. Klasse 10.
// Schleifen-Hürde ist immer 80 % der Sterne (4 von 5 bzw. 8 von 10) …
const SCHLEIFEN_QUOTE = 0.8;
const SCHLEIFE_MIN_GANGART = 1;  // … in Trab oder Galopp
const schleifeMinSterne = (rundenLaenge) => Math.round(rundenLaenge * SCHLEIFEN_QUOTE);

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

/* ============================================================
   Generatoren 1. Klasse (Zahlenraum 20)
   ============================================================ */

function genZaehlen(level) {
  if (level === 0) { const n = rand(1, 9); return mach(`Welche Zahl kommt direkt nach ${n}?`, n + 1, "Zählen bis 10", `Zähl einfach laut weiter: ${n}, …`); }
  if (level === 1) { const n = rand(2, 15); return mach(`Welche Zahl kommt direkt vor ${n}?`, n - 1, "Zählen bis 20", "Zähl einen Schritt zurück."); }
  const n = rand(1, 17); return mach(`Zähle weiter: ${n}, ${n + 1}, ?`, n + 2, "Weiterzählen bis 20", "Immer eins dazu.");
}

function genZerlegen(level) {
  if (level === 0) { const ziel = rand(4, 6); const a = rand(1, ziel - 1); return mach(`${a} + ? = ${ziel}`, ziel - a, "Ergänzen bis 6", `Zähl von ${a} hinauf bis ${ziel} – wie viele Schritte?`); }
  if (level === 1) { const a = rand(1, 9); return mach(`${a} + ? = 10`, 10 - a, "Ergänzen auf 10", `Die Zehnerfreunde! ${a} und ${10 - a} gehören zusammen.`); }
  const a = rand(11, 19); return mach(`${a} + ? = 20`, 20 - a, "Ergänzen auf 20", "Schau auf die Einer: Wie viel fehlt auf den vollen Zwanziger?");
}

function genPlusMinus10(level) {
  if (level === 0) { const a = rand(1, 5); const b = rand(1, 6 - a); return mach(`${a} + ${b} = ?`, a + b, "Plus bis 6", `Zähl von ${a} einfach ${b} weiter.`); }
  if (level === 1) {
    if (Math.random() < 0.5) { const a = rand(2, 9); const b = rand(1, 10 - a); return mach(`${a} + ${b} = ?`, a + b, "Plus bis 10", "Zähl von der größeren Zahl weiter."); }
    const a = rand(3, 10); const b = rand(1, a - 1); return mach(`${a} − ${b} = ?`, a - b, "Minus bis 10", `Zähl von ${a} rückwärts.`);
  }
  const a = rand(1, 4); const b = rand(1, 3); const c = rand(1, 10 - a - b);
  return mach(`${a} + ${b} + ${c} = ?`, a + b + c, "Plus mit drei Zahlen", `Rechne zuerst ${a} + ${b}, dann kommt ${c} dazu.`);
}

function genZahlenraum20(level) {
  if (level === 0) { const e = rand(1, 9); return mach(`10 + ${e} = ?`, 10 + e, "Zehner und Einer", `Ein voller Zehner und ${e} Einer.`); }
  if (level === 1) { const e = rand(1, 9); return mach(`1 Z + ${e} E = ?`, 10 + e, "Zehner und Einer", "Z ist der Zehner, E sind die Einer."); }
  const n = 10 + rand(1, 9); return mach(`Wie viele Einer hat die Zahl ${n}?`, n - 10, "Stellenwert bis 20", "Der Zehner ist voll – was bleibt übrig?");
}

function genPlusMinus20(level) {
  if (level === 0) { const a = 10 + rand(1, 5); const b = rand(1, 20 - a); return mach(`${a} + ${b} = ?`, a + b, "Plus bis 20 ohne Übergang", "Nur die Einer ändern sich."); }
  if (level === 1) { const a = 10 + rand(3, 9); const b = rand(1, a - 11); return mach(`${a} − ${b} = ?`, a - b, "Minus bis 20 ohne Übergang", "Nur die Einer ändern sich."); }
  if (Math.random() < 0.5) { const a = rand(5, 9); const b = rand(11 - a, 9); return mach(`${a} + ${b} = ?`, a + b, "Plus mit Zehnerübergang", "Rechne zuerst bis 10, dann den Rest dazu."); }
  const a = rand(11, 18); const b = rand(a - 9, 9); return mach(`${a} − ${b} = ?`, a - b, "Minus mit Zehnerübergang", "Zieh zuerst bis zum Zehner ab, dann den Rest.");
}

function genSach1(level) {
  if (level === 0) { const a = rand(2, 5); const b = rand(1, 4); return mach(`Bruno hat ${a} Knochen und bekommt ${b} dazu. Wie viele hat er jetzt?`, a + b, "Sachaufgabe: dazubekommen", `„Dazu" heißt Plus: ${a} + ${b}.`); }
  if (level === 1) { const b = rand(5, 10); const a = rand(1, b - 1); return mach(`Daisy hat ${b} Äpfel und frisst ${a} davon. Wie viele bleiben übrig?`, b - a, "Sachaufgabe: wegnehmen", `„Übrig bleiben" heißt Minus: ${b} − ${a}.`); }
  const a = rand(5, 9); const b = rand(3, 8); const c = rand(1, Math.min(a + b - 1, 9));
  return mach(`Auf der Weide stehen ${a} Hühner und ${b} Gänse. ${c} laufen weg. Wie viele Tiere bleiben?`, a + b - c, "Sachaufgabe mit zwei Schritten", `Zuerst alle zusammenzählen (${a} + ${b}), dann ${c} wegnehmen.`);
}

/* ============================================================
   Generatoren 2. Klasse (Zahlenraum 100, kleines Einmaleins)
   ============================================================ */

function genZahlenraum100(level) {
  if (level === 0) { const z = rand(2, 9); const e = rand(1, 9); return mach(`${z} Z + ${e} E = ?`, z * 10 + e, "Zehner und Einer", "Z sind Zehner, E sind Einer – einfach nebeneinander."); }
  if (level === 1) { let n = rand(21, 89); if (n % 10 === 0) n += rand(1, 9); return mach(`Welcher Zehner kommt direkt nach ${n}?`, Math.ceil(n / 10) * 10, "Nachbarzehner finden", "Der nächste Zehner ist die nächste runde Zahl."); }
  const n = rand(15, 85);
  if (Math.random() < 0.5) return mach(`${n} + 10 = ?`, n + 10, "Zehnersprünge", "Nur der Zehner ändert sich.");
  return mach(`${n} − 10 = ?`, n - 10, "Zehnersprünge", "Nur der Zehner ändert sich.");
}

function genPlusMinusOhne(level) {
  if (level === 0) { const a = rand(2, 7) * 10; const b = rand(1, 9 - a / 10) * 10; return mach(`${a} + ${b} = ?`, a + b, "Glatte Zehner", "Rechne mit den Zehnern – die Null bleibt."); }
  if (level === 1) {
    const az = rand(2, 6); const ae = rand(1, 5); const bz = rand(1, 8 - az); const be = rand(1, 9 - ae);
    const a = az * 10 + ae; const b = bz * 10 + be;
    return mach(`${a} + ${b} = ?`, a + b, "Plus ohne Übertrag", "Zehner zu Zehnern, Einer zu Einern.");
  }
  const az = rand(4, 9); const ae = rand(5, 9); const bz = rand(1, az - 1); const be = rand(1, ae - 1);
  const a = az * 10 + ae; const b = bz * 10 + be;
  return mach(`${a} − ${b} = ?`, a - b, "Minus ohne Übertrag", "Zehner minus Zehner, Einer minus Einer.");
}

function genPlusMinusMit(level) {
  if (level === 0) { const a = rand(15, 45); const b = rand(6, 9); return mach(`${a} + ${b} = ?`, a + b, "Plus über den Zehner", "Rechne zuerst bis zum nächsten Zehner, dann den Rest."); }
  if (level === 1) {
    const ae = rand(1, 4); const be = rand(ae + 1, 9);
    const a = rand(3, 8) * 10 + ae; const b = rand(1, Math.floor(a / 10) - 1) * 10 + be;
    return mach(`${a} − ${b} = ?`, a - b, "Minus über den Zehner", "Zieh zuerst bis zum Zehner ab, dann den Rest.");
  }
  let b = rand(25, 85); if (b % 10 === 0) b += 3;
  return mach(`${b} + ? = 100`, 100 - b, "Ergänzen auf 100", "Zuerst zum nächsten Zehner, dann die Zehner bis 100.");
}

function genKleineMalreihen(level) {
  // Lehrplan 2. Klasse: das GANZE kleine Einmaleins – schwere Reihen im Galopp.
  const reihe = level === 0 ? pick([2, 10]) : level === 1 ? pick([5, 3, 4]) : pick([6, 7, 8, 9]);
  const b = rand(1, 10);
  return mach(`${reihe} · ${b} = ?`, reihe * b, `Malreihe von ${reihe}`, `Denk an die ${reihe}er-Reihe: immer ${reihe} dazu.`);
}

function genErsteIn(level) {
  const teiler = level === 0 ? pick([2, 10]) : level === 1 ? pick([5, 3, 4]) : pick([6, 7, 8, 9]);
  const ergebnis = rand(1, 10); const zahl = teiler * ergebnis;
  return mach(`${teiler} in ${zahl} = ?`, ergebnis, "In-Rechnungen", `Wie oft passt ${teiler} in ${zahl}? Denk an die ${teiler}er-Reihe.`);
}

/* ---------- Lehrplan-Ergänzungen (Audit 13.07.2026) ---------- */

/* 1. Klasse: Verdoppeln & Halbieren im ZR 20 */
function genVerdoppeln20(level) {
  if (level === 0) { const a = rand(1, 5); return mach(`Verdopple ${a}!`, a * 2, "Verdoppeln bis 10", `Verdoppeln heißt: ${a} + ${a}.`); }
  if (level === 1) { const a = rand(6, 10); return mach(`Verdopple ${a}!`, a * 2, "Verdoppeln bis 20", `Verdoppeln heißt: ${a} + ${a}.`); }
  const a = rand(1, 10) * 2; return mach(`Die Hälfte von ${a} = ?`, a / 2, "Halbieren bis 20", `Teile ${a} in zwei gleich große Teile.`);
}

/* 1. Klasse: Mit Euro zahlen bis 20 € */
function genGeld20(level) {
  if (level === 0) { const a = rand(1, 5); const b = rand(1, 10 - a); return mach(`${a} € + ${b} € = ? €`, a + b, "Mit Euro rechnen", "Rechne wie mit Zahlen – nur mit € dahinter."); }
  if (level === 1) { const a = rand(5, 20); const b = rand(1, a - 1); return mach(`Du hast ${a} € und kaufst etwas um ${b} €. Wie viele € bleiben?`, a - b, "Einkaufen mit Euro", `Ausgeben heißt Minus: ${a} − ${b}.`); }
  const preis = rand(2, 9); return mach(`Das Spielzeug kostet ${preis} €. Du zahlst mit 10 €. Wie viele € bekommst du zurück?`, 10 - preis, "Rückgeld", `Rückgeld heißt Minus: 10 − ${preis}.`);
}

/* 2. Klasse: Uhr & Zeit */
function genUhrZeit(level) {
  if (level === 0) {
    return pick([
      () => mach("1 Stunde = ? Minuten", 60, "Zeit-Maße", "Der große Zeiger braucht 60 Minuten für eine Runde."),
      () => mach("1 Tag = ? Stunden", 24, "Zeit-Maße", "Ein ganzer Tag mit Tag und Nacht hat 24 Stunden."),
      () => mach("1 Woche = ? Tage", 7, "Zeit-Maße", "Montag bis Sonntag – zähl nach!"),
      () => mach("1 Minute = ? Sekunden", 60, "Zeit-Maße", "Eine Minute hat 60 Sekunden."),
    ])();
  }
  if (level === 1) {
    return pick([
      () => mach("Eine halbe Stunde = ? Minuten", 30, "Halbe und Viertelstunden", "Die Hälfte von 60."),
      () => mach("Eine Viertelstunde = ? Minuten", 15, "Halbe und Viertelstunden", "60 geteilt in 4 Teile."),
      () => mach("Eine Dreiviertelstunde = ? Minuten", 45, "Halbe und Viertelstunden", "Drei mal eine Viertelstunde: 15 + 15 + 15."),
    ])();
  }
  if (Math.random() < 0.5) {
    const von = rand(1, 9); const bis = rand(von + 1, Math.min(von + 5, 12));
    return mach(`Von ${von} Uhr bis ${bis} Uhr sind es ? Stunden`, bis - von, "Zeitspannen", `Zähl die vollen Stunden von ${von} bis ${bis}.`);
  }
  const a = rand(1, 5) * 5; const b = rand(1, 5) * 5;
  return mach(`${a} Minuten + ${b} Minuten = ? Minuten`, a + b, "Mit Minuten rechnen", "Rechne wie mit Zahlen – nur mit Minuten.");
}

/* 3. Klasse: Hälfte & Viertel (Brüche anbahnen) */
function genHaelfteViertel(level) {
  if (level === 0) { const a = rand(6, 50) * 2; return mach(`Die Hälfte von ${a} = ?`, a / 2, "Halbieren", `Teile ${a} in zwei gleich große Teile.`); }
  if (level === 1) { const a = rand(3, 25) * 4; return mach(`Ein Viertel von ${a} = ?`, a / 4, "Vierteln", `Halbiere ${a} – und halbiere dann noch einmal.`); }
  if (Math.random() < 0.5) { const a = rand(11, 49) * 20; return mach(`Die Hälfte von ${a} = ?`, a / 2, "Halbieren im Zahlenraum 1000", "Halbiere zuerst die Hunderter, dann die Zehner."); }
  const a = rand(2, 12) * 80; return mach(`Ein Viertel von ${a} = ?`, a / 4, "Vierteln im Zahlenraum 1000", "Zweimal halbieren – das ist ein Viertel.");
}

/* 4. Klasse: Bis zur Million */
function genMillion(level) {
  if (level === 0) {
    const ht = rand(1, 9); const zt = rand(1, 9); const t = rand(1, 9);
    return mach(`${fmt(ht * 100000)} + ${fmt(zt * 10000)} + ${fmt(t * 1000)} = ?`, ht * 100000 + zt * 10000 + t * 1000, "Große Zahlen zusammensetzen", "Hunderttausender, Zehntausender und Tausender einfach nebeneinander.");
  }
  if (level === 1) { const t = rand(12, 98) * 10; return mach(`Wie viele Tausender stecken in ${fmt(t * 1000)}?`, t, "Stellenwert verstehen", "Streich die letzten drei Nullen weg."); }
  if (Math.random() < 0.5) {
    const n = rand(12, 89) * 10000 + rand(1, 9) * 1000;
    return mach(`${fmt(n)} + 10.000 = ?`, n + 10000, "Zehntausendersprünge", "Nur die Zehntausender-Stelle ändert sich.");
  }
  return mach("999.999 + 1 = ?", 1000000, "Die Million!", "Alle Stellen kippen um – wie ein Kilometerzähler.");
}

/* 4. Klasse: Schriftliche Division (Rest darf hier auch 0 sein) */
function genSchriftlichDiv(level) {
  let teiler, q;
  if (level === 0) { teiler = pick([2, 3, 4, 5]); q = rand(21, 99); }
  else if (level === 1) { teiler = rand(3, 9); q = rand(51, 199); }
  else { teiler = rand(3, 9); q = rand(201, 999); }
  const rest = rand(0, teiler - 1);
  const dividend = teiler * q + rest;
  return {
    typ: "rest",
    frage: `${fmt(dividend)} : ${teiler} = ?  Rest ?`,
    antwort: { q, rest },
    antwortText: `${fmt(q)}, Rest ${rest}`,
    thema: "Schriftliche Division",
    hinweis: `Teile Stelle für Stelle durch ${teiler} – von links nach rechts. Was am Schluss übrig bleibt, ist der Rest.`,
  };
}

/* 4. Klasse: Brüche & Teile */
function genBrueche(level) {
  if (level === 0) {
    const teile = pick([2, 4]); const a = rand(3, 25) * teile;
    return mach(`${teile === 2 ? "Die Hälfte" : "Ein Viertel"} von ${a} = ?`, a / teile, "Hälfte und Viertel", `Teile ${a} in ${teile} gleich große Teile.`);
  }
  if (level === 1) {
    const teile = pick([3, 6, 8]); const a = rand(2, 12) * teile;
    const name = teile === 3 ? "Ein Drittel" : teile === 6 ? "Ein Sechstel" : "Ein Achtel";
    return mach(`${name} von ${a} = ?`, a / teile, "Bruchteile", `Teile ${a} in ${teile} gleich große Teile.`);
  }
  if (Math.random() < 0.5) { const a = rand(3, 20) * 4; return mach(`Drei Viertel von ${a} = ?`, (a / 4) * 3, "Mehrere Bruchteile", `Rechne zuerst ein Viertel (${a / 4}) – und nimm es dreimal.`); }
  const a = rand(4, 30) * 3; return mach(`Zwei Drittel von ${a} = ?`, (a / 3) * 2, "Mehrere Bruchteile", `Rechne zuerst ein Drittel (${a / 3}) – und nimm es zweimal.`);
}

/* 4. Klasse: Umfang & Fläche */
function genUmfangFlaeche(level) {
  if (level === 0) { const a = rand(2, 9); return mach(`Ein Quadrat hat die Seite ${a} cm. Wie groß ist sein Umfang in cm?`, 4 * a, "Umfang des Quadrats", `Vier gleich lange Seiten: 4 · ${a}.`); }
  if (level === 1) {
    const a = rand(4, 12); const b = rand(2, a - 1);
    return mach(`Ein Rechteck ist ${a} cm lang und ${b} cm breit. Wie groß ist sein Umfang in cm?`, 2 * (a + b), "Umfang des Rechtecks", `Länge plus Breite – und das Ganze zweimal: 2 · (${a} + ${b}).`);
  }
  const a = rand(4, 12); const b = rand(2, 9);
  return mach(`Ein Rechteck ist ${a} cm lang und ${b} cm breit. Wie groß ist seine Fläche in cm²?`, a * b, "Fläche des Rechtecks", `Fläche heißt Länge mal Breite: ${a} · ${b}.`);
}

/* 4. Klasse: Komma, Geld & Maße */
function genKommaGeld(level) {
  if (level === 0) {
    const euro = rand(1, 9); const zehner = rand(1, 9);
    return mach(`${euro},${zehner}0 € = ? c`, euro * 100 + zehner * 10, "Kommazahlen bei Geld", "Vor dem Komma stehen Euro (je 100 c), dahinter die Cent.");
  }
  if (level === 1) {
    if (Math.random() < 0.5) { const km = rand(1, 9); const r = rand(1, 9); return mach(`${km},${r} km = ? m`, km * 1000 + r * 100, "Kommazahlen bei Längen", "1 km sind 1.000 m – die Kommastelle sind Hunderter-Meter."); }
    const m = rand(1, 9); const cm = rand(1, 9); return mach(`${m},${cm}0 m = ? cm`, m * 100 + cm * 10, "Kommazahlen bei Längen", "1 m sind 100 cm – die Kommastellen sind die Zentimeter.");
  }
  if (Math.random() < 0.5) { const t = rand(1, 9); const r = rand(1, 9); return mach(`${t},${r} t = ? kg`, t * 1000 + r * 100, "Kommazahlen bei Gewichten", "1 t sind 1.000 kg – die Kommastelle sind Hunderter-Kilo."); }
  const kg = rand(1, 9); const dag = rand(1, 9); return mach(`${kg} kg ${dag * 10} dag = ? dag`, kg * 100 + dag * 10, "Gemischte Maße", "1 kg sind 100 dag – dann die dag dazuzählen.");
}

function genVerdoppeln(level) {
  if (level === 0) { const a = rand(2, 10); return mach(`Verdopple ${a}!`, a * 2, "Verdoppeln", `Verdoppeln heißt: ${a} + ${a}.`); }
  if (level === 1) { const a = rand(2, 10) * 2; return mach(`Die Hälfte von ${a} = ?`, a / 2, "Halbieren", `Teile ${a} in zwei gleich große Teile.`); }
  if (Math.random() < 0.5) { const a = rand(2, 5) * 10; return mach(`Verdopple ${a}!`, a * 2, "Verdoppeln mit Zehnern", "Verdopple die Zehner – die Null bleibt."); }
  const a = rand(2, 5) * 20; return mach(`Die Hälfte von ${a} = ?`, a / 2, "Halbieren mit Zehnern", "Halbiere die Zehner – die Null bleibt.");
}

function genSach2(level) {
  if (level === 0) { const preis = rand(2, 9); return mach(`Ein Sackerl Karotten kostet ${preis} €. Was kosten 2 Sackerl?`, preis * 2, "Sachaufgabe mit Geld", `2 Sackerl heißt: ${preis} + ${preis}.`); }
  if (level === 1) { const a = rand(25, 60); const b = rand(10, 95 - a); return mach(`Im Stall liegen ${a} Heuballen, es kommen ${b} dazu. Wie viele sind es jetzt?`, a + b, "Sachaufgabe: dazubekommen", `„Dazu" heißt Plus: ${a} + ${b}.`); }
  const preis = rand(12, 45); const bezahlt = (Math.floor(preis / 10) + 1) * 10 + pick([0, 10]);
  return mach(`Das Putzzeug für Daisy kostet ${preis} €. Du zahlst mit ${bezahlt} €. Wie viel bekommst du zurück?`, bezahlt - preis, "Sachaufgabe: Rückgeld", `Rückgeld heißt Minus: ${bezahlt} − ${preis}.`);
}

const TURNIERPFADE = [
  {
    id: "klasse1",
    titel: "1. Klasse",
    emoji: "🐣",
    rundenLaenge: 5,
    stationen: [
      { id: "s1_zaehlen", emoji: "🐣", titel: "Zählen & Zahlen", sub: "Nachbarzahlen finden", gen: genZaehlen, farbe: PALETTE.grass },
      { id: "s1_zerlegen", emoji: "🧩", titel: "Zerlegen & Ergänzen", sub: "Wie viel fehlt?", gen: genZerlegen, farbe: PALETTE.coral },
      { id: "s1_pm10", emoji: "🌱", titel: "Plus & Minus bis 10", sub: "die ersten Rechnungen", gen: genPlusMinus10, farbe: PALETTE.grass },
      { id: "s1_zr20", emoji: "🔢", titel: "Zahlenraum 20", sub: "Zehner und Einer", gen: genZahlenraum20, farbe: PALETTE.blue },
      { id: "s1_pm20", emoji: "➕", titel: "Plus & Minus bis 20", sub: "über den Zehner", gen: genPlusMinus20, farbe: PALETTE.grass, mix: true },
      { id: "s1_verdopp", emoji: "🪞", titel: "Verdoppeln & Halbieren", sub: "doppelt und halb", gen: genVerdoppeln20, farbe: PALETTE.sun },
      { id: "s1_geld", emoji: "💶", titel: "Mit Euro zahlen", sub: "€ bis 20", gen: genGeld20, farbe: PALETTE.sun, mix: true },
      { id: "s1_final", emoji: "🏆", titel: "Abschlussturnier", sub: "kleine Sachaufgaben", gen: genSach1, farbe: PALETTE.lila, mix: true },
    ],
  },
  {
    id: "klasse2",
    titel: "2. Klasse",
    emoji: "🌱",
    rundenLaenge: 5,
    stationen: [
      { id: "s2_zr100", emoji: "🔢", titel: "Zahlenraum 100 entdecken", sub: "Zehner und Einer", gen: genZahlenraum100, farbe: PALETTE.blue },
      { id: "s2_pmo", emoji: "➕", titel: "Plus & Minus ohne Übertrag", sub: "Schritt für Schritt", gen: genPlusMinusOhne, farbe: PALETTE.grass },
      { id: "s2_pmm", emoji: "💪", titel: "Plus & Minus mit Übertrag", sub: "über den Zehner", gen: genPlusMinusMit, farbe: PALETTE.grass, mix: true },
      { id: "s2_mal", emoji: "✖️", titel: "Das kleine Einmaleins", sub: "alle Malreihen", gen: genKleineMalreihen, farbe: PALETTE.coral },
      { id: "s2_in", emoji: "🍏", titel: "Erste In-Rechnungen", sub: "Teilen kennenlernen", gen: genErsteIn, farbe: PALETTE.coral },
      { id: "s2_verdopp", emoji: "🪞", titel: "Verdoppeln & Halbieren", sub: "doppelt und halb", gen: genVerdoppeln, farbe: PALETTE.sun },
      { id: "s2_zeit", emoji: "⏰", titel: "Uhr & Zeit", sub: "Stunden, Minuten, Tage", gen: genUhrZeit, farbe: PALETTE.sun, mix: true },
      { id: "s2_final", emoji: "🏆", titel: "Abschlussturnier", sub: "gemischte Sachaufgaben", gen: genSach2, farbe: PALETTE.lila, mix: true },
    ],
  },
  {
    id: "klasse3",
    titel: "3. Klasse",
    emoji: "🏠",
    rundenLaenge: 10,
    stationen: [
      { id: "s3_warm", emoji: "🐾", titel: "Aufwärmen: Plus & Minus bis 100", sub: "Wiederholung", gen: genWarm100, farbe: PALETTE.grass },
      { id: "s3_zr", emoji: "🔢", titel: "Zahlenraum 1000 entdecken", sub: "Hunderter, Zehner, Einer", gen: genZahlenraum1000, farbe: PALETTE.blue },
      { id: "s3_pm", emoji: "➕", titel: "Plus & Minus bis 1000", sub: "rechnen im großen Raum", gen: genPlusMinus1000, farbe: PALETTE.grass, mix: true },
      { id: "s3_mal", emoji: "✖️", titel: "Malreihen sichern", sub: "das Einmaleins", gen: genMalreihen, farbe: PALETTE.coral },
      { id: "s3_in", emoji: "🍏", titel: "In-Rechnungen", sub: "Teilen lernen", gen: genInRechnungen, farbe: PALETTE.coral },
      { id: "s3_rest", emoji: "➗", titel: "Division mit Rest", sub: "z. B. 47 : 5", gen: genRest, farbe: PALETTE.blue, mix: true },
      { id: "s3_teile", emoji: "🍕", titel: "Hälfte & Viertel", sub: "Brüche anbahnen", gen: genHaelfteViertel, farbe: PALETTE.lila },
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
    rundenLaenge: 10,
    stationen: [
      { id: "s4_zr", emoji: "🔢", titel: "Zahlenraum 100.000 entdecken", sub: "große Zahlen verstehen", gen: genZahlenraum100k, farbe: PALETTE.blue },
      { id: "s4_mio", emoji: "🚀", titel: "Bis zur Million", sub: "der ganze Zahlenraum", gen: genMillion, farbe: PALETTE.blue },
      { id: "s4_pm", emoji: "➕", titel: "Plus & Minus bis 100.000", sub: "rechnen im großen Raum", gen: genPlusMinus100k, farbe: PALETTE.grass },
      { id: "s4_rund", emoji: "🎯", titel: "Runden & Überschlagen", sub: "≈ ungefähr rechnen", gen: genRunden, farbe: PALETTE.lila, mix: true },
      { id: "s4_mal", emoji: "✖️", titel: "Mal & In mit großen Zahlen", sub: "geschickt zerlegen", gen: genMalIn100k, farbe: PALETTE.coral },
      { id: "s4_div", emoji: "➗", titel: "Schriftlich dividieren", sub: "große Zahlen teilen", gen: genSchriftlichDiv, farbe: PALETTE.blue, mix: true },
      { id: "s4_brueche", emoji: "🍕", titel: "Brüche & Teile", sub: "Drittel, Viertel, Achtel", gen: genBrueche, farbe: PALETTE.lila },
      { id: "s4_geo", emoji: "📐", titel: "Umfang & Fläche", sub: "Rechteck und Quadrat", gen: genUmfangFlaeche, farbe: PALETTE.lila },
      { id: "s4_masse", emoji: "⚖️", titel: "Neue Maße", sub: "t, mm, s", gen: genMasseNeu, farbe: PALETTE.sun },
      { id: "s4_komma", emoji: "💶", titel: "Komma, Geld & Maße", sub: "2,50 € verstehen", gen: genKommaGeld, farbe: PALETTE.sun, mix: true },
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

/* ---------- Lokales Speichern (localStorage) ----------
   Schleifen, Gangarten, Klasse und Tagesstatistik bleiben auf dem
   Gerät erhalten – auch nach Neuladen oder Browser-Neustart.
   try/catch, weil localStorage z. B. im privaten Modus fehlen kann. */

const SPEICHER_PREFIX = "lernweide.";

function ladeGespeichert(schluessel, fallback) {
  try {
    const roh = localStorage.getItem(SPEICHER_PREFIX + schluessel);
    return roh === null ? fallback : JSON.parse(roh);
  } catch {
    return fallback;
  }
}

function useLokalGespeichert(schluessel, startwert) {
  const [wert, setWert] = useState(() => ladeGespeichert(schluessel, startwert));
  useEffect(() => {
    try {
      localStorage.setItem(SPEICHER_PREFIX + schluessel, JSON.stringify(wert));
    } catch {
      // Speichern nicht möglich (z. B. privater Modus) – die App läuft trotzdem.
    }
  }, [schluessel, wert]);
  return [wert, setWert];
}

/** Heutiges Datum als "JJJJ-MM-TT" – für den Tages-Reset der Statistik. */
function heutigesDatum() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

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

function PausenTimer({ endeZeit, onFertig }) {
  // Das Pausenende kommt als fixer Zeitpunkt von außen (und liegt im
  // localStorage): So läuft die Pause auch bei gesperrtem Display weiter –
  // und Neuladen hilft nicht, die Restzeit bleibt die echte. 🙂
  const [status, setStatus] = useState(Date.now() >= endeZeit ? "fertig" : "laeuft");
  const [restzeit, setRestzeit] = useState(
    Math.max(0, Math.ceil((endeZeit - Date.now()) / 1000))
  );

  useEffect(() => {
    if (status !== "laeuft") return;
    const aktualisiere = () => {
      const rest = Math.max(0, Math.ceil((endeZeit - Date.now()) / 1000));
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
  }, [status, endeZeit]);

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
  // Läuft laut localStorage noch eine Bewegungspause? Dann startet die App
  // direkt in der Warteschleife – Neuladen führt sofort zurück in die Pause.
  const [screen, setScreen] = useState(() =>
    Date.now() < ladeGespeichert("pauseEnde", 0) ? "pause" : "home"
  );
  const [klasse, setKlasse] = useLokalGespeichert("klasse", "klasse3"); // wird später ein Profil-Setting
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
  // Pausenende als Zeitstempel im localStorage: Neuladen umgeht die Pause nicht.
  const [pauseEnde, setPauseEnde] = useLokalGespeichert("pauseEnde", 0);
  const [wartestation, setWartestation] = useState(null); // startet nach der Pause
  const [rundenErgebnis, setRundenErgebnis] = useState(null); // { sterne, level, schleifeNeu }

  // Heutige Statistik für Daisys Tagesbericht 📸 – bleibt lokal gespeichert
  // und beginnt an einem neuen Tag automatisch bei null.
  const [heute, setHeute] = useLokalGespeichert("heute", {
    datum: heutigesDatum(),
    aufgaben: 0,
    sterne: 0,
    schleifen: 0,
  });
  useEffect(() => {
    if (heute.datum !== heutigesDatum()) {
      setHeute({ datum: heutigesDatum(), aufgaben: 0, sterne: 0, schleifen: 0 });
    }
  }, [heute.datum]);
  const [berichtUrl, setBerichtUrl] = useState(null);
  const berichtCanvasRef = useRef(null);

  // Turnier-Fortschritt: welche Stationen haben schon eine Schleife 🎀?
  // Bleibt lokal gespeichert – einmal Geschafftes ist nie wieder weg.
  const [schleifen, setSchleifen] = useLokalGespeichert(
    "schleifen",
    Object.fromEntries(ALLE_STATION_IDS.map((id) => [id, false]))
  );

  // Gangart pro Station – auch über Sitzungen hinweg.
  const [levels, setLevels] = useLokalGespeichert(
    "levels",
    Object.fromEntries(ALLE_STATION_IDS.map((id) => [id, 0]))
  );
  const [level, setLevel] = useState(0);
  const [upStreak, setUpStreak] = useState(0);
  const [downStreak, setDownStreak] = useState(0);
  const [levelMsg, setLevelMsg] = useState(null);

  const timerRef = useRef(null);
  // Bereits gestellte Fragen der laufenden Runde – keine Frage doppelt.
  const gestellteFragenRef = useRef(new Set());
  useEffect(() => () => clearTimeout(timerRef.current), []);

  const pfad = TURNIERPFADE.find((p) => p.id === klasse) ?? TURNIERPFADE[0];
  const rundenLaenge = pfad.rundenLaenge;

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
     Positionen 2 und 4 Wiederholungen (falls es Geschafftes gibt).
     Keine Frage doppelt in einer Runde: kleine Zahlenräume (z. B.
     „Ergänzen auf 10") würfeln sonst fast sicher Doppler. */
  function erzeugeAufgabe(nr, lvl) {
    const roh = () => {
      // Jede zweite Position wiederholt – außer der ersten und der letzten.
      if (station.mix && nr % 2 === 1 && nr < rundenLaenge - 1) {
        const w = wiederholungsAufgabe();
        if (w) return w;
      }
      return station.gen(lvl);
    };
    let a = roh();
    for (let anlauf = 0; anlauf < 12 && gestellteFragenRef.current.has(a.frage); anlauf++) {
      a = roh();
    }
    gestellteFragenRef.current.add(a.frage);
    return a;
  }

  function startRound(s) {
    // Läuft noch eine Bewegungspause (auch nach Neuladen)? Dann erst fertig hüpfen!
    if (Date.now() < pauseEnde) {
      setWartestation(s);
      setPause(pick(PAUSEN));
      setPauseFertig(false);
      setScreen("pause");
      return;
    }
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
    gestellteFragenRef.current = new Set();
    const erste = s.gen(startLevel);
    gestellteFragenRef.current.add(erste.frage);
    setTask(erste);
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
    if (taskNr + 1 >= rundenLaenge) {
      // Runde fertig → Schleifen-Check 🎀
      const bestanden = finaleSterne >= schleifeMinSterne(rundenLaenge) && neuesLevel >= SCHLEIFE_MIN_GANGART;
      schleifeNeu = bestanden && !schleifen[station.id];
      if (schleifeNeu) {
        setSchleifen((s) => ({ ...s, [station.id]: true }));
      }
      setRundenErgebnis({ sterne: finaleSterne, level: neuesLevel, schleifeNeu, hatSchleife: schleifen[station.id] || schleifeNeu });
      setPauseFertig(false); // Bewegungspause ist Pflicht – Buttons erst danach
      setPauseEnde(Date.now() + PAUSE_SEKUNDEN * 1000); // überlebt auch ein Neuladen
      setScreen("done");
    } else {
      const nr = taskNr + 1;
      setTaskNr(nr);
      setTask(erzeugeAufgabe(nr, neuesLevel));
      setPhase("frage");
    }

    // Tages-Statistik für Daisys Bericht 📸 – nach Mitternacht frisch anfangen
    setHeute((h) => {
      const datum = heutigesDatum();
      const basis = h.datum === datum ? h : { aufgaben: 0, sterne: 0, schleifen: 0 };
      return {
        datum,
        aufgaben: basis.aufgaben + 1,
        sterne: basis.sterne + (mitStern ? 1 : 0),
        schleifen: basis.schleifen + (schleifeNeu ? 1 : 0),
      };
    });
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

          {/* Klassen-Wahl: kompaktes Auswahlfeld statt vier Buttons –
              am iPhone öffnet sich das native Wahlrad. */}
          <div className="klassen-wahl">
            <label className="klassen-label" htmlFor="klassen-select">Ich bin in der</label>
            <select
              id="klassen-select"
              className="klassen-select"
              value={klasse}
              onChange={(e) => setKlasse(e.target.value)}
            >
              {TURNIERPFADE.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.emoji} {p.titel}
                </option>
              ))}
            </select>
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
            🎀 Schleife = mindestens {schleifeMinSterne(rundenLaenge)} von {rundenLaenge} Sternen im {GANGARTEN[SCHLEIFE_MIN_GANGART].name} oder schneller.
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
            <Weideweg step={taskNr} total={rundenLaenge} />
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
                    {schleifeMinSterne(rundenLaenge)} Sterne im {GANGARTEN[SCHLEIFE_MIN_GANGART].name} – du schaffst das!
                  </p>
                )}
              </>
            )}

            <div className="stars" aria-label={`${rundenErgebnis.sterne} von ${rundenLaenge} Sternen`}>
              {Array.from({ length: rundenLaenge }).map((_, i) => (
                <span key={i} className={i < rundenErgebnis.sterne ? "star on" : "star"}>★</span>
              ))}
            </div>
            <p className="done-gangart">
              Daisys Tempo: {GANGARTEN[rundenErgebnis.level].emoji} <strong>{GANGARTEN[rundenErgebnis.level].name}</strong>
            </p>
            <div className="pause-box">
              <p className="pause-titel">Bewegungspause! 🤸</p>
              <p>{pause}</p>
              <PausenTimer endeZeit={pauseEnde} onFertig={() => setPauseFertig(true)} />
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

      {screen === "pause" && (
        <div className="screen">
          <div className="card done-card">
            <div className="big-emoji pop">🤸</div>
            <h2>Erst fertig hüpfen!</h2>
            <p className="done-text">
              Die Bewegungspause läuft noch – Daisy wartet so lange auf dich.
            </p>
            <div className="pause-box">
              <p className="pause-titel">Bewegungspause! 🤸</p>
              <p>{pause}</p>
              <PausenTimer endeZeit={pauseEnde} onFertig={() => setPauseFertig(true)} />
            </div>
            {pauseFertig && (
              <div className="done-buttons">
                {(wartestation ?? naechsteOffeneStation) && (
                  <button
                    className="btn-primary"
                    onClick={() => startRound(wartestation ?? naechsteOffeneStation)}
                  >
                    Weiter geht&rsquo;s {(wartestation ?? naechsteOffeneStation).emoji}
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
.klassen-wahl {
  display: flex; align-items: center; justify-content: center; gap: 10px;
}
.klassen-label {
  font-weight: 800; color: ${PALETTE.soft}; font-size: 15px;
}
.klassen-select {
  -webkit-appearance: none; appearance: none;
  font-family: 'Baloo 2', cursive; font-size: 17px; color: ${PALETTE.ink};
  background: #fff; border: 3px solid ${PALETTE.grass}; border-radius: 999px;
  padding: 8px 36px 8px 16px; cursor: pointer;
  box-shadow: 0 3px 0 rgba(51,41,31,0.10);
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='8'><path d='M1 1l5 5 5-5' stroke='%2333291F' stroke-width='2.5' fill='none' stroke-linecap='round'/></svg>");
  background-repeat: no-repeat; background-position: right 14px center;
}

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
.stars { font-size: 28px; letter-spacing: 3px; }  /* 10 Sterne müssen in eine Zeile passen */
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
