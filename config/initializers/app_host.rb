# Absolute URLs for mailers, API image links and the sitemap.
host = ENV.fetch("APP_HOST") { Rails.env.production? ? "pcmarket.example" : "localhost:3000" }
protocol = Rails.env.production? ? "https" : "http"

Rails.application.routes.default_url_options = { host: host, protocol: protocol }
Rails.application.config.action_mailer.default_url_options = { host: host, protocol: protocol }
