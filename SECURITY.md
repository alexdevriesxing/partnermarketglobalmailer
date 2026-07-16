# Security

- Protect the production hostname with Cloudflare Access.
- Keep `UNSUBSCRIBE_SECRET`, Cloudflare credentials, and admin allowlists in secrets, never source control.
- Use sender domains authenticated by SPF, DKIM, and DMARC.
- Restrict the Cloudflare API token to the minimum account and resource permissions required.
- Review audience provenance before sending and never import purchased or unlawfully obtained lists.
- Keep the suppression table intact during data migrations and backups.
- Rotate secrets after any suspected exposure.

Report security issues privately to the repository owner rather than opening a public issue.
