# Demo marketplace: stores, private sellers, listings with real photos, orders,
# reviews, favourites, follows and conversations. Re-running resets demo data.
require "faker"
require_relative "images"
require_relative "catalog"

Faker::Config.locale = :es
Faker::Config.random = Random.new(42)
srand(42)
ActiveJob::Base.queue_adapter = :inline
ActionMailer::Base.perform_deliveries = false
Listing.skip_counter_refresh = true

SPAIN = Country.find_by!(code: "ES")
SPAIN_REGIONS = SPAIN.regions.to_a
CITY_BY_REGION = { "Madrid" => "Madrid", "Barcelona" => "Barcelona", "Valencia" => "Valencia", "Sevilla" => "Sevilla", "Málaga" => "Málaga",
                   "Bizkaia" => "Bilbao", "Zaragoza" => "Zaragoza", "A Coruña" => "A Coruña", "Murcia" => "Murcia", "Asturias" => "Oviedo",
                   "Alicante" => "Alicante", "Granada" => "Granada", "Valladolid" => "Valladolid", "Illes Balears" => "Palma", "Navarra" => "Pamplona" }.freeze
POPULAR_REGIONS = SPAIN_REGIONS.select { |r| CITY_BY_REGION.key?(r.name) }
OPTIONS = FilterDefinition.includes(:filter_options).index_by(&:key).transform_values { |d| d.filter_options.index_by(&:value) }

def opt(key, value) = OPTIONS.dig(key, value)
def pick_region = (rand < 0.8 ? POPULAR_REGIONS : SPAIN_REGIONS).sample
def price_between(min, max) = (rand(min.to_f..max.to_f) / 5).round * 5 - [0, 0.01, 0.1].sample

# --- reset previous demo data --------------------------------------------------
demo_users = User.where("email LIKE ?", "%@demo.pcmarket.example")
Order.where(buyer: demo_users).or(Order.where(seller: demo_users)).find_each(&:destroy)
Listing.where(user: demo_users).find_each(&:destroy)
demo_users.find_each(&:destroy)
ImageCredit.delete_all

# --- photos --------------------------------------------------------------------
queries = (DEMO_CATALOG.values.map(&:first) + DEMO_IMAGES.values.flatten + ["store logo technology"]).uniq
puts "\n  downloading photos for #{queries.size} queries (cached in tmp/seed_images)"
SeedImages.prefetch(queries)
PHOTOS = queries.index_with { |q| SeedImages.blobs_for(q) }
def photos_for(category_slug)
  queries = DEMO_IMAGES[category_slug] || [DEMO_CATALOG.dig(category_slug, 0)]
  pool = queries.compact.flat_map { |q| PHOTOS[q] }.compact
  pool = PHOTOS.values.flatten if pool.empty?
  pool.sample(rand(2..4))
end

# --- users ---------------------------------------------------------------------
def logo_png(text, color)
  file = Rails.root.join("tmp/seed_images/logo-#{text.parameterize}.png")
  unless File.exist?(file)
    MiniMagick::Tool::Convert.new do |convert|
      convert.size "256x256"
      convert << "xc:#{color}"
      convert.gravity "center"
      convert.font Rails.root.join("app/assets/fonts/space-grotesk-latin-wght-normal.woff2").to_s
      convert.fill "white"
      convert.pointsize 92
      convert.annotate "+0+0", text
      convert << file.to_s
    end
  end
  file
rescue StandardError
  nil
end

def create_user(email:, username:, **attributes)
  user = User.new(email: email, username: username, password: "Password123!", terms_accepted_at: 60.days.ago, country: SPAIN, locale: "es", **attributes)
  user.skip_confirmation!
  user.save!
  user
end

admin = User.find_by(email: "admin@pcmarket.example") || create_user(email: "admin@pcmarket.example", username: "admin", role: :admin, first_name: "Admin", last_name: "PCMarket")
admin.update!(role: :admin)
User.find_by(email: "moderator@pcmarket.example") || create_user(email: "moderator@pcmarket.example", username: "moderador", role: :moderator, first_name: "Marta", last_name: "Moderadora")

STORES = [
  ["Tormenta PCs", "Gaming PCs montados y testeados en Madrid", "#4f46e5"], ["Byte Barcelona", "Componentes revisados con garantía", "#0891b2"],
  ["Silicio Sevilla", "Hardware de segunda vida", "#ea580c"], ["RGB Factory", "Builds con mucha luz y personalidad", "#db2777"],
  ["Retro Rincón", "Consolas y videojuegos retro", "#65a30d"], ["Valencia Hardware", "Tienda de informática desde 2009", "#0f766e"],
  ["NeoBuilds", "Workstations para creadores e IA local", "#7c3aed"], ["Píxel Norte", "Periféricos y monitores gaming", "#2563eb"],
  ["Overclock Bilbao", "Rendimiento máximo, precios justos", "#dc2626"], ["Málaga Gaming Lab", "PCs a medida en la Costa del Sol", "#d97706"]
].freeze

stores = STORES.each_with_index.map do |(name, tagline, color), index|
  region = POPULAR_REGIONS[index % POPULAR_REGIONS.size]
  user = create_user(email: "store#{index + 1}@demo.pcmarket.example", username: name.parameterize(separator: "_").first(28), store_name: name, store_tagline: tagline,
                     seller_type: :business, legal_name: "#{name} S.L.", tax_id: "B#{rand(10_000_000..99_999_999)}", business_address: "#{Faker::Address.street_address}, #{CITY_BY_REGION[region.name]}",
                     trader_certified_at: 50.days.ago, verified_at: (index < 7 ? 40.days.ago : nil), region: region, city: CITY_BY_REGION[region.name],
                     bio: "#{tagline}. Envíos en 24/48 h a toda España. Todos los equipos se prueban con benchmarks antes de enviarse.",
                     return_window_days: [14, 30].sample, store_policies: "Garantía de 6 meses en equipos completos. Embalaje reforzado con espuma.", created_at: rand(200..900).days.ago)
  if (logo = logo_png(name.split.map(&:first).join.first(3), color))
    user.store_logo.attach(io: File.open(logo), filename: "logo.png", content_type: "image/png")
  end
  user
end

individuals = 45.times.map do |index|
  first = Faker::Name.first_name
  last = Faker::Name.last_name
  region = pick_region
  create_user(email: "user#{index + 1}@demo.pcmarket.example", username: "#{I18n.transliterate(first).downcase.gsub(/[^a-z]/, '')}_#{index + 1}#{rand(10..99)}",
              first_name: first, last_name: last, region: region, city: CITY_BY_REGION[region.name] || region.name, created_at: rand(5..500).days.ago,
              bio: (rand < 0.4 ? "Aficionado al hardware. Vendo lo que ya no uso, todo probado." : nil), verified_at: (rand < 0.15 ? 20.days.ago : nil))
end
sellers = stores * 3 + individuals
buyers = individuals

# --- listings ------------------------------------------------------------------
def status_for(index)
  case index % 40
  when 0, 1 then :pending_review
  when 2 then :rejected
  when 3 then :draft
  when 4, 5, 6 then :sold
  when 7 then :paused
  else :published
  end
end

DESCRIPTIONS = [
  "Vendo por cambio de equipo. Funciona perfectamente, sin golpes ni arañazos. Se puede probar en mano si eres de la zona.",
  "Producto revisado y limpiado. Incluye caja original y todos los accesorios. Envío bien protegido con número de seguimiento.",
  "Usado muy poco, prácticamente como nuevo. Factura de compra disponible. Cualquier duda, pregúntame por el chat.",
  "Equipo probado con benchmarks y pruebas de estrés de varias horas. Temperaturas excelentes. Sin overclock.",
  "Lo vendo porque me he pasado a un modelo superior. Siempre en casa sin fumadores ni mascotas."
].freeze

def build_listing(seller, category, title:, price:, specs:, brand:, index:, condition: nil)
  status = status_for(index)
  published_at = rand(1..60).days.ago - rand(0..23).hours
  on_sale = rand < 0.18
  region = seller.region || pick_region
  listing = Listing.new(
    user: seller, category: category, country: SPAIN, region: region, city: seller.city.presence || CITY_BY_REGION[region.name] || region.name,
    postal_code: format("%05d", rand(1_000..52_999)), title: title.first(Listing::MAX_TITLE), brand: brand,
    description: "#{DESCRIPTIONS.sample}\n\n#{specs.keys.first(6).filter_map { |k| (o = opt(k, specs[k])) && "• #{FilterDefinition.cached_by_key[k]&.name('es')}: #{o.label('es')}" }.join("\n")}",
    price: price, original_price: on_sale ? (price * rand(1.08..1.25)).round : nil,
    condition: condition || (seller.business? ? %i[brand_new open_box like_new good].sample : Listing.conditions.keys.sample(random: Random.new(index))),
    status: status, specs: specs, quantity: seller.business? && rand < 0.3 ? rand(2..8) : 1,
    shipping_available: true, shipping_price: [0, 0, 4.95, 6.99, 9.95, 14.95].sample, local_pickup: rand < 0.4, handling_days: [1, 2, 3].sample,
    allow_offers: rand < 0.75, featured: rand < 0.06, tags: [],
    submitted_at: published_at - 2.hours, published_at: %i[published sold paused].include?(status) ? published_at : nil,
    rejection_reason: status == :rejected ? "Las fotos no muestran el producto real. Sube fotos propias, por favor." : nil,
    views_count: rand(5..900), created_at: published_at - 3.hours, updated_at: published_at
  )
  listing.condition = :for_parts if rand < 0.02
  photos_for(category.slug).each { |blob| listing.photos.attach(blob) }
  listing
end

listings = []
index = 0
gaming = Category.find_by!(slug: "gaming-pcs")
cpu_options = OPTIONS["cpu_model"].values.select { |o| o.score.positive? && !o.value.start_with?("apple", "snapdragon", "tr_", "xeon") }
gpu_options = OPTIONS["gpu_model"].values.select { |o| o.score.positive? && !o.value.start_with?("rtx_a", "rtx_6000") }
TAGS = OPTIONS["seller_tags"].keys

140.times do
  cpu = cpu_options.sample
  gpu = gpu_options.select { |g| (g.score - cpu.score * 1.2).abs < 15_000 }.sample || gpu_options.sample
  ram = %w[16gb 32gb 32gb 64gb].sample
  ram_type = cpu.score > 14_000 ? "ddr5" : "ddr4"
  storage = %w[512gb 1tb 1tb 2tb 4tb].sample
  color = %w[black black white white multicolor pink].sample
  case_brand = %w[lian_li nzxt fractal_design corsair hyte montech mars_gaming phanteks].sample
  cooler = gpu.score > 20_000 ? %w[aio aio custom_loop air].sample : %w[air air aio].sample
  base = 250 + gpu.score * 0.042 + cpu.score * 0.018 + (ram == "64gb" ? 120 : 0) + (storage == "4tb" ? 150 : 0)
  price = price_between(base * 0.88, base * 1.12)
  name = ["Gaming PC", "PC Gaming", "PC Gamer", "Torre gaming", "Equipo gaming"].sample
  prefix = ["", "", "\"#{%w[Nébula Tormenta Glaciar Fénix Aurora Vortex Sakura Titán Eclipse Cobalto].sample}\" "].sample
  title = "#{prefix}#{name} #{cpu.label('es').sub(/^(Intel Core |AMD )/, '')} | #{gpu.label('es').sub(/^(GeForce |Radeon )/, '')} | #{ram.upcase} #{ram_type.upcase} | #{storage.upcase} NVMe"
  specs = { "cpu_brand" => cpu.value.start_with?("r", "tr") ? "amd" : "intel", "cpu_model" => cpu.value, "cpu_cores" => %w[c6 c8 c8 c12 c16].sample,
            "cpu_cooler_type" => cooler, "gpu_chipset" => gpu.value.start_with?("rx") ? "amd" : (gpu.value.start_with?("arc") ? "intel" : "nvidia"),
            "gpu_model" => gpu.value, "gpu_memory" => %w[8gb 12gb 16gb].sample, "memory_capacity" => ram, "memory_type" => ram_type,
            "storage_capacity" => storage, "storage_interface" => "nvme_ssd", "motherboard_form_factor" => %w[atx atx matx itx].sample,
            "case_brand" => case_brand, "case_form_factor" => color == "pink" ? "mid_tower" : %w[mid_tower mid_tower sff full_tower].sample,
            "case_color" => color, "psu_wattage" => gpu.score > 25_000 ? "1000w" : %w[650w 750w 850w].sample, "lighting" => %w[argb argb static none].sample,
            "warranty" => %w[seller none manufacturer].sample }
  seller = (stores * 2 + individuals.first(15)).sample
  listing = build_listing(seller, gaming, title: title, price: price, specs: specs, brand: nil, index: index)
  listing.tags = (TAGS.sample(rand(1..3)) + (color == "white" ? ["whiteout"] : []) + (specs["lighting"] == "argb" ? ["rgb"] : [])).uniq
  listing.labels = [price < 800 ? "value_pc" : (price < 1600 ? "midrange_pc" : "pro_pc")] + (rand < 0.05 ? ["rare"] : [])
  listings << listing
  index += 1
end

gpus = Category.find_by!(slug: "gpus")
GPU_BRANDS = ["ASUS TUF Gaming", "ASUS ROG Strix", "MSI Gaming X Trio", "MSI Ventus 2X", "Gigabyte Gaming OC", "Gigabyte Eagle", "Zotac Twin Edge", "Sapphire Pulse", "Sapphire Nitro+", "PowerColor Hellhound", "XFX Speedster", "Founders Edition"].freeze
90.times do
  gpu = gpu_options.sample
  maker = gpu.value.start_with?("rx") ? GPU_BRANDS.grep(/Sapphire|PowerColor|XFX|ASUS|Gigabyte/).sample : GPU_BRANDS.reject { |b| b =~ /Sapphire|PowerColor|XFX/ }.sample
  memory = gpu.label("es")[/(\d+)GB/, 1] || { "rtx_3060" => 12, "rtx_4060" => 8, "rtx_4070" => 12, "rtx_4090" => 24, "rtx_5090" => 32, "rx_7900xtx" => 24, "rx_9070xt" => 16 }.fetch(gpu.value, [8, 12, 16].sample)
  price = price_between(gpu.score * 0.026 + 30, gpu.score * 0.034 + 40)
  title = "#{gpu.label('es')} #{maker} #{memory}GB"
  specs = { "gpu_chipset" => gpu.value.start_with?("rx") ? "amd" : (gpu.value.start_with?("arc") ? "intel" : "nvidia"), "gpu_model" => gpu.value,
            "gpu_memory" => "#{memory}gb", "lighting" => %w[argb none static].sample, "includes_box" => %w[yes no].sample, "warranty" => %w[manufacturer seller none].sample }
  specs.delete("gpu_memory") unless opt("gpu_memory", specs["gpu_memory"])
  listing = build_listing(sellers.sample, gpus, title: title, price: price, specs: specs, brand: maker.split.first, index: index)
  listing.labels = [price < 300 ? "value_gpu" : (price < 700 ? "midrange_gpu" : "pro_gpu")]
  listings << listing
  index += 1
end

LAPTOPS = [
  ["gaming-laptops", "ASUS ROG Strix G16 i7-13650HX RTX 4060", 950, 1250, "i7_13700k", "rtx_4060", "asus", "16"], ["gaming-laptops", "Lenovo Legion Pro 5 Ryzen 7 RTX 4070", 1150, 1450, "r7_7700x", "rtx_4070", "lenovo", "16"],
  ["gaming-laptops", "MSI Katana 15 i5 RTX 3050", 550, 700, "i5_12400f", "other", "msi", "15"], ["gaming-laptops", "Razer Blade 14 RTX 4070", 1500, 1900, "r9_7950x", "rtx_4070", "razer", "14"],
  ["everyday-laptops", "Dell XPS 13 Plus i7 16GB", 750, 950, "i7_12700k", "other", "dell", "13"], ["everyday-laptops", "Lenovo ThinkPad X1 Carbon Gen 11", 900, 1150, "i7_13700k", "other", "lenovo", "14"],
  ["everyday-laptops", "HP Pavilion 15 Ryzen 5 16GB", 380, 500, "r5_5600", "other", "hp", "15"], ["macbooks", "MacBook Air M2 13\" 8/256", 680, 820, "apple_m2", "other", "apple", "13"],
  ["macbooks", "MacBook Pro 14\" M3 18/512", 1400, 1700, "apple_m3", "other", "apple", "14"], ["macbooks", "MacBook Pro 16\" M4 Pro 24/1TB", 2300, 2700, "apple_m4_pro", "other", "apple", "16"]
].freeze
35.times do
  slug, title, min, max, cpu, gpu, brand, screen = LAPTOPS.sample
  specs = { "laptop_brand" => brand, "cpu_model" => cpu, "gpu_model" => gpu, "memory_capacity" => %w[16gb 16gb 32gb].sample, "storage_capacity" => %w[512gb 1tb].sample,
            "laptop_screen" => screen, "keyboard_layout" => %w[es es es uk us].sample, "battery_health" => %w[b100 b90 b80].sample }
  listings << build_listing(sellers.sample, Category.find_by!(slug: slug), title: title, price: price_between(min, max), specs: specs, brand: brand.capitalize, index: index)
  index += 1
end

WORKSTATIONS = [["creator-pcs", "Workstation Ryzen 9 7950X | RTX 4080 Super | 128GB | 4TB", 3200, 3800, "r9_7950x", "rtx_4080s"],
                ["ai-rigs", "Rig IA local 2x RTX 3090 24GB | Threadripper | 256GB", 4200, 5200, "tr_7970x", "rtx_3090"],
                ["creator-pcs", "Estación de edición i9-14900K | RTX 4070 Ti Super | 64GB", 2300, 2800, "i9_14900k", "rtx_4070tis"]].freeze
12.times do
  slug, title, min, max, cpu, gpu = WORKSTATIONS.sample
  specs = { "cpu_model" => cpu, "gpu_model" => gpu, "memory_capacity" => "128gb", "storage_capacity" => "4tb", "storage_interface" => "nvme_ssd" }
  listings << build_listing(stores.sample, Category.find_by!(slug: slug), title: title, price: price_between(min, max), specs: specs, brand: nil, index: index)
  index += 1
end

DEMO_CATALOG.each do |slug, (_query, products)|
  category = Category.find_by!(slug: slug)
  (products.size * 3).times do
    title, min, max, specs, brand = products.sample
    listings << build_listing(sellers.sample, category, title: title, price: price_between(min, max), specs: specs, brand: brand, index: index)
    index += 1
  end
end

saved = listings.count do |listing|
  listing.save!
rescue ActiveRecord::RecordInvalid => e
  warn "  skipped #{listing.title}: #{e.record.errors.full_messages.to_sentence}"
  false
end
puts "\n  #{saved} listings created"

# --- orders, reviews, social ----------------------------------------------------
REVIEW_TEXTS = [
  "Todo perfecto, el equipo llegó muy bien embalado y funciona de maravilla. Vendedor de 10.",
  "Muy buena comunicación, respondió todas mis dudas antes de comprar. Envío rapidísimo.",
  "Tal y como se describía. Repetiría sin dudarlo.", "Algún arañazo que no se veía en las fotos, pero el vendedor me hizo un descuento. Correcto.",
  "Primera compra en la plataforma y genial, el pago retenido hasta recibirlo da mucha tranquilidad.",
  "Gráfica en perfecto estado, temperaturas de lujo. Gracias!"
].freeze
address = lambda do |buyer|
  { "full_name" => buyer.full_name, "line1" => Faker::Address.street_address, "city" => buyer.city || "Madrid", "region" => buyer.region&.name,
    "postal_code" => format("%05d", rand(1_000..52_999)), "country_code" => "ES", "phone" => "+34 6#{rand(10_000_000..99_999_999)}" }
end

saved_listings = Listing.where(user: User.where("email LIKE ?", "%@demo.pcmarket.example"))
saved_listings.sold.includes(:user).find_each do |listing|
  buyer = (buyers - [listing.user]).sample
  created = listing.published_at + rand(1..5).days
  order = Order.create!(buyer: buyer, seller: listing.user, checkout_reference: SecureRandom.uuid, email: buyer.email, status: :completed,
                        subtotal_cents: listing.price_cents, shipping_cents: listing.shipping_price_cents, total_cents: listing.price_cents + listing.shipping_price_cents,
                        shipping_address: address.call(buyer), payment_provider: "simulated", payment_reference: "SIM-#{SecureRandom.hex(4)}",
                        paid_at: created, shipped_at: created + 1.day, delivered_at: created + 3.days, completed_at: created + 5.days,
                        carrier: "Correos", tracking_number: "PQ#{rand(10**9..10**10)}ES", created_at: created)
  order.items.create!(listing: listing, title: listing.title, unit_price_cents: listing.price_cents, quantity: 1)
  %w[pending_payment paid shipped delivered completed].each_cons(2) { |from, to| order.events.create!(from_status: from, to_status: to, created_at: created) }
  listing.update_columns(quantity: 0, sold_count: 1, updated_at: order.completed_at)
  next if rand < 0.2

  review = Review.new(order: order, reviewer: buyer, seller: listing.user, rating: [5, 5, 5, 4, 4, 3].sample, body: REVIEW_TEXTS.sample, created_at: order.completed_at + 1.day)
  review.save!
end

# A few orders in progress so dashboards show every state.
saved_listings.published.where(quantity: 2..).limit(8).each_with_index do |listing, i|
  buyer = (buyers - [listing.user]).sample
  status = %i[paid shipped delivered disputed paid shipped delivered paid][i]
  order = Order.create!(buyer: buyer, seller: listing.user, checkout_reference: SecureRandom.uuid, email: buyer.email, status: status,
                        subtotal_cents: listing.price_cents, shipping_cents: listing.shipping_price_cents, total_cents: listing.price_cents + listing.shipping_price_cents,
                        shipping_address: address.call(buyer), payment_provider: "simulated", paid_at: 2.days.ago,
                        shipped_at: (status == :paid ? nil : 1.day.ago), delivered_at: (%i[delivered disputed].include?(status) ? 2.hours.ago : nil),
                        protection_ends_at: (status == :delivered ? 2.days.from_now : nil), tracking_number: (status == :paid ? nil : "PQ#{rand(10**9..10**10)}ES"),
                        carrier: (status == :paid ? nil : "SEUR"), dispute_reason: (status == :disputed ? "La gráfica hace coil whine muy fuerte que no se mencionaba." : nil))
  order.items.create!(listing: listing, title: listing.title, unit_price_cents: listing.price_cents, quantity: 1)
  order.events.create!(to_status: status.to_s)
  listing.update_columns(quantity: listing.quantity - 1, sold_count: listing.sold_count + 1)
end

User.where(id: (stores + individuals).map(&:id)).find_each(&:refresh_reputation!)
User.where(id: stores.map(&:id)).find_each { |store| store.update_column(:sales_count, store.sales.completed.count + rand(10..120)) }

visible = saved_listings.published.to_a
buyers.each do |buyer|
  visible.sample(rand(0..12)).each { |listing| Favorite.find_or_create_by!(user: buyer, listing: listing) unless listing.user_id == buyer.id }
  stores.sample(rand(0..3)).each { |store| Follow.find_or_create_by!(follower: buyer, seller: store) }
end
buyers.first(10).each do |buyer|
  SavedSearch.create!(user: buyer, name: "RTX 4070 por menos de 600 €", query: { "category" => "gpus", "f" => { "gpu_model" => %w[rtx_4070 rtx_4070s] }, "max_price" => "600" })
end

QUESTIONS = ["¡Hola! ¿Sigue disponible?", "¿Tiene algún defecto que no se vea en las fotos?", "¿Harías envío a Canarias?", "¿Puedo pasar a verlo este fin de semana?"].freeze
ANSWERS = ["¡Hola! Sí, sigue disponible.", "Ninguno, está como nuevo. Te puedo mandar un vídeo funcionando.", "Sí, sin problema. El envío sale unos euros más caro.", "Claro, escríbeme y quedamos."].freeze
visible.sample(25).each do |listing|
  buyer = (buyers - [listing.user]).sample
  conversation = Conversation.create!(listing: listing, buyer: buyer, seller: listing.user)
  q = rand(QUESTIONS.size)
  conversation.post!(sender: buyer, body: QUESTIONS[q])
  conversation.post!(sender: listing.user, body: ANSWERS[q])
  next unless listing.allow_offers && rand < 0.5

  offer = Offer.create!(listing: listing, buyer: buyer, conversation: conversation, amount_cents: (listing.price_cents * 0.88).round(-2))
  conversation.post!(sender: buyer, kind: :offer, offer: offer, body: "¿Aceptarías esta oferta? Pago hoy mismo.")
end

Listing.skip_counter_refresh = false
User.where(id: (stores + individuals).map(&:id)).find_each(&:refresh_listings_count!)
Category.find_each { |category| category.update_column(:listings_count, Listing.visible.where(category_id: category.descendant_ids).count) }
puts "  demo accounts: admin@pcmarket.example / Password123! · moderator@pcmarket.example · store1@demo.pcmarket.example · user1@demo.pcmarket.example"
