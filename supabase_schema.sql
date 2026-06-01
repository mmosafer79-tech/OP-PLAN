-- ============================================================
-- OP-PLANUNG · Klinikum Traunstein
-- Supabase SQL Schema — einmalig im Dashboard ausführen:
-- supabase.com/dashboard → Projekt → SQL Editor → Run
-- ============================================================

-- Tabelle anlegen
CREATE TABLE IF NOT EXISTS op_eingriffe (
  id           TEXT PRIMARY KEY,
  datum        TEXT,           -- 'YYYY-MM-DD'
  uhrzeit      TEXT,           -- 'HH:MM'
  patient      TEXT,           -- Pseudonym / Kürzel, kein Klarname (DSGVO)
  diagnose     TEXT,
  icd          TEXT,
  icd_text     TEXT,
  ops_code     TEXT,
  ops_text     TEXT,
  prozedur     TEXT,
  seite        TEXT,
  dauer        TEXT,           -- Minuten als String (kompatibel mit App)
  saal         TEXT,
  anaesthesie  TEXT,
  implantate   TEXT,
  op1          TEXT DEFAULT 'Dr. Mosafer',
  op2          TEXT,
  anaest       TEXT,
  pflege       TEXT,
  status       TEXT DEFAULT 'geplant',
  prioritaet   TEXT DEFAULT 'elektiv',
  monitoring   TEXT,
  notiz        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security aktivieren
ALTER TABLE op_eingriffe ENABLE ROW LEVEL SECURITY;

-- Policy: nur eingeloggte User (Supabase Auth)
-- Anon-Zugriff wird bewusst gesperrt (DSGVO: Patientendaten)
CREATE POLICY "auth_all" ON op_eingriffe
  FOR ALL
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- updated_at automatisch aktualisieren
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = public;

CREATE TRIGGER trg_updated_at
  BEFORE UPDATE ON op_eingriffe
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
