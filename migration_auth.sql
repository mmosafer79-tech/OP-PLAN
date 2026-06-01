-- ============================================================
-- Migration: Anon-Policy entfernen, Auth-Policy einrichten
-- Ausführen in: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- 1. Alte offene Policy entfernen
DROP POLICY IF EXISTS "anon_all" ON op_eingriffe;

-- 2. Neue Policy: nur authentifizierte User
CREATE POLICY "auth_all" ON op_eingriffe
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
