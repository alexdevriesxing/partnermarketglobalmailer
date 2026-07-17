-- Seeds the default sender identity. The From address must sit on the domain
-- onboarded to Cloudflare Email Sending so outbound mail carries a valid DKIM
-- signature. Replies are directed back to the same address, which depends on
-- inbound Email Routing being configured for it.
INSERT OR IGNORE INTO sender_identities (id, name, email, reply_to, status, is_default)
VALUES (
  'default-sender',
  'PartnerMarket Global',
  'alex@partnermarketglobal.com',
  'alex@partnermarketglobal.com',
  'ready',
  1
);
