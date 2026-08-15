create extension if not exists pgcrypto;
create schema if not exists private;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  timezone text not null default 'Asia/Kolkata',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.promises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person text not null,
  text text not null,
  direction text not null check (direction in ('mine','theirs')),
  due_date date not null,
  due_time time,
  source text not null default 'Manual',
  status text not null default 'open' check (status in ('open','done')),
  amount numeric(14,2) not null default 0 check (amount >= 0),
  currency text not null default 'INR' check (currency in ('INR','USD','EUR','GBP')),
  notes text not null default '',
  confidence integer not null default 100 check (confidence between 0 and 100),
  source_message_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists promises_user_due_idx on public.promises(user_id,due_date,status);

create table if not exists public.detections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source text not null default 'Gmail',
  source_message_id text not null,
  source_thread_id text,
  subject text,
  from_name text,
  snippet text,
  person text,
  text text not null,
  direction text not null default 'theirs' check (direction in ('mine','theirs')),
  due_date date,
  due_time time,
  amount numeric(14,2) not null default 0 check (amount >= 0),
  currency text not null default 'INR' check (currency in ('INR','USD','EUR','GBP')),
  confidence integer not null default 0 check (confidence between 0 and 100),
  status text not null default 'pending' check (status in ('pending','accepted','ignored')),
  detected_at timestamptz not null default now(),
  reviewed_at timestamptz,
  unique(user_id,source,source_message_id)
);
create index if not exists detections_user_status_idx on public.detections(user_id,status,detected_at desc);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  promise_id uuid references public.promises(id) on delete cascade,
  kind text not null,
  dedupe_key text not null,
  title text not null,
  body text not null,
  scheduled_for timestamptz,
  sent_at timestamptz,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  unique(user_id,dedupe_key)
);
create index if not exists notifications_user_idx on public.notifications(user_id,created_at desc);
create index if not exists notifications_promise_idx on public.notifications(promise_id);

create table if not exists public.gmail_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  gmail_email text,
  refresh_token_encrypted text not null,
  scan_enabled boolean not null default true,
  last_scan_at timestamptz,
  last_scan_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.whatsapp_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  phone_number_id text not null unique,
  display_phone_number text,
  verified_name text,
  access_token_encrypted text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  stripe_price_id text,
  status text not null default 'inactive',
  plan text not null default 'free' check (plan in ('free','pro','business','beta')),
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.promises enable row level security;
alter table public.detections enable row level security;
alter table public.notifications enable row level security;
alter table public.gmail_connections enable row level security;
alter table public.whatsapp_connections enable row level security;
alter table public.subscriptions enable row level security;

revoke all on table public.profiles, public.promises, public.detections, public.notifications,
  public.gmail_connections, public.whatsapp_connections, public.subscriptions from anon, authenticated;

grant select, update on table public.profiles to authenticated;
grant select, insert, update, delete on table public.promises to authenticated;
grant select, update on table public.detections to authenticated;
grant select, update on table public.notifications to authenticated;
grant select on table public.subscriptions to authenticated;

grant select, insert, update, delete on table public.profiles, public.promises, public.detections,
  public.notifications, public.gmail_connections, public.whatsapp_connections, public.subscriptions to service_role;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists promises_select_own on public.promises;
create policy promises_select_own on public.promises for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
drop policy if exists promises_insert_own on public.promises;
create policy promises_insert_own on public.promises for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
drop policy if exists promises_update_own on public.promises;
create policy promises_update_own on public.promises for update to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
drop policy if exists promises_delete_own on public.promises;
create policy promises_delete_own on public.promises for delete to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

drop policy if exists detections_select_own on public.detections;
create policy detections_select_own on public.detections for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
drop policy if exists detections_update_own on public.detections;
create policy detections_update_own on public.detections for update to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists notifications_select_own on public.notifications;
create policy notifications_select_own on public.notifications for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
drop policy if exists notifications_update_own on public.notifications;
create policy notifications_update_own on public.notifications for update to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists subscriptions_select_own on public.subscriptions;
create policy subscriptions_select_own on public.subscriptions for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

-- No authenticated-user policies are intentionally created for gmail_connections or
-- whatsapp_connections. Those tables contain encrypted integration credentials and are
-- accessed only by trusted server-side code with a Supabase secret key.

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles(user_id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name'))
  on conflict (user_id) do nothing;
  insert into public.subscriptions(user_id, plan, status)
  values (new.id, 'free', 'inactive')
  on conflict (user_id) do nothing;
  return new;
end;
$$;
revoke all on function private.handle_new_user() from public, anon, authenticated;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function private.handle_new_user();
