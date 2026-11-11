# History

## 2026-11-11 – Initial marketplace build
- What: full PCMarket marketplace (catalogue with dynamic filters, listings with moderation, PC Finder, chat + offers, cart/checkout/orders with buyer protection, reviews, saved-search alerts, seller dashboard, store pages, complete admin panel with feature flags and country launch toggles, API v1, SEO, legal pages per country, 6 languages, demo seeds, tests).
- Why: initial product request (Jawa-like marketplace for Spain, ready for FR/GB/DE/IT/PT).
- Files: everything under app/, config/ (routes, locales, initializers), db/migrate, db/seeds, test/, README.md.
- Fixes found while testing: YAML inline maps with commas, numeric-looking YAML keys, optional locale route segment with positional URL args, `allow_browser` blocking older mobile browsers, filter sidebar hidden on desktop, buy box order on mobile, FK on offers referenced by messages.
