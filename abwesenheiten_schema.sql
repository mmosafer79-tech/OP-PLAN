-- ============================================================
-- OP-PLANUNG · Urlaubs-/Abwesenheitsplanung
-- Supabase SQL Schema — einmalig im Dashboard ausführen:
-- supabase.com/dashboard → Projekt → SQL Editor → NEUER TAB (+) → Run
--
-- ⚠ Immer erst auf "+" klicken. Sonst landet man in einem der
--   gespeicherten Queries vom Juni und führt versehentlich Altes aus.
--
-- Bewusst eigene Tabelle statt Zusatzfeldern in op_eingriffe:
-- Abwesenheiten sind Zeiträume (von/bis) ohne Uhrzeit, Patient und
-- Anmeldebogen. In op_eingriffe würden sie Statistik, CSV-Export und
-- Drag & Drop verfälschen.
-- ============================================================

CREATE TABLE IF NOT EXISTS abwesenheiten (
  id          TEXT PRIMARY KEY,
  person      TEXT NOT NULL,            -- 'mosafer' | 'wittmann' | 'moravec' | 'bas'
  von         TEXT NOT NULL,            -- 'YYYY-MM-DD'
  bis         TEXT NOT NULL,            -- 'YYYY-MM-DD' (inklusiv)
  art         TEXT NOT NULL DEFAULT 'urlaub',  -- 'urlaub' | 'fortbildung' | 'krank'
  notiz       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Schnelle Bereichsabfrage pro Monat/Woche
CREATE INDEX IF NOT EXISTS idx_abwesenheiten_zeitraum ON abwesenheiten (von, bis);

-- Row Level Security (Mitarbeiterdaten → nur eingeloggte User)
ALTER TABLE abwesenheiten ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "auth_all" ON abwesenheiten;
CREATE POLICY "auth_all" ON abwesenheiten
  FOR ALL
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- updated_at automatisch aktualisieren (Funktion existiert bereits aus supabase_schema.sql)
DROP TRIGGER IF EXISTS trg_abw_updated_at ON abwesenheiten;
CREATE TRIGGER trg_abw_updated_at
  BEFORE UPDATE ON abwesenheiten
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
