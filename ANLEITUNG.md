# So bringst du die App online — Schritt für Schritt

Du brauchst dafür kein Terminal und keine Vorkenntnisse. Ca. 5 Minuten.

## Schritt 1 — GitHub-Account
Falls noch nicht vorhanden: auf https://github.com kostenlos registrieren.

## Schritt 2 — Repository anlegen
1. Oben rechts auf das **+** → **New repository**
2. **Repository name:** `op-planung`
3. Sichtbarkeit: **Private** wählen (wichtig — keine OP-Daten öffentlich!)
   - Hinweis: GitHub Pages funktioniert mit privaten Repos nur in bezahlten Plänen.
     Für die kostenlose Variante "Public" wählen — dann aber NIEMALS echte
     Patientendaten eintragen, nur Testdaten. Echtdaten erst mit Sync-Backend (v3).
4. **Create repository**

## Schritt 3 — Dateien hochladen
1. Im neuen Repo auf **"uploading an existing file"** klicken
   (oder: **Add file → Upload files**)
2. Beide Dateien hineinziehen:
   - `index.html`
   - `README.md`
3. Unten **Commit changes**

## Schritt 4 — GitHub Pages aktivieren
1. Im Repo oben auf **Settings**
2. Linke Seite: **Pages**
3. Unter **Source:** Branch `main` auswählen, Ordner `/ (root)`
4. **Save**
5. Nach ~1 Minute Seite neu laden — oben erscheint die Live-URL:
   `https://<dein-name>.github.io/op-planung/`

## Schritt 5 — Von jedem Gerät nutzen
- Die URL auf PC, iPad, iPhone als Lesezeichen / zum Homescreen hinzufügen
- Auf dem iPhone: Safari → Teilen → "Zum Home-Bildschirm" → läuft wie eine App

## Code von überall bearbeiten
- Im Repo auf `index.html` → Stift-Symbol (✏) → direkt im Browser ändern → Commit
- Änderungen sind nach ~1 Minute live

---

## Wichtig zum Thema Daten

Aktuell speichert die App lokal pro Gerät (localStorage). Das heißt:
- Trägst du am PC eine OP ein, erscheint sie NICHT automatisch am iPad.
- Für echte Synchronisation bauen wir im nächsten Schritt ein Backend ein
  (empfohlen: deine Synology DS224+ — Daten bleiben in Deutschland, DSGVO-konform).

Sag einfach Bescheid, wenn du bei der Sync-Stufe weitermachen willst.
