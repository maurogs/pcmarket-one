class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.references :region, foreign_key: true
      t.string :city
      t.string :postal_code
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description, null: false, default: ""
      t.string :brand
      t.integer :price_cents, null: false
      t.integer :original_price_cents
      t.string :currency, null: false, default: "EUR"
      t.integer :condition, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :quantity, null: false, default: 1
      t.integer :sold_count, null: false, default: 0
      t.jsonb :specs, null: false, default: {}
      t.string :labels, array: true, null: false, default: []
      t.string :tags, array: true, null: false, default: []
      t.boolean :shipping_available, null: false, default: true
      t.integer :shipping_price_cents, null: false, default: 0
      t.boolean :local_pickup, null: false, default: false
      t.integer :handling_days, null: false, default: 3
      t.boolean :allow_offers, null: false, default: true
      t.boolean :featured, null: false, default: false
      t.datetime :promoted_until
      t.integer :performance_score
      t.integer :views_count, null: false, default: 0
      t.integer :favorites_count, null: false, default: 0
      t.datetime :submitted_at
      t.datetime :published_at
      t.datetime :reviewed_at
      t.references :reviewer, foreign_key: { to_table: :users }
      t.text :rejection_reason
      t.timestamps
    end
    add_virtual_column = <<~SQL.squish
      setweight(to_tsvector('simple', coalesce(title, '')), 'A') ||
      setweight(to_tsvector('simple', coalesce(brand, '')), 'B') ||
      setweight(to_tsvector('simple', coalesce(description, '')), 'C')
    SQL
    add_column :listings, :searchable, :virtual, type: :tsvector, as: add_virtual_column, stored: true

    add_index :listings, :searchable, using: :gin
    add_index :listings, :title, opclass: :gin_trgm_ops, using: :gin
    add_index :listings, :specs, using: :gin, opclass: :jsonb_path_ops
    add_index :listings, :labels, using: :gin
    add_index :listings, :tags, using: :gin
    add_index :listings, [ :status, :published_at ]
    add_index :listings, [ :status, :category_id, :published_at ]
    add_index :listings, [ :status, :price_cents ]
    add_index :listings, [ :user_id, :status ]
    add_index :listings, [ :country_id, :status ]
    add_index :listings, :promoted_until, where: "promoted_until IS NOT NULL"

    create_table :listing_events do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.text :note
      t.timestamps
    end
  end
end
