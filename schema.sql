-- NEXORA database v0.2 — Supabase/PostgreSQL
create extension if not exists pgcrypto;
create type public.review_state as enum ('draft','pending','approved','published','rejected','retracted');
create type public.verification_state as enum ('confirmed','corroborated','reported','unverified','disputed','undisclosed');

create table if not exists public.projects (
 id uuid primary key default gen_random_uuid(), name text not null, slug text unique not null,
 ticker text, website_url text, description text, logo_url text, lifecycle_stage text,
 project_status text not null default 'discovery', founded_year int, headquarters text,
 last_verified_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.sectors (id uuid primary key default gen_random_uuid(), name text unique not null, slug text unique);
create table if not exists public.project_sectors (project_id uuid references public.projects(id) on delete cascade, sector_id uuid references public.sectors(id) on delete cascade, primary key(project_id,sector_id));
create table if not exists public.ecosystems (id uuid primary key default gen_random_uuid(), name text unique not null, category text, website_url text);
create table if not exists public.project_ecosystems (project_id uuid references public.projects(id) on delete cascade, ecosystem_id uuid references public.ecosystems(id) on delete cascade, primary key(project_id,ecosystem_id));
create table if not exists public.people (id uuid primary key default gen_random_uuid(), full_name text not null, role text, profile_url text, organisation text);
create table if not exists public.project_people (project_id uuid references public.projects(id) on delete cascade, person_id uuid references public.people(id) on delete cascade, relation text, primary key(project_id,person_id,relation));
create table if not exists public.sources (id uuid primary key default gen_random_uuid(), url text not null unique, domain text, source_type text, publisher text, published_at timestamptz, retrieved_at timestamptz not null default now(), content_hash text, reliability_score numeric check(reliability_score between 0 and 1), terms_url text);
create table if not exists public.claims (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, claim_type text not null, claim_text text not null, claim_value jsonb, verification_status public.verification_state not null default 'unverified', confidence numeric check(confidence between 0 and 1), valid_from timestamptz, valid_until timestamptz, review_state public.review_state not null default 'pending', created_at timestamptz not null default now());
create table if not exists public.claim_evidence (claim_id uuid references public.claims(id) on delete cascade, source_id uuid references public.sources(id) on delete cascade, evidence_excerpt text, supports_claim boolean, primary key(claim_id,source_id));
create table if not exists public.milestones (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, title text not null, description text, milestone_type text, announced_date date, expected_date date, actual_date date, status text not null default 'unverified', evidence_claim_id uuid references public.claims(id));
create table if not exists public.funding_rounds (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, round_type text, amount numeric, currency text default 'USD', announced_date date, valuation numeric, valuation_currency text, verification_status public.verification_state not null default 'unverified', source_id uuid references public.sources(id), created_at timestamptz default now());
create table if not exists public.investors (id uuid primary key default gen_random_uuid(), name text not null unique, website_url text, investor_type text);
create table if not exists public.funding_investors (funding_round_id uuid references public.funding_rounds(id) on delete cascade, investor_id uuid references public.investors(id) on delete cascade, lead_investor boolean default false, primary key(funding_round_id,investor_id));
create table if not exists public.campaigns (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, campaign_type text not null check(campaign_type in ('testnet','airdrop','points','quest','grant')), title text not null, description text, official_url text, start_at timestamptz, end_at timestamptz, status text not null default 'unverified', eligibility jsonb, reward_details jsonb, safety_notes text, review_state public.review_state not null default 'pending', created_at timestamptz default now());
create table if not exists public.token_sales (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, sale_type text not null check(sale_type in ('IDO','ICO','IEO','launchpad','private')), launchpad text, start_at timestamptz, end_at timestamptz, token_price numeric, currency text, fdv numeric, allocation numeric, vesting jsonb, participation_url text, status text default 'unverified', source_id uuid references public.sources(id));
create table if not exists public.tokens (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, name text, symbol text, chain text, contract_address text, total_supply numeric, max_supply numeric, circulating_supply numeric, decimals int, coingecko_id text, dexscreener_url text, unique(chain,contract_address));
create table if not exists public.token_unlocks (id uuid primary key default gen_random_uuid(), token_id uuid references public.tokens(id) on delete cascade, unlock_at timestamptz, amount numeric, percent_supply numeric, beneficiary text, unlock_type text, source_id uuid references public.sources(id), verification_status public.verification_state default 'unverified');
create table if not exists public.market_snapshots (id bigserial primary key, token_id uuid references public.tokens(id) on delete cascade, provider text not null, price_usd numeric, market_cap_usd numeric, volume_24h_usd numeric, liquidity_usd numeric, captured_at timestamptz not null default now(), raw jsonb);
create table if not exists public.protocol_snapshots (id bigserial primary key, project_id uuid references public.projects(id) on delete set null, provider text not null, chain text, tvl_usd numeric, fees_24h_usd numeric, revenue_24h_usd numeric, captured_at timestamptz not null default now(), raw jsonb);
create table if not exists public.project_events (id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, event_type text, title text, summary text, occurred_at timestamptz, source_id uuid references public.sources(id), review_state public.review_state not null default 'pending');
create table if not exists public.reports (id uuid primary key default gen_random_uuid(), title text not null, slug text unique not null, summary text, body_md text, report_type text, review_state public.review_state not null default 'draft', published_at timestamptz, created_at timestamptz default now());
create table if not exists public.api_sources (id uuid primary key default gen_random_uuid(), provider text not null unique, base_url text, credential_required boolean default false, enabled boolean default true, terms_url text, last_success_at timestamptz, last_error text, rate_limit_notes text);
create table if not exists public.ingestion_runs (id uuid primary key default gen_random_uuid(), provider text not null, started_at timestamptz default now(), finished_at timestamptz, status text, records_seen int default 0, records_inserted int default 0, error_message text, metadata jsonb);
create table if not exists public.watchlists (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, project_id uuid references public.projects(id) on delete cascade, token_id uuid references public.tokens(id) on delete cascade, created_at timestamptz default now(), check(project_id is not null or token_id is not null));
create table if not exists public.alert_rules (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, event_type text not null, filters jsonb default '{}'::jsonb, enabled boolean default true, created_at timestamptz default now());
create table if not exists public.editorial_actions (id uuid primary key default gen_random_uuid(), record_type text not null, record_id uuid not null, action text not null, reviewer_id uuid references auth.users(id), notes text, created_at timestamptz default now());

create index if not exists idx_projects_stage on public.projects(lifecycle_stage);
create index if not exists idx_claims_project on public.claims(project_id,created_at desc);
create index if not exists idx_events_time on public.project_events(occurred_at desc);
create index if not exists idx_campaigns_dates on public.campaigns(start_at,end_at,status);
create index if not exists idx_funding_date on public.funding_rounds(announced_date desc);
create index if not exists idx_unlock_date on public.token_unlocks(unlock_at);
create index if not exists idx_market_token_time on public.market_snapshots(token_id,captured_at desc);

-- Enable RLS on user-owned tables. Add public read policies only for approved/published records after admin roles are configured.
alter table public.watchlists enable row level security;
alter table public.alert_rules enable row level security;
create policy "users manage own watchlists" on public.watchlists for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "users manage own alert rules" on public.alert_rules for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
-- Do not expose service-role keys in browser code. Configure ingestion using server-side secrets only.
