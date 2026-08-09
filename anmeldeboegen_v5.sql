-- ============================================================
-- ANMELDEBÖGEN v5 · Versand-Zeitstempel „Bogen versendet"
--
-- Neues Kalender-Merkmal (Gegenstück zu „⚠ kein Anmeldebogen"): ein
-- grünes/navyfarbenes Papierflieger-Badge am Chip, sobald der Mail-
-- Entwurf ans ZBM tatsächlich geöffnet wurde. Zwei Spalten, gleiches
-- Muster wie bogen_id (anmeldeboegen_schema.sql):
--   - anmeldeboegen.versendet_am   : Quelle der Wahrheit
--   - op_eingriffe.bogen_versendet_am : Kopie fürs Kalender-Rendering
--     ohne Join (op_eingriffe ist ohnehin geladen)
--
-- Wichtig: bildet nur ab, dass der Mail-Entwurf GEÖFFNET wurde — nicht,
-- ob die Mail tatsächlich abgeschickt/angekommen ist (gleiche Grenze
-- wie beim mailto-Anhang selbst).
--
-- Voraussetzung: anmeldeboegen_v4.sql wurde bereits ausgeführt.
-- Ausführen: Supabase Dashboard → SQL Editor → Run (neuer Tab, nicht
-- versehentlich eine gespeicherte Alt-Query öffnen!)
--
-- Idempotent (IF NOT EXISTS) — mehrfaches Ausführen ist gefahrlos.
-- ============================================================

ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS versendet_am TIMESTAMPTZ;
ALTER TABLE op_eingriffe  ADD COLUMN IF NOT EXISTS bogen_versendet_am TIMESTAMPTZ;
