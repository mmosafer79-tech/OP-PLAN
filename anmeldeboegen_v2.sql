-- ============================================================
-- ANMELDEBÖGEN v2 · Zusammenführung mit KSOB-Sprechstundenanforderung
--
-- Bringt die Tabelle 'anmeldeboegen' auf den Stand des Traunsteiner
-- Hausformulars "CHU Sprechstundenanforderung" (KSOB500268, Rev. 2)
-- und verknüpft OP-Plan-Einträge fest mit ihrem Bogen.
--
-- Voraussetzung: anmeldeboegen_schema.sql wurde bereits ausgeführt.
-- Ausführen: Supabase Dashboard → SQL Editor → Run
--
-- Alle Statements sind idempotent (IF NOT EXISTS) — mehrfaches
-- Ausführen ist gefahrlos.
-- ============================================================

-- ---------- Standort (Traunstein / Praxis Rosenheim) ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS standort TEXT DEFAULT 'traunstein';

-- ---------- Eingriff: Operateur, Antibiose, Lagerung ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS op_qualifikation    TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS op_dauer            TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ab_single_shot      BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ab_cefuroxim        BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ab_antibiose_sonst  TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS implantat_bestellen BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS lagerung            TEXT;

-- ---------- Aufnahme & Planung ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS aufnahmemodus       TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS g_aep               BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS nicht_zopv          BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS aoz_moeglich        BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS op_innerhalb_wert   TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS op_innerhalb_einheit TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS nicht_vor_tagen     TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS aufnahme_zeitpunkt  TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS verweildauer_tage   TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS unterbringung       TEXT;

-- ---------- Rehabilitation ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS reha_art            TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS reha_ahb            BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS reha_planen_ab      TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS reha_6wo            BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS reha_wunschklinik   TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS sozialdienst_am     TEXT;

-- ---------- Gerinnung (feiner als die bisherigen Checkboxen) ----------
-- ab_ass / ab_metformin aus v1 bleiben erhalten (Altdaten), werden aber
-- vom Formular nicht mehr geschrieben. Neu: Modus + Absetzdatum je Präparat.
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ass_modus           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS ass_ab              TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS clopi_modus         TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS clopi_ab            TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS marcumar_modus      TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS marcumar_ab         TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS keine_medikamente   BOOLEAN DEFAULT FALSE;

-- ---------- Weitere Medizin ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS allergien           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS dialyse_tage        TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS praeop_abfuehren    BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS icu_postop          BOOLEAN DEFAULT FALSE;

-- ---------- Konsile stationär ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS konsil_kardio       BOOLEAN DEFAULT FALSE;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS konsil_kardio_text  TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS konsil_neuro_text   TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS konsil_sonst        TEXT;

-- ---------- Befunde prästationär (Matrix Rö / CT / MRT / frei) ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ro_status       TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ro_geplant      TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ro_hz           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ct_status       TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ct_geplant      TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_ct_hz           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_mrt_status      TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_mrt_geplant     TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_mrt_hz          TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_sonst_label     TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_sonst_status    TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_sonst_geplant   TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS bef_sonst_hz        TEXT;

-- ---------- Anordnender Arzt ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS arzt_tel            TEXT;

-- ---------- Vom ZBM auszufüllen (nur Traunstein) ----------
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS zbm_opv             TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS zbm_opv_anae        TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS zbm_op_am           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS tel_pat             TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS tel_angeh           TEXT;
ALTER TABLE anmeldeboegen ADD COLUMN IF NOT EXISTS betreuer            TEXT;

-- ============================================================
-- Verknüpfung OP-Plan-Eintrag -> Anmeldebogen
--
-- Bisher lief die Zuordnung über die ID-Konvention 'op_' + bogen.id.
-- Das bricht still, sobald ein Fall direkt im Kalender angelegt und der
-- Bogen später nachgereicht wird. Ab jetzt: echte Spalte.
-- ============================================================
ALTER TABLE op_eingriffe ADD COLUMN IF NOT EXISTS bogen_id TEXT;

CREATE INDEX IF NOT EXISTS idx_op_eingriffe_bogen_id ON op_eingriffe (bogen_id);

-- Altbestand nachziehen: vorhandene 'op_AB…'-IDs auf ihren Bogen mappen
UPDATE op_eingriffe
   SET bogen_id = substring(id from 4)
 WHERE bogen_id IS NULL
   AND id LIKE 'op\_%';
