-- ============================================================
-- ANMELDEBÖGEN · Wirbelsäulenchirurgie
-- Vollständiger Anmeldebogen inkl. Klarname (Patientenstammdaten).
-- WICHTIG (DSGVO): Diese Tabelle enthält echte Patientendaten.
--   - Nur für authentifizierte User (RLS unten).
--   - Projekt muss in EU-Region liegen.
--   - Niemals Inhalte in Git committen (nur dieses Schema).
-- Einmalig ausführen: Supabase Dashboard → SQL Editor → Run
-- ============================================================

CREATE TABLE IF NOT EXISTS anmeldeboegen (
  id                TEXT PRIMARY KEY,
  -- Patient (Klarname)
  p_name            TEXT,
  p_gebdat          TEXT,
  p_geschlecht      TEXT,
  p_fallnr          TEXT,
  p_strasse         TEXT,
  p_ort             TEXT,
  p_kasse           TEXT,
  p_versnr          TEXT,
  p_kostentraeger   TEXT,
  p_bkat            TEXT,
  p_wunschtermin    TEXT,
  begleitperson     BOOLEAN DEFAULT FALSE,
  terminieren       BOOLEAN DEFAULT FALSE,
  -- Eingriff
  dringlichkeit     TEXT DEFAULT 'Elektiv',
  diagnose          TEXT,
  icd               TEXT,
  ops_code          TEXT,
  op1_text          TEXT,
  op2_text          TEXT,
  implantat         TEXT,
  seite             TEXT,
  op_datum          TEXT,
  uhrzeit           TEXT,
  praeop_tage       TEXT,
  postop_tage       TEXT,
  blut_blutgruppe   BOOLEAN DEFAULT FALSE,
  blut_ek           BOOLEAN DEFAULT FALSE,
  blut_cellsaver    BOOLEAN DEFAULT FALSE,
  -- Medikamente absetzen
  ab_metformin      BOOLEAN DEFAULT FALSE,
  ab_ass            BOOLEAN DEFAULT FALSE,
  ab_glp            BOOLEAN DEFAULT FALSE,
  ab_schrittmacher  BOOLEAN DEFAULT FALSE,
  ab_sonstiges      TEXT,
  -- Kinder / Konsile / Korsett
  kind_narkose      BOOLEAN DEFAULT FALSE,
  kind_sedierung    BOOLEAN DEFAULT FALSE,
  konsil_neuro      BOOLEAN DEFAULT FALSE,
  konsil_anaesth    BOOLEAN DEFAULT FALSE,
  korsett           TEXT,
  korsett_sonstiges TEXT,
  -- Diagnostik
  d_roentgen        BOOLEAN DEFAULT FALSE,
  d_rx_hws          BOOLEAN DEFAULT FALSE,
  d_rx_lws          BOOLEAN DEFAULT FALSE,
  d_rx_pan          BOOLEAN DEFAULT FALSE,
  d_funktion        BOOLEAN DEFAULT FALSE,
  d_bending         BOOLEAN DEFAULT FALSE,
  d_ct              BOOLEAN DEFAULT FALSE,
  d_ct_nav          BOOLEAN DEFAULT FALSE,
  d_mrt             BOOLEAN DEFAULT FALSE,
  d_mrt_navkopf     BOOLEAN DEFAULT FALSE,
  d_mrt_funkt       BOOLEAN DEFAULT FALSE,
  d_infiltration    BOOLEAN DEFAULT FALSE,
  d_myelo           BOOLEAN DEFAULT FALSE,
  d_sonstiges       TEXT,
  -- Fuss
  notiz             TEXT,
  arzt              TEXT,
  erstellt          TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security: nur eingeloggte User (Anon gesperrt)
ALTER TABLE anmeldeboegen ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "auth_all" ON anmeldeboegen;
CREATE POLICY "auth_all" ON anmeldeboegen
  FOR ALL
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- updated_at automatisch aktualisieren (nutzt vorhandene Funktion update_updated_at)
DROP TRIGGER IF EXISTS trg_anmeldeboegen_updated ON anmeldeboegen;
CREATE TRIGGER trg_anmeldeboegen_updated
  BEFORE UPDATE ON anmeldeboegen
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
