# NEXORA — Crypto Intelligence Platform (early access build 0.2)

A free-first, research-led crypto intelligence web application. The supplied `index.html` is a static frontend that can be previewed immediately. It includes project discovery, candidate profiles, local watchlists, research desk, methodology, funding structure, lifecycle tracking, markets/DeFi, testnet, airdrop, token sale, token intelligence, research/report, alerts and admin/source pages.

## Live integrations included
- DefiLlama public endpoint: `https://api.llama.fi/protocols` (protocol catalogue and TVL).
- DEX Screener public endpoint: `https://api.dexscreener.com/latest/dex/search` (pair search, price, liquidity and volume).

These are browser-side public integrations for the initial static preview. API availability, CORS, rate limits and provider terms may change. Market data is not independently verified research. Other sections are structured product modules, not falsely represented as live populated data.

## Database
`schema.sql` is a Supabase/PostgreSQL starting schema covering projects, sectors, ecosystems, people, sources, claims/evidence, milestones, funding, investors, campaigns, token sales, tokens, unlocks, market snapshots, protocol snapshots, events, reports, API sources, ingestion runs, watchlists and alerts.

It is a foundation, not a completed production backend. Before public production use, configure admin roles, public-read policies for approved content, RLS for every table, migrations, audit logging, backups and ingestion workers. Never put a Supabase service-role key or provider secret in frontend JavaScript.

## Preview locally
Open `index.html` in a modern browser, or run a local static server:

```bash
python3 -m http.server 8000
```

Then open `http://localhost:8000`.

## Publish a free preview
1. Create a GitHub account and a new repository named `nexora`.
2. Upload `index.html` (and keep `schema.sql`, `README.md` in the repository).
3. In Cloudflare, open Workers & Pages → Create → Pages → Connect to Git.
4. Select the repository. Framework preset: None. Build command: leave empty. Build output directory: `/` (or `.` if prompted).
5. Deploy. Cloudflare will provide a `*.pages.dev` address. No custom domain is required for this first preview.

## Connect the database
1. Create a Supabase project on the Free plan.
2. Open SQL Editor and run `schema.sql`.
3. Copy the Project URL and anon/publishable key into a future application configuration. The static build does not yet connect to Supabase.
4. Keep service-role keys only in server-side environment variables.

## API integration roadmap
| Source | Role | Credential / next step |
|---|---|---|
| DefiLlama | TVL, protocols, chains, yields | Public endpoints used in frontend preview; confirm endpoint-specific terms |
| DEX Screener | DEX pairs, liquidity, volume | Public endpoint used in frontend preview; obey published rate limits |
| RootData | Project discovery, funding, investors, calendars | Create API account; free tier currently advertises 1,000 monthly credits; store key server-side |
| CoinGecko | Prices, market cap, token metadata | Create Demo API key; server-side integration recommended |
| GitHub | Repositories, releases, developer activity | Public REST API; token recommended for higher rate limits |
| Etherscan | Contract and chain explorer data | API key and supported-chain plan vary |
| Official project sources | Testnets, airdrops, token sales, milestones | Curated source registry and reviewed ingestion; no universal reliable free API exists |

## What is not yet production-ready
- Supabase connection, authentication, admin roles and database-backed forms.
- Scheduled ingestion, persistent historical snapshots, retries and alert delivery.
- RootData/CoinGecko/GitHub/Etherscan credentialed connectors.
- A verified global testnet/airdrop/IDO/ICO dataset. Candidate records must be collected and checked; the prototype intentionally does not fabricate active opportunities.
- Security review, privacy policy, terms, monitoring, backups and domain/trademark clearance.

## Important
NEXORA is a provisional working brand, not trademark-cleared. The project records in the starter UI are research candidates, not investment recommendations. This product is not financial advice.
