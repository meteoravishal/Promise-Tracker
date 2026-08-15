# Promise Tracker V3.1 Beta

Promise Tracker turns commitments into trackable promises: what you promised, what others promised you, due dates, money attached to commitments, AI-assisted extraction, follow-ups, and reminders.

## Live beta

Production URL: https://promise-tracker-self.vercel.app

The current public beta includes:

- Supabase email/password authentication
- Private per-user promise data with Row Level Security
- Create, edit, complete, reopen and delete promises
- Due-today and overdue tracking
- `I promised` vs `Promised to me`
- Monetary commitments in INR, USD, EUR and GBP
- AI Inbox extraction with a built-in smart fallback
- Responsive Vercel-hosted UI and Node serverless API

The database schema is in `docs/supabase-schema.sql`. Gmail and WhatsApp credential tables are intentionally inaccessible to browser users.

## Production integrations not enabled yet

The architecture can be extended with private Vercel environment variables for OpenAI, Gmail, WhatsApp Business, scheduled reminders and Stripe billing. Do not commit server secrets to this repository.

## Security

- User-owned tables are protected by ownership-based Supabase RLS policies.
- Browser users receive only the database permissions needed for the beta.
- Gmail and WhatsApp integration credential tables have no authenticated-user policies.
- No private credentials are stored in the repository.

## Deployment

The current production build was deployed to Vercel after verifying:

- `/` returns HTTP 200
- `/api/config` returns the beta configuration
- `/api/promises` returns HTTP 401 when no user is authenticated
