# Idempotent seeds. Reference data (countries, filters, categories, games,
# collections) is safe to run in any environment; demo marketplace content
# (users, listings, orders) only runs outside production unless SEED_DEMO=1.
require_relative "seeds/support"

%w[countries filters categories games collections].each do |file|
  SeedSupport.step(file) { load Rails.root.join("db/seeds/#{file}.rb") }
end

if !Rails.env.production? || ENV["SEED_DEMO"] == "1"
  SeedSupport.step("demo") { load Rails.root.join("db/seeds/demo.rb") }
end

Rails.cache.clear
puts "Seeds finished."
