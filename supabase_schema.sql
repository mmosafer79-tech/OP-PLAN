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

-- Policy: anon darf alles lesen und schreiben
-- (Single-User-App ohne Login — für Multi-User später Auth hinzufügen)
CREATE POLICY "anon_all" ON op_eingriffe
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- updated_at automatisch aktualisieren
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_updated_at
  BEFORE UPDATE ON op_eingriffe
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
