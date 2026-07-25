-- ============================================================
-- ANMELDEBÖGEN v3 · IONM + Traktionsaufnahme
--
-- Ergänzt die Felder für das intraoperative Neuromonitoring und die
-- Traktionsaufnahme in der Diagnostik.
--
-- Die Lagerungs-Optionen (Seitenlagerung statt Vacuum re./li.,
-- Halotraktion statt Extensionstisch) brauchen kein Schema-Update —
-- 'lagerung' ist TEXT.
--
-- Gestrichene Felder (op_qualifikation, g_aep, nicht_zopv, konsil_*)
-- werden vom Formular nicht mehr geschrieben. Die Spalten bleiben
-- absichtlich stehen, damit Altbögen lesbar bleiben.
--
-- Voraussetzung: anmeldeboegen_v2.sql wurde bereits ausgeführt.
-- Ausführen: Supabase Dashboard → SQL Editor → Run
--
-- Idempotent (IF NOT EXISTS) — mehrfaches Ausführen ist gefahrlos.
-- ============================================================

ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ionm       BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS d_traktion BOOLEAN DEFAULT FALSE;
