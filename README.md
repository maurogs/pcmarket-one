# PCMarket

A marketplace for new and second-hand gaming PCs, graphics cards, components, peripherals, laptops, phones, tablets and consoles. Private sellers and professional stores list items; buyers pay through the platform and the money is held until delivery (buyer protection).

Built with Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS v4 and Solid Queue/Cache/Cable.

## Quick start

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed      # reference data + demo marketplace (first run downloads photos, ~5 min)
bin/dev                # http://localhost:3000
```

Demo accounts (password `Password123!`):

| Account | Role |
| --- | --- |
| `admin@pcmarket.example` | Administrator (admin panel at `/admin`) |
| `moderator@pcmarket.example` | Moderator |
| `store1@demo.pcmarket.example` … `store10@` | Professional stores |
| `user1@demo.pcmarket.example` … `user45@` | Private users |

Run the test suite with `bin/rails test`. Translation keys are checked with `bundle exec i18n-tasks missing`.

## Features

- **Catalogue**: category tree, mega menu, full-text search (PostgreSQL tsvector + trigram), dynamic sidebar filters defined in the admin panel (stored as `jsonb` specs with a GIN index), price/condition/location/seller-type filters, sorting by price, performance and value.
- **Listings**: photos (Active Storage, WebP variants), specs per category, multi-unit stock for stores, offers, local pickup or shipping, moderation before publication (re-review on material edits), pause/resume, holiday mode.
- **PC Finder**: quiz (games, resolution, FPS, budget, case, cooling, style) with FPS estimates based on GPU/CPU benchmark scores editable in the admin.
- **Buying**: cart, multi-seller checkout (one order per seller, row-locked stock), seller discount codes, simulated payments by default or Stripe Checkout when configured, order state machine (paid → shipped → delivered → completed, cancellations, disputes), automatic completion after the protection window, reviews.
- **Social**: internal chat with real-time updates (Turbo Streams), offers inside the chat, blocks, reports (DSA notice-and-action), favourites, follows, saved searches with email alerts (instant or daily), in-app notifications.
- **Stores**: logo, banner, tagline, policies, return window, trader information (DSA art. 30), public store page with reviews.
- **Admin panel** (`/admin`): dashboard, moderation queue with templates and bulk actions, users (roles, suspension, verification), orders (status changes, CSV export), categories, filters and options, collections, PC Finder games, countries, settings and feature flags, legal text overrides, reports, reviews, support tickets, newsletter, promotions, buyback requests, conversation access (audited) and audit log.
- **Feature flags** (Settings): commissions, paid promotions and “Sell to us” are implemented but disabled until switched on. Countries other than Spain are ready and can be launched from Admin › Countries.
- **Languages**: Spanish (default), English (UK), French, German, Italian and Portuguese. All UI text lives in `config/locales/<locale>/*.yml`.
- **Legal**: terms, privacy, cookies, legal notice (with LSSI, Impressum, médiation, Livro de Reclamações sections), returns and withdrawal, buyer protection, seller terms, prohibited items, DSA and accessibility pages, generated per country from `LegalFacts` and editable/overridable in the admin. GDPR data export and account deletion, cookie consent banner. **Have all legal texts reviewed by a lawyer before going live.**
- **SEO**: per-page titles and descriptions, canonical URLs, `hreflang` alternates, Open Graph/Twitter tags, JSON-LD (Organization, WebSite search, Product, BreadcrumbList, FAQ), dynamic `sitemap.xml` and `robots.txt`, `noindex` on faceted URLs.
- **API v1** (`/api/v1`, JSON) for future mobile apps: token auth (`POST /api/v1/session` → `Authorization: Bearer <token>`), registration, profile, categories with filters, listings (search/create/update), favourites, conversations and messages, offers, orders, notifications, saved searches. Pagination via `page`/`per_page` and `X-Total-Count` headers; errors localised from `Accept-Language`.

## Configuration

| Variable | Purpose |
| --- | --- |
| `APP_HOST` | Public host for absolute URLs, emails and the sitemap |
| `MAILER_FROM` | Sender address |
| `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` | Enable Stripe Checkout (webhook: `POST /webhooks/stripe`) |
| `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | Enable “Log in with Google” (also toggle it in Settings) |
| `UNSPLASH_ACCESS_KEY`, `PEXELS_API_KEY`, `PIXABAY_API_KEY` | Optional extra photo providers for demo seeds (Openverse is used without a key) |
| `SEED_DEMO=1` | Load demo data in production |

Recurring jobs (`config/recurring.yml`): order maintenance (payment timeouts, auto-completion), offer expiry and the daily saved-search digest.

## Performance notes

Indexed jsonb/array/full-text columns, counter columns, preloaded associations on every listing grid, cached category tree and filters, cached home page for guests, ETags, lazy-loaded WebP images with preprocessed variants, lazily loaded Stimulus controllers and self-hosted fonts.

## Image credits

Demo photos come from Openverse (Creative Commons). Attribution is stored per image and shown at `/p/credits`.
