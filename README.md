# Promise Tracker V4 Beta

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
- AI Inbox extraction with real OpenAI support plus a smart fallback
- Hindi, Hinglish and English promise extraction
- Gmail OAuth integration and review queue
- Daily automatic Gmail scan on Vercel Hobby plus manual Scan Now
- Responsive Vercel-hosted UI and Node serverless API

The database schema is in `docs/supabase-schema.sql`. Gmail and WhatsApp credential tables are intentionally inaccessible to browser users.

## Security

- User-owned tables are protected by ownership-based Supabase RLS policies.
- Browser users receive only the database permissions needed for the beta.
- Gmail integration refresh tokens are encrypted and stored server-side.
- Integration secrets remain in Vercel environment variables and are not committed.

## Deployment

Vercel is connected directly to this GitHub repository. Production deployments are built from the complete repository so frontend, auth, AI and Gmail functions stay in sync.
