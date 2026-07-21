# Patientenportal — Bedarf Skoliosechirurgie & Kinderorthopädie

**Termin:** Donnerstag, 23.07.2026, 14:00 Uhr (Microsoft Teams)
**Projektleitung KSOB:** Simon Pfannes, Projektmanager Digitalisierung & IT
**Weitere Beteiligte:** B. Berner, T. Schöndorfer, I. Baumgartner (ZBM), V. Hofmann
**Für die Abteilung:** Dr. M. Mosafer

---

## 1. Ausgangslage

Die neue Abteilung startet mit einem Team von vier Ärzten (Mosafer, Wittmann, Moravec, Bas) und einem Sekretariat (D. Stiller). Sprechstunden sollen auch im OSZ angeboten werden.

Zwei Punkte machen die Abteilung zu einem Sonderfall im Portal-Rollout:

**a) Doppelrolle Praxis ↔ Klinik.** Dr. Mosafer betreibt parallel die Praxis Mosafer Spine in Rosenheim (PVS: medatixx). Ein relevanter Teil der Patienten wird dort gesehen und nach Traunstein zur Operation angemeldet. Die Abteilung ist damit gleichzeitig **Zuweiser und Empfänger** — der Zuweiserpfad ist für uns kein Randthema, sondern der Hauptpfad.

**b) Der Zuweiserkanal ist derzeit nicht definiert.** Frau Baumgartner hat am 13.07.2026 schriftlich mitgeteilt, dass das aktuelle Formular „Sprechstundenanforderung CHSK" eine Übergangslösung ist („Ziel ist es dieses Formular schnell abzulösen") und dass nicht vorgegeben ist, ob externe Praxen per Fax oder E-Mail anfordern. Diese Lücke sollte das Projekt mit adressieren.

---

## 2. Ist-Zustand der Abteilung (bereits vorhanden)

| Baustein | Stand |
|---|---|
| **OP-Planungs-App** | Produktiv einsetzbar. Monats-/Wochenansicht, Statusverfolgung, ICD-10/OPS, Abwesenheits-/Urlaubsplanung des Teams, CSV-Export, Logins für Mosafer und Sekretariat. |
| **Digitale Sprechstundenanforderung** | Das KSOB-Hausformular (KSOB500268) ist als ausfüllbares Formular umgesetzt und um wirbelsäulenspezifische Felder ergänzt (Korsett, Bending, Navigation, Myelographie, Narkose beim Kind). Entwurf ging am 20.07. an Frau Baumgartner zur Abstimmung. |
| **Verknüpfung** | Ein ausgefüllter Bogen erzeugt automatisch den zugehörigen OP-Plan-Eintrag; der Bogen bleibt am Fall hinterlegt und ist jederzeit editier- und druckbar. |
| **Versand** | PDF + E-Mail an das ZBM. |

Die Abteilung kommt also nicht mit einer leeren Anforderungsliste, sondern mit einem laufenden Workflow, der entweder abgelöst oder angebunden werden sollte — beides ist besser als ein drittes Parallelsystem.

---

## 3. Grundsätzliche Abgrenzung (gemeinsames Verständnis)

Zwei verschiedene Kommunikationsachsen, die im Gespräch nicht vermischt werden sollten:

| | **KIM** (Telematikinfrastruktur) | **Patientenportal** (KHZG) |
|---|---|---|
| Achse | Praxis ↔ Klinik, Arzt ↔ Arzt | **Patient** ↔ Klinik |
| Inhalte | eArztbrief, Befunde, Zuweisung/Anforderung | Termine, Anamnese- und Aufklärungsbögen, Dokumenten-Upload, Entlassunterlagen |
| Deckt unseren OP-Anmeldeweg ab? | **Ja** | Nur mit separatem Zuweisermodul |

Für die Ablösung des Papierformulars ist deshalb primär KIM (oder ein Zuweiserportal) relevant, nicht das Patientenportal im engeren Sinn.

---

## 4. Bedarf entlang des Behandlungspfads

**Zuweisung / OP-Anmeldung (höchste Priorität)**
- Definierter, datenschutzkonformer Kanal für externe Praxen und für die Praxis Rosenheim — Fax ist keine tragfähige Zielarchitektur.
- Strukturierte Übernahme der Anforderungsdaten ins KIS, statt Abtippen im ZBM.

**Vor der Sprechstunde**
- Anamnesebogen und Einwilligungen digital vorab durch den Patienten — hier liegt der größte Zeitgewinn in der Sprechstunde.
- Upload von Vorbefunden und Bildgebung durch Patient oder Zuweiser (bei Skoliose regelhaft umfangreiche Voraufnahmen und Verlaufsbilder).

**OP-Planung**
- Rückkopplung zwischen Portal-/KIS-Termin und OP-Plan in beide Richtungen; eine Terminverschiebung darf nicht zu zwei divergierenden Ständen führen.
- Sichtbarkeit für das Sekretariat, welche Fälle noch unvollständig sind.

**Aufnahme / prästationär**
- Prämedikation und prästationäre Befunde verlässlich terminiert — hier gab es am 08.07. bereits einen Fall mit fehlender Prämedikation.
- Digitale Aufklärung, sofern das Portal das unterstützt.

**Entlassung**
- Reha-Anbindung (AHB/Sozialdienst) und Entlassdokumente über das Portal.

---

## 5. Fragen an das Projekt

1. Welches Produkt wird eingesetzt, und gibt es ein **Zuweiserportal-Modul**? Falls ja: Löst es die Sprechstundenanforderung ab, und zu welchem Termin?
2. Ist **KIM am Standort Traunstein produktiv**? Gibt es eine KIM-Adresse für ZBM oder Fachabteilung, an die eine Praxis anfordern kann?
3. Womit genau soll das Formular abgelöst werden — Portal, Medico-Funktion oder etwas Drittes? Mit welchem Zeitplan?
4. Kann das Portal **Anamnese- und Aufklärungsbögen vor dem Termin** einsammeln, und sind fachspezifische Bögen (Skoliose, Kinderorthopädie) abbildbar?
5. Gibt es eine **Schnittstelle oder strukturierten Import/Export**, oder ist der Zugriff ausschließlich über die Oberfläche vorgesehen?
6. Wie gelangen Portal-Termine in den OP- und Sprechstundenplan — und geht das in beide Richtungen?
7. **Minderjährige Patienten:** Wie werden Sorgeberechtigte im Portal abgebildet (Zugang, Einwilligung, getrennt lebende Eltern)? Für die Kinderorthopädie ist das der Regelfall, nicht die Ausnahme.
8. Wie funktioniert der Portalzugang für **internationale Selbstzahler** ohne deutsche Versichertenstruktur?
9. Welche Datenschutzvereinbarungen sind zwischen Praxis (eigenständig Verantwortliche) und KSOB erforderlich, wenn beide Seiten denselben Behandlungspfad bedienen?

---

## 6. Offene Punkte zur Klärung im Termin

- **Startdatum der Abteilung:** Die Projektmail nennt den 01.09., in der bisherigen Abstimmung war vom 01.08. die Rede. Für Portal-Konfiguration, Sprechstundenzeiten und Saalkontingente muss ein Datum gelten.
- **Sprechstundenzeiten** sind noch nicht final gesetzt und werden für die Portal-Terminvergabe benötigt.
- **Empfängeradresse ZBM:** In den Hausverteilern wird `zentrales.belegungsmanagement.ts@kliniken-sob.de` verwendet. Bestätigung, dass Anforderungen dorthin gehen sollen.

---

## 7. Angestrebtes Ergebnis

1. Verbindliche Aussage, ob und wann der Zuweiserpfad digital abgebildet wird.
2. Entscheidung, ob die bestehende OP-Planung angebunden oder abgelöst wird.
3. Fester Ansprechpartner für die Abteilung im Projekt und ein Folgetermin.
4. Bis dahin: Der bestehende Weg (ausgefülltes PDF per E-Mail ans ZBM) bleibt als Übergang aktiv.
