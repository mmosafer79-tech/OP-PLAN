// Edge Function: baut den Anmeldebogen als ECHTES OOXML-.docx (nicht Word-HTML)
// und verschlüsselt es serverseitig mit AES-256, bevor es den Browser erreicht.
//
// Warum serverseitig: Die Verschlüsselung darf NIE clientseitig mit einem im
// (öffentlichen!) Repo oder Browser-Storage abgelegten Passwort erfolgen — das
// Passwort liegt hier ausschließlich als Supabase-Edge-Function-Secret
// (ZBM_PASSWORT), niemals im Client erreichbar. Es entsteht dadurch an keiner
// Stelle des gesamten Ablaufs eine unverschlüsselte, versendbare Datei — der
// Browser bekommt von Anfang an nur die fertig verschlüsselten Bytes.
//
// Warum "docx"-Bibliothek statt Word-HTML: officecrypto-tool kann nur echte
// OOXML-ZIP-Container (word/document.xml etc.) verschlüsseln, keine Word-HTML-
// Datei (das bisherige .doc-Format). Die Edge-Function-Sandbox hat kein
// LibreOffice/Office zur Konvertierung — deshalb wird das Dokument hier direkt
// als valides OOXML gebaut.
//
// Geprüft (02.09.2026, lokal via Deno vor Deploy): docx@9 + officecrypto-tool@0.0.19
// laufen sauber per npm-Specifier in Deno, erzeugen echtes AES-256 (keyBits:256,
// ECMA-376 Agile), Ergebnis mit unabhängigem Werkzeug (Python msoffcrypto)
// verifiziert entschlüsselbar.

import {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  WidthType, BorderStyle, ShadingType, AlignmentType, VerticalAlign,
} from "npm:docx@9";
import officeCrypto from "npm:officecrypto-tool@0.0.19";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ---------- Kleine Formatierungs-Bausteine (Entsprechung zu wMark/wLine/wPair/wBox im Frontend) ----------

const NAVY = "0A2240";
const GRAU = "555555";
const RAND = "C8D0DC";
const DUENN = "999999";

function mark(label: string, checked: boolean | undefined): TextRun[] {
  return [
    new TextRun({ text: (checked ? "☒ " : "☐ ") + label + "   " }),
  ];
}

function marksParagraph(items: [string, boolean | undefined][]): Paragraph {
  const runs: TextRun[] = [];
  for (const [label, checked] of items) runs.push(...mark(label, checked));
  return new Paragraph({ children: runs, spacing: { after: 60 } });
}

function labelRun(text: string): TextRun {
  return new TextRun({ text, color: GRAU, size: 18 }); // 9pt
}
function valueRun(text: string): TextRun {
  return new TextRun({ text: text || " ", size: 20 }); // 10pt
}

function lineParagraph(label: string, value?: string): Paragraph {
  return new Paragraph({
    children: [labelRun(label + "  "), valueRun(value || "")],
    border: { bottom: { style: BorderStyle.SINGLE, size: 2, color: DUENN } },
    spacing: { after: 80 },
  });
}

function noBorder() {
  return {
    top: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
    bottom: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
    left: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
    right: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
  };
}

function pairCellLabel(text: string) {
  return new TableCell({
    width: { size: 15, type: WidthType.PERCENTAGE },
    borders: noBorder(),
    margins: { top: 40, bottom: 40, left: 0, right: 100 },
    children: [new Paragraph({ children: [labelRun(text)] })],
  });
}
function pairCellValue(text?: string) {
  return new TableCell({
    width: { size: 35, type: WidthType.PERCENTAGE },
    borders: { ...noBorder(), bottom: { style: BorderStyle.SINGLE, size: 2, color: DUENN } },
    margins: { top: 40, bottom: 40, left: 0, right: 200 },
    children: [new Paragraph({ children: [valueRun(text)] })],
  });
}
function pairRow(l1: string, v1?: string, l2 = "", v2?: string): TableRow {
  return new TableRow({
    children: [pairCellLabel(l1), pairCellValue(v1), pairCellLabel(l2), pairCellValue(v2)],
  });
}
function pairsTable(rows: TableRow[]): Table {
  return new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows });
}

// Umrandete Box mit Titel — Entsprechung zu wBox()
function box(title: string, content: (Paragraph | Table)[], highlight = false): Table {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: {
      top: { style: BorderStyle.SINGLE, size: 4, color: RAND },
      bottom: { style: BorderStyle.SINGLE, size: 4, color: RAND },
      left: { style: BorderStyle.SINGLE, size: 4, color: RAND },
      right: { style: BorderStyle.SINGLE, size: 4, color: RAND },
      insideHorizontal: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
      insideVertical: { style: BorderStyle.NONE, size: 0, color: "FFFFFF" },
    },
    rows: [
      new TableRow({
        children: [
          new TableCell({
            shading: highlight ? { type: ShadingType.CLEAR, fill: "F4F6FA" } : undefined,
            margins: { top: 150, bottom: 150, left: 150, right: 150 },
            children: [
              new Paragraph({
                children: [new TextRun({ text: title, bold: true, color: NAVY, size: 21 })],
                border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: NAVY } },
                spacing: { after: 100 },
              }),
              ...content,
            ],
          }),
        ],
      }),
    ],
  });
}

// Zwei Boxen nebeneinander — Entsprechung zu wBoxRow()
function boxRow(box1: Table, box2: Table): Table {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: noBorder(),
    rows: [
      new TableRow({
        children: [
          new TableCell({ width: { size: 50, type: WidthType.PERCENTAGE }, borders: noBorder(), margins: { right: 100 }, children: [box1] }),
          new TableCell({ width: { size: 50, type: WidthType.PERCENTAGE }, borders: noBorder(), margins: { left: 100 }, children: [box2] }),
        ],
      }),
    ],
  });
}

function dataHeadCell(text: string) {
  return new TableCell({
    shading: { type: ShadingType.CLEAR, fill: "EEF1F5" },
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ children: [new TextRun({ text, bold: true, size: 18 })] })],
  });
}
function dataCell(text: string) {
  return new TableCell({
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ children: [new TextRun({ text: text || " ", size: 19 })] })],
  });
}

// ---------- Formularaufbau (1:1-Entsprechung zu baueWordHtml() im Frontend) ----------

function bauDokument(b: Record<string, any>, standort: string): Document {
  const P: (Paragraph | Table)[] = [];

  // ---------- Patient ----------
  const patientRows = pairsTable([
    pairRow("Name, Vorname", b.p_name, "Geb.-Datum", b.p_gebdat),
    pairRow("Geschlecht", b.p_geschlecht, "Fall-/Aufnahme-Nr.", b.p_fallnr),
    pairRow("Straße", b.p_strasse, "PLZ / Ort", b.p_ort),
    pairRow("Krankenkasse", b.p_kasse, "Vers.-Nr.", b.p_versnr),
    pairRow("Kostenträger", b.p_kostentraeger, "Behandlungskat.", b.p_bkat),
    pairRow("Tel. Patient", b.tel_pat, "Wunschmonat / -termin", b.p_wunschtermin),
  ]);
  P.push(box("Patient", [
    patientRows,
    marksParagraph([["mit Begleitperson", b.begleitperson], ["Pat. terminieren", b.terminieren]]),
  ]));

  // ---------- Dringlichkeit & Eingriff ----------
  const dringInner: (Paragraph | Table)[] = [
    marksParagraph((["Elektiv", "dringlich", "Notfall", "Warteliste"] as string[]).map(v => [v, b.dringlichkeit === v])),
  ];
  if (b.nk_kategorie) dringInner.push(lineParagraph("Kategorie Nebenerkrankungen (A/B/C)", b.nk_kategorie));
  dringInner.push(
    lineParagraph("Diagnose", b.diagnose),
    pairsTable([pairRow("ICD-10", b.icd, "OPS-Code", b.ops_code)]),
    lineParagraph("1. Operation", b.op1_text),
    lineParagraph("2. Operation", b.op2_text),
    pairsTable([pairRow("OP-Dauer (min)", b.op_dauer, "Seite", b.seite)]),
    new Paragraph({ children: [labelRun("Lagerung")] }),
    marksParagraph((["Bauchlage", "Rücken", "Seitenlagerung", "Halotraktion"] as string[]).map(v => [v, b.lagerung === v])),
    marksParagraph([
      ["IONM erforderlich", b.ionm_status === "erforderlich" || (!b.ionm_status && b.ionm)],
      ["kein IONM erforderlich", b.ionm_status === "nicht_erforderlich"],
    ]),
    new Paragraph({ children: [labelRun("Antibiose")] }),
    marksParagraph([["Single shot", b.ab_single_shot], ["Cefuroxim", b.ab_cefuroxim]]),
    lineParagraph("Antibiose sonstiges", b.ab_antibiose_sonst),
    pairsTable([pairRow("Implantat", b.implantat, "Implantat bestellen?", b.implantat_bestellen ? "Ja → sep. Bogen" : "Nein")]),
    new Paragraph({ children: [labelRun("Blut")] }),
    marksParagraph([
      ["Blutgruppe inkl. AK", b.blut_blutgruppe], ["EK bereitstellen", b.blut_ek],
      ["Cell-Saver", b.blut_cellsaver], ["ICU post OP", b.icu_postop],
    ]),
    pairsTable([pairRow("Standardlabor inkl. CRP", (b.lab_standard ? "☒" : "☐") + " Ja/Nein", "erw. Laborparameter", b.lab_zusatz)]),
  );
  P.push(box("Dringlichkeit & Eingriff", dringInner));

  // ---------- Aufnahme & Planung ----------
  const aufnInner: (Paragraph | Table)[] = [
    marksParagraph([
      ["stationär", b.aufnahmemodus === "stationär"], ["ambulant", b.aufnahmemodus === "ambulant"],
      ["OP i. AOZ möglich", b.aoz_moeglich],
    ]),
    pairsTable([
      pairRow("OP innerhalb", [b.op_innerhalb_wert, b.op_innerhalb_einheit].filter(Boolean).join(" "), "nicht vor (Tagen)", b.nicht_vor_tagen),
      pairRow("OP-Datum", b.op_datum, "Uhrzeit", b.uhrzeit),
    ]),
    new Paragraph({ children: [labelRun("Aufnahme")] }),
    marksParagraph((["am OP-Tag", "1 Tag vor OP"] as string[]).map(v => [v, b.aufnahme_zeitpunkt === v])),
    pairsTable([pairRow("Verweildauer ca. (Tage)", b.verweildauer_tage, "präop./postop. Tage", [b.praeop_tage, b.postop_tage].filter(Boolean).join(" / "))]),
    new Paragraph({ children: [labelRun("Unterbringung")] }),
    marksParagraph((["1 Bett", "2 Bett", "Chefarztwahl"] as string[]).map(v => [v, b.unterbringung === v])),
  ];
  P.push(box("Aufnahme & Planung", aufnInner));

  // ---------- Rehabilitation | Kinder/Korsett ----------
  const rehaInner: (Paragraph | Table)[] = [
    marksParagraph((["AHB", "6 Wo. nach OP", "keine"] as string[]).map(v => [v, b.reha_art === v])),
    lineParagraph("Reha planen ab", b.reha_planen_ab),
    lineParagraph("bevorzugt in", b.reha_wunschklinik),
    lineParagraph("Sozialdienstinfo durch ZBM am", b.sozialdienst_am),
  ];
  const korsettInner: (Paragraph | Table)[] = [
    marksParagraph([["Narkose", b.kind_narkose], ["in Sedierung", b.kind_sedierung]]),
    new Paragraph({ children: [labelRun("Korsett")] }),
    marksParagraph((["Ja", "Nein"] as string[]).map(v => [v, b.korsett === v])),
    lineParagraph("Korsett sonstiges", b.korsett_sonstiges),
  ];
  P.push(boxRow(box("Rehabilitation", rehaInner), box("Kinder / Korsett", korsettInner)));

  // ---------- Gerinnung & Medikamente ----------
  const gerTable = new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({ children: [dataHeadCell("Medikament"), dataHeadCell("Modus"), dataHeadCell("ab")] }),
      new TableRow({ children: [dataCell("ASS"), dataCell(b.ass_modus), dataCell(b.ass_ab)] }),
      new TableRow({ children: [dataCell("Clopidogrel / OAK"), dataCell(b.clopi_modus), dataCell(b.clopi_ab)] }),
      new TableRow({ children: [dataCell("Marcumar"), dataCell(b.marcumar_modus), dataCell(b.marcumar_ab)] }),
    ],
  });
  P.push(box("Gerinnung & Medikamente", [
    marksParagraph([["Pat. nimmt keine Medikamente", b.keine_medikamente]]),
    gerTable,
    pairsTable([
      pairRow("Metformin absetzen", (b.ab_metformin ? "☒" : "☐") + " Ja/Nein", "GLP-1 absetzen", (b.ab_glp ? "☒" : "☐") + " Ja/Nein"),
      pairRow("Herzschrittmacher", (b.ab_schrittmacher ? "☒" : "☐") + " Ja/Nein", "präoperativ abführen", (b.praeop_abfuehren ? "☒" : "☐") + " Ja/Nein"),
      pairRow("Medikamente sonstiges", b.ab_sonstiges, "Allergien", b.allergien),
    ]),
  ]));

  // ---------- Diagnostik anfordern ----------
  const diagLeft = [
    marksParagraph([["Röntgen", b.d_roentgen]]),
    marksParagraph([["HWS", b.d_rx_hws], ["LWS", b.d_rx_lws], ["PAN (Ganzwirbelsäule)", b.d_rx_pan]]),
    marksParagraph([["Funktionsaufnahmen", b.d_funktion]]),
    marksParagraph([["Bending", b.d_bending], ["Traktionsaufnahme", b.d_traktion]]),
    marksParagraph([["CT", b.d_ct]]),
    marksParagraph([["CT Navigation WS", b.d_ct_nav]]),
  ];
  const diagRight = [
    marksParagraph([["MRT", b.d_mrt]]),
    marksParagraph([["MRT Navigation Kopf", b.d_mrt_navkopf], ["MRT funktionell", b.d_mrt_funkt]]),
    marksParagraph([["diagn. Infiltration", b.d_infiltration]]),
    marksParagraph([["Myelographie", b.d_myelo]]),
    lineParagraph("Sonstiges", b.d_sonstiges),
  ];
  const diagTable = new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: noBorder(),
    rows: [new TableRow({ children: [
      new TableCell({ width: { size: 50, type: WidthType.PERCENTAGE }, borders: noBorder(), margins: { right: 150 }, children: diagLeft }),
      new TableCell({ width: { size: 50, type: WidthType.PERCENTAGE }, borders: { ...noBorder(), left: { style: BorderStyle.SINGLE, size: 2, color: "E2E6EC" } }, margins: { left: 150 }, children: diagRight }),
    ] })],
  });
  P.push(box("Diagnostik anfordern", [diagTable]));

  // ---------- Befunde prästationär ----------
  const befRow = (label: string, status: string | undefined, geplant: string | undefined, hz: string | undefined) =>
    new TableRow({ children: [
      dataCell(label),
      dataCell(status === "vorhanden" ? "vorhanden" : status === "ausstehend" ? "ausstehend" : ""),
      dataCell(geplant || ""),
      dataCell(hz || ""),
    ] });
  const befRows = [
    befRow("Rö", b.bef_ro_status, b.bef_ro_geplant, b.bef_ro_hz),
    befRow("CT", b.bef_ct_status, b.bef_ct_geplant, b.bef_ct_hz),
    befRow("MRT", b.bef_mrt_status, b.bef_mrt_geplant, b.bef_mrt_hz),
  ];
  if (b.bef_sonst_label) befRows.push(befRow(b.bef_sonst_label, b.bef_sonst_status, b.bef_sonst_geplant, b.bef_sonst_hz));
  const befTable = new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({ children: [dataHeadCell(""), dataHeadCell("Status"), dataHeadCell("geplant am"), dataHeadCell("Hz")] }),
      ...befRows,
    ],
  });
  P.push(box("Befunde prästationär", [befTable]));

  // ---------- Bemerkung ----------
  P.push(box("Bemerkung", [new Paragraph({ children: [valueRun(b.notiz)] })]));

  // ---------- Anordnender Arzt ----------
  P.push(box("Anordnender Arzt", [
    pairsTable([pairRow("Name", b.arzt, "Tel. / WLAN für Rückfragen", b.arzt_tel)]),
    new Paragraph({
      spacing: { before: 300 },
      children: [new TextRun({ text: "Unterschrift: ______________________________      Datum: " + (b.erstellt || "____________"), size: 20 })],
    }),
  ]));

  // ---------- Vom ZBM auszufüllen (bewusst LEER, editierbar) ----------
  P.push(box("Vom ZBM auszufüllen", [
    pairsTable([
      pairRow("OPV", "", "OPV Anästhesie", ""),
      pairRow("OP am", "", "Tel. Angehörige", ""),
      pairRow("Betreuer", "", "", ""),
    ]),
    new Paragraph({
      children: [new TextRun({ text: "ZBM-Fax Traunstein: 0861/705-2219 · ZBM-Fax Reichenhall: 08651/772619", size: 17, color: GRAU })],
    }),
  ], true));

  const titel = standort === "traunstein" ? "Sprechstundenanforderung" : "Anmeldebogen";
  const untertitel = (standort === "traunstein"
    ? "Sprechstundenanforderung / Anmeldung zur operativen Behandlung"
    : "Anmeldebogen") + " · Klinikum Traunstein (Kliniken Südostbayern AG)";

  return new Document({
    creator: "OP-Plan Traunstein",
    title: titel + " Wirbelsäulenchirurgie",
    sections: [{
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, bottom: 1134, left: 1020, right: 1020 } } }, // A4, ~2cm/1.8cm
      children: [
        new Paragraph({ children: [new TextRun({ text: "Wirbelsäulenchirurgie", bold: true, color: NAVY, size: 28 })], spacing: { after: 40 } }),
        new Paragraph({ children: [new TextRun({ text: untertitel, color: GRAU, size: 20 })], spacing: { after: 200 } }),
        ...P,
      ],
    }],
  });
}

// ---------- Dateiname (identische Logik wie bogenDateiname() im Frontend — DSGVO: keine Klarnamen im Dateinamen) ----------

function bogenInitialen(pName: string): string {
  const teile = String(pName || "").split(",");
  const nach = (teile[0] || "").trim().charAt(0);
  const vor = (teile[1] || "").trim().charAt(0);
  const kuerzel = (nach + vor).toUpperCase();
  return kuerzel || "XX";
}
function bogenDateiname(b: Record<string, any>): string {
  const initialen = bogenInitialen(b.p_name);
  const datRoh = b.op_datum || b.erstellt || new Date().toISOString().slice(0, 10);
  const datum = String(datRoh).replace(/-/g, "").slice(0, 8) || "00000000";
  const anker = String(b.id || "").replace(/\D/g, "").slice(-6) || "000000";
  const roh = [initialen, datum, anker].join("_");
  const sicher = roh.replace(/[\\/:*?"<>|]/g, "").replace(/\s+/g, "_");
  return sicher + ".docx";
}

// ---------- HTTP-Handler ----------

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Nur POST erlaubt" }), { status: 405, headers: { ...CORS, "Content-Type": "application/json" } });
    }

    const password = Deno.env.get("ZBM_PASSWORT");
    if (!password) {
      // Fail-safe: ohne gesetztes Secret wird NICHTS ausgeliefert — kein
      // unverschlüsselter Fallback, lieber ein sichtbarer Fehler im Frontend.
      return new Response(JSON.stringify({ error: "ZBM_PASSWORT ist auf dem Server nicht gesetzt. Kein Export möglich." }), {
        status: 500, headers: { ...CORS, "Content-Type": "application/json" },
      });
    }

    const { b, standort } = await req.json();
    if (!b || typeof b !== "object") {
      return new Response(JSON.stringify({ error: "Fehlende Formulardaten" }), { status: 400, headers: { ...CORS, "Content-Type": "application/json" } });
    }

    const doc = bauDokument(b, standort || "traunstein");
    const roh = await Packer.toBuffer(doc);
    const verschluesselt = await officeCrypto.encrypt(roh, { password });
    const dateiname = bogenDateiname(b);

    return new Response(verschluesselt, {
      status: 200,
      headers: {
        ...CORS,
        "Content-Type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "Content-Disposition": `attachment; filename="${dateiname}"`,
        "X-Dateiname": dateiname,
      },
    });
  } catch (err) {
    console.error("Fehler beim verschlüsselten Export:", err);
    return new Response(JSON.stringify({ error: String(err instanceof Error ? err.message : err) }), {
      status: 500, headers: { ...CORS, "Content-Type": "application/json" },
    });
  }
});
