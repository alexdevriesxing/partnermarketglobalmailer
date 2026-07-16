CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO settings (key, value) VALUES
  ('company_name', 'PartnerMarket Global'),
  ('company_address', ''),
  ('default_footer', 'You are receiving this email because you opted in or have an existing business relationship with us.');
