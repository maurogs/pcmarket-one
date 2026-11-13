# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_11_000011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name", null: false
    t.string "company"
    t.string "line1", null: false
    t.string "line2"
    t.string "city", null: false
    t.string "region"
    t.string "postal_code", null: false
    t.string "country_code", default: "ES", null: false
    t.string "phone"
    t.boolean "default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.string "name"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "action", null: false
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.jsonb "details", default: {}, null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
  end

  create_table "blocks", force: :cascade do |t|
    t.bigint "blocker_id", null: false
    t.bigint "blocked_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_id"], name: "index_blocks_on_blocked_id"
    t.index ["blocker_id", "blocked_id"], name: "index_blocks_on_blocker_id_and_blocked_id", unique: true
    t.index ["blocker_id"], name: "index_blocks_on_blocker_id"
  end

  create_table "buyback_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "filter_option_id", null: false
    t.integer "condition", default: 0, null: false
    t.integer "quoted_cents", null: false
    t.integer "status", default: 0, null: false
    t.string "paypal_email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filter_option_id"], name: "index_buyback_requests_on_filter_option_id"
    t.index ["user_id"], name: "index_buyback_requests_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "listing_id", null: false
    t.bigint "offer_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "listing_id"], name: "index_cart_items_on_cart_id_and_listing_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["listing_id"], name: "index_cart_items_on_listing_id"
    t.index ["offer_id"], name: "index_cart_items_on_offer_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_carts_on_token", unique: true
    t.index ["user_id"], name: "index_carts_on_user_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "parent_id"
    t.string "slug", null: false
    t.jsonb "name_translations", default: {}, null: false
    t.jsonb "description_translations", default: {}, null: false
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.boolean "show_in_menu", default: true, null: false
    t.boolean "pc_finder", default: false, null: false
    t.integer "listings_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "position"], name: "index_categories_on_parent_id_and_position"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "category_filters", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "filter_definition_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "filter_definition_id"], name: "index_category_filters_on_category_id_and_filter_definition_id", unique: true
    t.index ["category_id"], name: "index_category_filters_on_category_id"
    t.index ["filter_definition_id"], name: "index_category_filters_on_filter_definition_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "kind", default: 0, null: false
    t.jsonb "title_translations", default: {}, null: false
    t.jsonb "subtitle_translations", default: {}, null: false
    t.jsonb "query", default: {}, null: false
    t.string "accent_color"
    t.boolean "active", default: true, null: false
    t.boolean "show_on_home", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "active", "position"], name: "index_collections_on_kind_and_active_and_position"
    t.index ["slug"], name: "index_collections_on_slug", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "listing_id"
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.datetime "last_message_at"
    t.integer "buyer_unread_count", default: 0, null: false
    t.integer "seller_unread_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id", "last_message_at"], name: "index_conversations_on_buyer_id_and_last_message_at"
    t.index ["buyer_id"], name: "index_conversations_on_buyer_id"
    t.index ["listing_id", "buyer_id", "seller_id"], name: "index_conversations_uniqueness", unique: true
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["seller_id", "last_message_at"], name: "index_conversations_on_seller_id_and_last_message_at"
    t.index ["seller_id"], name: "index_conversations_on_seller_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.boolean "enabled", default: false, null: false
    t.string "default_locale", default: "es", null: false
    t.string "currency", default: "EUR", null: false
    t.decimal "vat_rate", precision: 5, scale: 2, default: "21.0", null: false
    t.integer "position", default: 0, null: false
    t.jsonb "legal", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "discount_codes", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.string "code", null: false
    t.integer "percent_off", null: false
    t.integer "max_uses"
    t.integer "uses_count", default: 0, null: false
    t.datetime "expires_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seller_id", "code"], name: "index_discount_codes_on_seller_id_and_code", unique: true
    t.index ["seller_id"], name: "index_discount_codes_on_seller_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_favorites_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "filter_definitions", force: :cascade do |t|
    t.string "key", null: false
    t.jsonb "name_translations", default: {}, null: false
    t.integer "kind", default: 0, null: false
    t.string "unit"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.boolean "collapsed", default: false, null: false
    t.boolean "in_listing_form", default: true, null: false
    t.boolean "required", default: false, null: false
    t.boolean "show_on_card", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_filter_definitions_on_key", unique: true
  end

  create_table "filter_options", force: :cascade do |t|
    t.bigint "filter_definition_id", null: false
    t.string "value", null: false
    t.jsonb "label_translations", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.boolean "featured", default: true, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filter_definition_id", "value"], name: "index_filter_options_on_filter_definition_id_and_value", unique: true
    t.index ["filter_definition_id"], name: "index_filter_options_on_filter_definition_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "seller_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id", "seller_id"], name: "index_follows_on_follower_id_and_seller_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
    t.index ["seller_id"], name: "index_follows_on_seller_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.integer "demand", default: 100, null: false
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "image_credits", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "title"
    t.string "creator"
    t.string "source", null: false
    t.string "source_url"
    t.string "license"
    t.string "license_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_image_credits_on_blob_id", unique: true
  end

  create_table "legal_pages", force: :cascade do |t|
    t.string "slug", null: false
    t.string "country_code", null: false
    t.string "locale", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug", "country_code", "locale"], name: "index_legal_pages_on_slug_and_country_code_and_locale", unique: true
  end

  create_table "listing_events", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "actor_id"
    t.string "action", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_listing_events_on_actor_id"
    t.index ["listing_id"], name: "index_listing_events_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.bigint "country_id", null: false
    t.bigint "region_id"
    t.string "city"
    t.string "postal_code"
    t.string "title", null: false
    t.string "slug", null: false
    t.text "description", default: "", null: false
    t.string "brand"
    t.integer "price_cents", null: false
    t.integer "original_price_cents"
    t.string "currency", default: "EUR", null: false
    t.integer "condition", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "quantity", default: 1, null: false
    t.integer "sold_count", default: 0, null: false
    t.jsonb "specs", default: {}, null: false
    t.string "labels", default: [], null: false, array: true
    t.string "tags", default: [], null: false, array: true
    t.boolean "shipping_available", default: true, null: false
    t.integer "shipping_price_cents", default: 0, null: false
    t.boolean "local_pickup", default: false, null: false
    t.integer "handling_days", default: 3, null: false
    t.boolean "allow_offers", default: true, null: false
    t.boolean "featured", default: false, null: false
    t.datetime "promoted_until"
    t.integer "performance_score"
    t.integer "views_count", default: 0, null: false
    t.integer "favorites_count", default: 0, null: false
    t.datetime "submitted_at"
    t.datetime "published_at"
    t.datetime "reviewed_at"
    t.bigint "reviewer_id"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "((setweight(to_tsvector('simple'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, (COALESCE(brand, ''::character varying))::text), 'B'::\"char\")) || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'C'::\"char\"))", stored: true
    t.index ["category_id"], name: "index_listings_on_category_id"
    t.index ["country_id", "status"], name: "index_listings_on_country_id_and_status"
    t.index ["country_id"], name: "index_listings_on_country_id"
    t.index ["labels"], name: "index_listings_on_labels", using: :gin
    t.index ["promoted_until"], name: "index_listings_on_promoted_until", where: "(promoted_until IS NOT NULL)"
    t.index ["region_id"], name: "index_listings_on_region_id"
    t.index ["reviewer_id"], name: "index_listings_on_reviewer_id"
    t.index ["searchable"], name: "index_listings_on_searchable", using: :gin
    t.index ["specs"], name: "index_listings_on_specs", opclass: :jsonb_path_ops, using: :gin
    t.index ["status", "category_id", "published_at"], name: "index_listings_on_status_and_category_id_and_published_at"
    t.index ["status", "price_cents"], name: "index_listings_on_status_and_price_cents"
    t.index ["status", "published_at"], name: "index_listings_on_status_and_published_at"
    t.index ["tags"], name: "index_listings_on_tags", using: :gin
    t.index ["title"], name: "index_listings_on_title", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id", "status"], name: "index_listings_on_user_id_and_status"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "offer_id"
    t.text "body"
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["offer_id"], name: "index_messages_on_offer_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.string "locale", default: "es", null: false
    t.string "token", null: false
    t.datetime "confirmed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_newsletter_subscriptions_on_email", unique: true
    t.index ["token"], name: "index_newsletter_subscriptions_on_token", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "kind", null: false
    t.jsonb "params", default: {}, null: false
    t.string "path"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "conversation_id"
    t.integer "amount_cents", null: false
    t.integer "status", default: 0, null: false
    t.datetime "expires_at", null: false
    t.datetime "responded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_offers_on_buyer_id"
    t.index ["conversation_id"], name: "index_offers_on_conversation_id"
    t.index ["listing_id"], name: "index_offers_on_listing_id"
    t.index ["seller_id"], name: "index_offers_on_seller_id"
    t.index ["status", "expires_at"], name: "index_offers_on_status_and_expires_at"
  end

  create_table "order_events", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "actor_id"
    t.string "from_status"
    t.string "to_status", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_order_events_on_actor_id"
    t.index ["order_id"], name: "index_order_events_on_order_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "listing_id", null: false
    t.bigint "offer_id"
    t.string "title", null: false
    t.integer "unit_price_cents", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_order_items_on_listing_id"
    t.index ["offer_id"], name: "index_order_items_on_offer_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "number", null: false
    t.string "checkout_reference", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "discount_code_id"
    t.integer "status", default: 0, null: false
    t.integer "delivery_method", default: 0, null: false
    t.string "currency", default: "EUR", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "shipping_cents", default: 0, null: false
    t.integer "discount_cents", default: 0, null: false
    t.integer "platform_fee_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.string "email", null: false
    t.jsonb "shipping_address", default: {}, null: false
    t.text "buyer_note"
    t.string "carrier"
    t.string "tracking_number"
    t.string "payment_provider"
    t.string "payment_reference"
    t.datetime "paid_at"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.datetime "protection_ends_at"
    t.text "cancel_reason"
    t.text "dispute_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id", "created_at"], name: "index_orders_on_buyer_id_and_created_at"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["checkout_reference"], name: "index_orders_on_checkout_reference"
    t.index ["discount_code_id"], name: "index_orders_on_discount_code_id"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["seller_id", "created_at"], name: "index_orders_on_seller_id_and_created_at"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
    t.index ["status", "protection_ends_at"], name: "index_orders_on_status_and_protection_ends_at"
  end

  create_table "promotions", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.integer "kind", default: 0, null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_promotions_on_listing_id"
    t.index ["status", "ends_at"], name: "index_promotions_on_status_and_ends_at"
    t.index ["user_id"], name: "index_promotions_on_user_id"
  end

  create_table "regions", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "code"], name: "index_regions_on_country_id_and_code", unique: true
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "reporter_id"
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.integer "reason", default: 0, null: false
    t.text "details"
    t.string "reporter_email"
    t.integer "status", default: 0, null: false
    t.text "resolution_note"
    t.bigint "resolved_by_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["resolved_by_id"], name: "index_reports_on_resolved_by_id"
    t.index ["status", "created_at"], name: "index_reports_on_status_and_created_at"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "reviewer_id", null: false
    t.bigint "seller_id", null: false
    t.integer "rating", null: false
    t.text "body"
    t.text "seller_reply"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_reviews_on_order_id", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["seller_id", "status", "created_at"], name: "index_reviews_on_seller_id_and_status_and_created_at"
    t.index ["seller_id"], name: "index_reviews_on_seller_id"
  end

  create_table "saved_searches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.jsonb "query", default: {}, null: false
    t.boolean "notify", default: true, null: false
    t.integer "frequency", default: 0, null: false
    t.datetime "last_notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notify"], name: "index_saved_searches_on_notify"
    t.index ["user_id"], name: "index_saved_searches_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.jsonb "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "email", null: false
    t.integer "topic", default: 0, null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.text "internal_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "created_at"], name: "index_support_tickets_on_status_and_created_at"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "provider"
    t.string "uid"
    t.string "username", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "suspension_reason"
    t.string "locale", default: "es", null: false
    t.bigint "country_id"
    t.bigint "region_id"
    t.string "city"
    t.text "bio"
    t.integer "seller_type", default: 0, null: false
    t.string "store_name"
    t.string "store_tagline"
    t.string "legal_name"
    t.string "tax_id"
    t.string "business_address"
    t.string "trade_register_number"
    t.datetime "trader_certified_at"
    t.datetime "verified_at"
    t.boolean "vacation_mode", default: false, null: false
    t.string "vacation_message"
    t.boolean "allow_offers_default", default: true, null: false
    t.integer "return_window_days", default: 0, null: false
    t.text "store_policies"
    t.decimal "rating_avg", precision: 3, scale: 2, default: "0.0", null: false
    t.integer "reviews_count", default: 0, null: false
    t.integer "listings_count", default: 0, null: false
    t.integer "sales_count", default: 0, null: false
    t.integer "followers_count", default: 0, null: false
    t.jsonb "notification_preferences", default: {}, null: false
    t.boolean "marketing_consent", default: false, null: false
    t.datetime "terms_accepted_at"
    t.datetime "last_seen_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((username)::text)", name: "index_users_on_lower_username", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["seller_type"], name: "index_users_on_seller_type"
    t.index ["status"], name: "index_users_on_status"
    t.index ["store_name"], name: "index_users_on_store_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "blocks", "users", column: "blocked_id"
  add_foreign_key "blocks", "users", column: "blocker_id"
  add_foreign_key "buyback_requests", "filter_options"
  add_foreign_key "buyback_requests", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "listings"
  add_foreign_key "cart_items", "offers"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "category_filters", "categories"
  add_foreign_key "category_filters", "filter_definitions"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users", column: "buyer_id"
  add_foreign_key "conversations", "users", column: "seller_id"
  add_foreign_key "discount_codes", "users", column: "seller_id"
  add_foreign_key "favorites", "listings"
  add_foreign_key "favorites", "users"
  add_foreign_key "filter_options", "filter_definitions"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "follows", "users", column: "seller_id"
  add_foreign_key "image_credits", "active_storage_blobs", column: "blob_id"
  add_foreign_key "listing_events", "listings"
  add_foreign_key "listing_events", "users", column: "actor_id"
  add_foreign_key "listings", "categories"
  add_foreign_key "listings", "countries"
  add_foreign_key "listings", "regions"
  add_foreign_key "listings", "users"
  add_foreign_key "listings", "users", column: "reviewer_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "offers"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "offers", "conversations"
  add_foreign_key "offers", "listings"
  add_foreign_key "offers", "users", column: "buyer_id"
  add_foreign_key "offers", "users", column: "seller_id"
  add_foreign_key "order_events", "orders"
  add_foreign_key "order_events", "users", column: "actor_id"
  add_foreign_key "order_items", "listings"
  add_foreign_key "order_items", "offers"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "discount_codes"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "promotions", "listings"
  add_foreign_key "promotions", "users"
  add_foreign_key "regions", "countries"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reports", "users", column: "resolved_by_id"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "reviews", "users", column: "seller_id"
  add_foreign_key "saved_searches", "users"
  add_foreign_key "support_tickets", "users"
  add_foreign_key "users", "countries"
  add_foreign_key "users", "regions"
end
