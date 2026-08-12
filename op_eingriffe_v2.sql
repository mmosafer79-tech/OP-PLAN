-- ============================================================
-- OP-EINGRIFFE v2 · Nebenerkrankungs-Kategorie A / B / C
--
-- Neue, bewusst NEUTRALE Kategorie-Spalte. A/B/C ist nur ein
-- Sortier-/Markierungsmerkmal für den Schweregrad der Neben-
-- erkrankungen — die konkrete Bedeutung legt jede beteiligte
-- Abteilung selbst fest. Bleibt aus Statistik & Zählung heraus.
--
-- Wird an drei Stellen gepflegt (index.html + anmeldebogen.html):
--   - Warteliste: Inline-Dropdown je Fall
--   - OP-Modal:   Dropdown neben „Priorität"
--   - Anmeldebogen: Feld bei „Dringlichkeit & Eingriff"
--
-- WICHTIG: Diese Migration ZUERST im Supabase-Dashboard ausführen,
-- BEVOR die neue index.html/anmeldebogen.html live geht — der
-- upsert schickt das ganze Objekt inkl. nk_kategorie; fehlt die
-- Spalte, lehnt PostgREST das Speichern ab.
--
-- Ausführen: Supabase Dashboard → SQL Editor → Run (neuer Tab).
-- Idempotent (IF NOT EXISTS) — mehrfaches Ausführen ist gefahrlos.
-- ============================================================

ALTER TABLE op_eingriffe ADD COLUMN IF NOT EXISTS nk_kategorie TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS nk_kategorie TEXT;

-- Neuromonitoring als 3-Zustand (statt nur „an/aus"): explizit auch
-- „kein IONM erforderlich" dokumentierbar. Werte: 'erforderlich' /
-- 'nicht_erforderlich' / '' (unbestimmt). Die alte Boolean-Spalte
-- anmeldeboegen.ionm bleibt für Rückwärtskompatibilität erhalten und wird
-- beim Speichern weiter mitgeführt (ionm = true, wenn Status 'erforderlich').
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ionm_status TEXT;
