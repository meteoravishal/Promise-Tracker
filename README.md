# Promise Tracker V3.1

Promise Tracker turns commitments into trackable promises: what you promised, what others promised you, due dates, money attached to commitments, AI-assisted extraction, follow-ups, and reminders.

## Live beta architecture

- Vercel-ready static frontend + Node API functions
- Supabase Auth and Postgres persistence
- Per-user Row Level Security for user-owned data
- Gmail and WhatsApp credentials isolated from browser sessions
- AI extraction with a built-in heuristic fallback when OpenAI is not configured
- Stripe, Gmail, WhatsApp and scheduled reminder hooks activate only when their server-side secrets are supplied

## Run locally

Requires Node.js 20+.

1. Copy `.env.example` to `.env` if you want to override the built-in beta Supabase public settings or enable private integrations.
2. Run `node server.js`.
3. Open `http://localhost:3000`.

The Supabase project URL and publishable key used by the beta are public client configuration and are intentionally safe to ship in the application. Never commit a Supabase secret key, OpenAI key, Google client secret, Stripe secret, Meta app secret, or token-encryption key.

## Database

`docs/supabase-schema.sql` is the production schema reference. It enables RLS on every public table, grants authenticated users only the operations they need, and deliberately gives browser users no direct access to Gmail or WhatsApp credential tables.

## Production-only environment variables

See `.env.example`. The core beta works with Supabase Auth + Promise CRUD without private server credentials. To activate server integrations add private values in the hosting environment for:

- `SUPABASE_SECRET_KEY`
- `OPENAI_API_KEY`
- Google OAuth / Gmail credentials
- `TOKEN_ENCRYPTION_KEY` and `OAUTH_STATE_SECRET`
- Stripe credentials and price IDs
- Meta WhatsApp credentials
- `CRON_SECRET`

## Security notes

- User-owned tables are protected with ownership-based RLS.
- OAuth and WhatsApp tokens are stored encrypted and are server-only.
- Integration secrets are never returned to the client.
- The repository contains no private credentials.
