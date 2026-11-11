# Project context – PCMarket

## Decisions
- Rails 8.1 + PostgreSQL, Hotwire, Tailwind v4 (tailwindcss-rails), Devise (+ devise-i18n), Pagy 43, pg_search, Stripe (optional).
- Locales: es (default, no URL prefix), en (UK), fr, de, it, pt via optional `(:locale)` route scope. Outside requests use `AppRoutes.helpers` (positional args + optional segment gotcha).
- Admin-managed content (categories, filters, collections) stores translations in `*_translations` jsonb (`Translatable` concern). All static UI text is in `config/locales/<locale>/{app,admin,pages,legal}.yml`. Inline YAML maps must quote values containing commas.
- Listing specs are `jsonb` keyed by `FilterDefinition#key`; filter values OR within a key, AND across keys (`ListingSearch`).
- Money in integer cents (`Monetizable`). Orders: one per seller per checkout; stock reserved with row locks.
- Feature flags and options in `Setting::DEFINITIONS`. Monetisation (commissions, promotions) and Sell-to-us are off by default.
- Countries: only ES enabled; FR/GB/DE/IT/PT ready (regions, VAT, `LegalFacts`) and launched from Admin › Countries.
- Payments: `Payments::Gateway` picks Stripe if `STRIPE_SECRET_KEY` is set, otherwise a simulated gateway.

## Code map
- Models: `app/models` (Listing, Order state machine, Offer, Conversation/Message, Setting, Country, LegalFacts…)
- Services: `app/services` (ListingSearch, Checkout, PcFinder, HomePage, ListingDetails, LegalDocument, stats, payments)
- Controllers: public, `account/`, `seller/`, `orders/`, `admin/`, `api/v1/`
- Seeds: `db/seeds/*.rb` (reference data) + `db/seeds/demo.rb` (demo marketplace, photos cached in tmp/seed_images)
- Tests: `test/` (models, services, integration, API, i18n key sync)

## Open items
- Legal texts must be reviewed by a lawyer; company data in `LegalFacts::COMMON` are placeholders.
- Stripe Connect payouts to sellers are not automated (funds released logically; payout execution pending).
- Production email delivery (SMTP provider) and object storage (S3) still to configure.
- Demo photos from Openverse are not always on-topic; add Unsplash/Pexels/Pixabay keys for better images.
