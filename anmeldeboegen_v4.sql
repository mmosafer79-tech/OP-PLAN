-- ============================================================
-- ANMELDEBÖGEN v4 · Labor (Rückmeldung ZBM Traunstein, 07/2026)
--
-- Das Zentrale Belegungsmanagement wünscht im Kasten „Dringlichkeit &
-- Eingriff" unter „Blut" eine Laboranforderung. Ein Kästchen genügt —
-- ein Labor ohne CRP wird nicht angefordert — plus Freitext für
-- zusätzliche Parameter.
--
-- Die ebenfalls gewünschte Patiententelefonnummer braucht KEINE neue
-- Spalte: Das Feld 'tel_pat' existiert seit v2, es stand nur im Block
-- „Vom ZBM auszufüllen" und ist jetzt in den Patient-Kasten gewandert.
--
-- Voraussetzung: anmeldeboegen_v3.sql wurde bereits ausgeführt.
-- Ausführen: Supabase Dashboard → SQL Editor → Run
--
-- Idempotent (IF NOT EXISTS) — mehrfaches Ausführen ist gefahrlos.
-- ============================================================

ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS lab_standard BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS lab_zusatz   TEXT;
