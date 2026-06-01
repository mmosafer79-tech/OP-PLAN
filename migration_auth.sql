-- ============================================================
-- Migration: Anon-Policy entfernen, Auth-Policy einrichten
-- Ausführen in: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- 1. Alte offene Policy entfernen
DROP POLICY IF EXISTS "anon_all" ON op_eingriffe;

-- 2. Neue Policy: nur authentifizierte User (explizite uid-Prüfung)
DROP POLICY IF EXISTS "auth_all" ON op_eingriffe;
CREATE POLICY "auth_all" ON op_eingriffe
  FOR ALL
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- 3. Trigger-Funktion mit fixem search_path absichern
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = public;
