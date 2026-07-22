-- ============================================================
-- Rollen-Migration OP-Plan (2026-07-22)
-- 3 Rollen:
--   admin  = Dr. Mosafer            → alles, inkl. Status "bestaetigt"
--   planer = Dr. Wittmann           → anlegen/planen/ändern/absagen,
--                                     aber nie "bestaetigt" setzen und
--                                     bestätigte Fälle nicht anfassen
--   lesen  = KSOB (Sammel-Account)  → nur lesen
--
-- Idempotent: kann gefahrlos mehrfach laufen. Nach dem Anlegen der
-- User florianwittmann@web.de und ksob@mosafer-spine.de im Dashboard
-- einfach ERNEUT ausführen — die Rollen-Zuordnung greift dann.
--
-- ⚠ Supabase SQL-Editor: immer über "+" einen NEUEN Tab öffnen
--   (nicht in einem gespeicherten Alt-Query arbeiten).
-- ============================================================

-- 1. Rollen-Tabelle -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_rollen (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  rolle   TEXT NOT NULL CHECK (rolle IN ('admin','planer','lesen'))
);
ALTER TABLE app_rollen ENABLE ROW LEVEL SECURITY;

-- Jeder darf nur die eigene Rolle lesen; schreiben kann niemand
-- (Zuordnung nur hier im SQL-Editor / als service_role).
DROP POLICY IF EXISTS "rolle_selbst_lesen" ON app_rollen;
CREATE POLICY "rolle_selbst_lesen" ON app_rollen
  FOR SELECT USING (user_id = auth.uid());

-- 2. Rollen-Funktion ----------------------------------------------------------
-- SECURITY DEFINER, damit die Policies unten die Tabelle trotz RLS lesen können.
CREATE OR REPLACE FUNCTION public.app_rolle()
RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$ SELECT rolle FROM app_rollen WHERE user_id = auth.uid() $$;

GRANT EXECUTE ON FUNCTION public.app_rolle() TO authenticated;

-- 3. Rollen zuordnen ----------------------------------------------------------
-- Admin ZUERST — sonst sperrt Schritt 4 den eigenen Zugriff.
INSERT INTO app_rollen (user_id, rolle)
SELECT id, 'admin' FROM auth.users WHERE email = 'm.mosafer79@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET rolle = 'admin';

INSERT INTO app_rollen (user_id, rolle)
SELECT id, 'planer' FROM auth.users WHERE email = 'florianwittmann@web.de'
ON CONFLICT (user_id) DO UPDATE SET rolle = 'planer';

INSERT INTO app_rollen (user_id, rolle)
SELECT id, 'lesen' FROM auth.users WHERE email = 'ksob@mosafer-spine.de'
ON CONFLICT (user_id) DO UPDATE SET rolle = 'lesen';

-- 4. op_eingriffe: auth_all ersetzen ------------------------------------------
DROP POLICY IF EXISTS "auth_all" ON op_eingriffe;

DROP POLICY IF EXISTS "lesen_alle" ON op_eingriffe;
CREATE POLICY "lesen_alle" ON op_eingriffe
  FOR SELECT USING (app_rolle() IS NOT NULL);

DROP POLICY IF EXISTS "admin_alles" ON op_eingriffe;
CREATE POLICY "admin_alles" ON op_eingriffe
  FOR ALL USING (app_rolle() = 'admin')
  WITH CHECK (app_rolle() = 'admin');

-- Planer: darf keinen Fall auf "bestaetigt" setzen (WITH CHECK) und
-- bereits bestätigte Fälle weder ändern noch löschen (USING) —
-- sonst ließe sich die Bestätigung durch Bearbeiten aushebeln.
DROP POLICY IF EXISTS "planer_insert" ON op_eingriffe;
CREATE POLICY "planer_insert" ON op_eingriffe
  FOR INSERT WITH CHECK (app_rolle() = 'planer' AND status IS DISTINCT FROM 'bestaetigt');

DROP POLICY IF EXISTS "planer_update" ON op_eingriffe;
CREATE POLICY "planer_update" ON op_eingriffe
  FOR UPDATE USING (app_rolle() = 'planer' AND status IS DISTINCT FROM 'bestaetigt')
  WITH CHECK (app_rolle() = 'planer' AND status IS DISTINCT FROM 'bestaetigt');

DROP POLICY IF EXISTS "planer_delete" ON op_eingriffe;
CREATE POLICY "planer_delete" ON op_eingriffe
  FOR DELETE USING (app_rolle() = 'planer' AND status IS DISTINCT FROM 'bestaetigt');

-- 5. anmeldeboegen: lesen alle, schreiben admin+planer ------------------------
DROP POLICY IF EXISTS "auth_all" ON anmeldeboegen;

DROP POLICY IF EXISTS "lesen_alle" ON anmeldeboegen;
CREATE POLICY "lesen_alle" ON anmeldeboegen
  FOR SELECT USING (app_rolle() IS NOT NULL);

DROP POLICY IF EXISTS "schreiben_admin_planer" ON anmeldeboegen;
CREATE POLICY "schreiben_admin_planer" ON anmeldeboegen
  FOR ALL USING (app_rolle() IN ('admin','planer'))
  WITH CHECK (app_rolle() IN ('admin','planer'));

-- 6. abwesenheiten: lesen alle, schreiben admin+planer ------------------------
DROP POLICY IF EXISTS "auth_all" ON abwesenheiten;

DROP POLICY IF EXISTS "lesen_alle" ON abwesenheiten;
CREATE POLICY "lesen_alle" ON abwesenheiten
  FOR SELECT USING (app_rolle() IS NOT NULL);

DROP POLICY IF EXISTS "schreiben_admin_planer" ON abwesenheiten;
CREATE POLICY "schreiben_admin_planer" ON abwesenheiten
  FOR ALL USING (app_rolle() IN ('admin','planer'))
  WITH CHECK (app_rolle() IN ('admin','planer'));

-- 7. Kontrolle ----------------------------------------------------------------
-- Erwartet: m.mosafer79@gmail.com=admin; nach dem Anlegen der User zusätzlich
-- florianwittmann@web.de=planer und ksob@mosafer-spine.de=lesen.
SELECT u.email, r.rolle
FROM app_rollen r JOIN auth.users u ON u.id = r.user_id
ORDER BY r.rolle;
