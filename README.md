# OP-Planung · Klinikum Traunstein

Digitale OP-Planung für die Pädiatrische Orthopädie & Skoliose — Kalenderübersicht (Monat/Woche), Detailerfassung, ICD-10/OPS-Kodierung, Team-Zuordnung, CSV-Export und Druckfunktion.

Reine HTML/CSS/JS-Anwendung, kein Server nötig. Läuft in jedem modernen Browser.

## Live-Version

Nach Aktivierung von GitHub Pages (siehe unten) erreichbar unter:
`https://<DEIN-GITHUB-NAME>.github.io/op-planung/`

## Funktionen

- **Monats- und Wochenansicht** mit Uhrzeiten und farbcodierten OP-Blöcken
- **Status-Tracking:** Geplant → Bestätigt → Durchgeführt → Abgesagt
- **Priorität:** Elektiv / Dringlich / Notfall
- **Erfassung pro OP:** Patient-ID (pseudonymisiert), Diagnose, ICD-10 (mit lokaler Suche häufiger Wirbelsäulencodes), OPS-Code, Prozedur, Seite, Dauer, Saal, Anästhesie, Implantate
- **Team:** Operateur 1 + 2, Anästhesist, OP-Pflege
- **Neuromonitoring / Besonderheiten** und interne Notizen
- **Suche & Filter** nach Status und Saal
- **CSV-Export** (Excel-kompatibel, UTF-8)
- **Druckfunktion** (A4 quer)

## Datenspeicherung

Aktuell werden alle Daten lokal im Browser gespeichert (`localStorage`). Das bedeutet:

- Daten bleiben pro Gerät und Browser erhalten
- **Keine geräteübergreifende Synchronisation** (geplant für v3 — z.B. via Synology NAS / Supabase EU)

> **Datenschutz:** Nur pseudonymisierte Patienten-Kürzel verwenden, keine Klarnamen. OP-Daten unterliegen DSGVO/BDSG.

## GitHub Pages aktivieren

1. Repository erstellen (z.B. `op-planung`)
2. Diese Dateien hochladen (`index.html`, `README.md`)
3. **Settings → Pages → Source:** Branch `main`, Ordner `/ (root)` → **Save**
4. Nach ~1 Minute ist die App unter der oben genannten URL erreichbar

## Roadmap

- [ ] v3: Geräteübergreifende Synchronisation (Synology NAS / Supabase EU)
- [ ] Mehrere Operateure / Standorte
- [ ] PDF-Tagesplan für Anästhesie & OP-Pflege
- [ ] medatixx-Integration

---
*Entwickelt für Dr. med. Mostafa Mosafer · Mosafer Spine*
