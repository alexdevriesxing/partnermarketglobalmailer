-- Open and click tracking.
--
-- Tracking is on by default per the product decision, but each campaign can turn
-- either signal off, which matters for recipients where there is no lawful basis
-- to track under GDPR/ePrivacy.
ALTER TABLE campaigns ADD COLUMN track_opens INTEGER NOT NULL DEFAULT 1 CHECK (track_opens IN (0, 1));
ALTER TABLE campaigns ADD COLUMN track_clicks INTEGER NOT NULL DEFAULT 1 CHECK (track_clicks IN (0, 1));

-- Every distinct destination URL in a campaign. Click tracking URLs carry this
-- id rather than the target URL, which keeps links short and stops the redirect
-- endpoint from being used as an open redirect: only stored URLs can be reached.
CREATE TABLE IF NOT EXISTS campaign_links (
  id TEXT PRIMARY KEY,
  campaign_id TEXT NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_campaign_links_campaign_url ON campaign_links(campaign_id, url);

-- events already indexes (campaign_id, type). Analytics additionally counts
-- distinct contacts per campaign/type for unique open and click rates, filters
-- contacts by engagement, and builds activity timelines.
CREATE INDEX IF NOT EXISTS idx_events_campaign_type_contact ON events(campaign_id, type, contact_id);
CREATE INDEX IF NOT EXISTS idx_events_contact_type ON events(contact_id, type);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);
