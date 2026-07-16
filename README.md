# PartnerMarket Global Mailer

A Cloudflare-native audience management and compliant email campaign application. It combines a polished admin dashboard with Cloudflare Workers, D1, Queues, Email Service, Static Assets, Access, Cron Triggers, and GitHub Actions.

## Included

- Multiple logical contact databases (audiences)
- CSV, XLS, and XLSX imports with column mapping and preview
- Contact search, sorting, status, custom columns, and CSV export
- Global tags and campaign tag filters
- Custom sender identities and Reply-To addresses
- HTML and plain-text campaign composer with merge tags
- Scheduled and immediate sends
- D1 campaign recipient snapshots
- Queue-based delivery, retries, dead-letter queue configuration, and send logs
- Global suppression list
- Signed one-click unsubscribe links and `List-Unsubscribe` headers
- Cloudflare Access-ready admin protection
- Responsive PartnerMarket Global dashboard

## Architecture

```text
Browser admin app
       │
       ▼
Cloudflare Worker ───── Static Assets
       │
       ├─────────────── D1 (audiences, contacts, campaigns, suppressions)
       │
       ├─────────────── Queue producer
       │                        │
       │                        ▼
       ├─────────────── Queue consumer ─── Cloudflare Email Service
       │
       └─────────────── Cron dispatcher (every minute)
```

The app uses **one D1 database with multiple logical audience databases**. This makes cross-database search, tags, suppression checks and campaign analytics efficient. Cloudflare supports separate physical D1 databases as well, but one structured database is the safer default for this use case.

## Important Email Service constraint

The UI lets you choose any sender address, but Cloudflare will only deliver it when the address belongs to a domain onboarded under **Compute → Email Service → Email Sending** in your Cloudflare account. Onboarding configures SPF, DKIM, DMARC, and bounce handling. Mark a sender identity `ready` only after that setup is complete.

This project is designed for permission-based business outreach and relationship email. You remain responsible for lawful basis, consent, accurate sender identification, a physical mailing address where required, and prompt opt-out handling.

## Source assembly

The repository stores the validated Worker and browser sources in deterministic parts under `source-parts/`. Running any build, development, type-check, or deploy command first reconstructs `src/index.ts` and `public/app.js` through `scripts/assemble.mjs`.

## First deployment

### 1. Install dependencies

```bash
npm install
```

### 2. Create the D1 database

```bash
npx wrangler d1 create partnermarket-global-mailer
```

Copy the returned database UUID into `wrangler.jsonc`, replacing:

```json
"database_id": "00000000-0000-0000-0000-000000000000"
```

### 3. Create the queues

```bash
npx wrangler queues create partnermarket-global-mailer-send
npx wrangler queues create partnermarket-global-mailer-dead-letter
```

### 4. Set the unsubscribe secret

Use a long random value. Never commit it.

```bash
npx wrangler secret put UNSUBSCRIBE_SECRET
```

### 5. Configure the public URL

Update `PUBLIC_BASE_URL` in `wrangler.jsonc` to the final custom domain or `workers.dev` URL. This URL is embedded in unsubscribe links.

### 6. Apply migrations

```bash
npm run db:migrate:remote
```

### 7. Onboard a sending domain

In Cloudflare:

1. Open **Compute → Email Service → Email Sending**.
2. Select **Onboard Domain**.
3. Choose a domain using Cloudflare DNS.
4. Confirm the SPF, DKIM, DMARC, bounce MX and TXT records.
5. Add a matching sender identity in the app and mark it `ready`.

### 8. Protect the app with Cloudflare Access

Create an Access self-hosted application for the mailer hostname. The Worker expects both the `Cf-Access-Authenticated-User-Email` and `Cf-Access-Jwt-Assertion` headers when `REQUIRE_ACCESS` is `true`.

Optionally restrict specific admins:

```bash
npx wrangler secret put ADMIN_EMAILS
```

Use a comma-separated list, for example:

```text
alex@example.com,operations@example.com
```

### 9. Deploy

```bash
npm run deploy
```

## GitHub Actions

The workflow in `.github/workflows/deploy.yml` deploys `main`. Add these repository secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

The API token needs Workers Scripts, D1, Queues, and deployment permissions for the target account.

## Local development

Create `.dev.vars`:

```dotenv
REQUIRE_ACCESS=false
PUBLIC_BASE_URL=http://localhost:8787
UNSUBSCRIBE_SECRET=replace-with-a-long-local-development-secret
```

Then run:

```bash
npm run db:migrate:local
npm run dev
```

Cloudflare's local Email Service simulation does not send real production email.

## Merge tags

Campaign content supports:

- `{{first_name}}`
- `{{last_name}}`
- `{{full_name}}`
- `{{email}}`
- `{{company}}`
- `{{job_title}}`
- `{{country}}`
- `{{phone}}`
- `{{unsubscribe_url}}`
- Extra spreadsheet columns stored in `custom_json`

## Operational notes

- New campaign launches snapshot all eligible contacts into `campaign_recipients`.
- The minute cron dispatches pending recipients to the queue in controlled batches.
- The queue consumer checks suppressions again immediately before sending.
- Failed sends retry up to three times, then move to `failed`; queue-level failures can land in the dead-letter queue.
- Cloudflare Email Service account quotas still apply. Adjust `SEND_BATCH_PER_MINUTE` to stay inside your approved sending rate.
- D1 import size defaults to 5,000 rows per upload and can be changed with `MAX_IMPORT_ROWS` up to the application cap.

## Validation

```bash
npm run check
```

This reconstructs the source, runs TypeScript validation, and performs a Wrangler dry-run bundle.
