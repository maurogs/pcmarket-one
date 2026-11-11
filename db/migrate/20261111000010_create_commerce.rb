class CreateCommerce < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true, index: { unique: true }
      t.string :token, null: false
      t.timestamps
    end
    add_index :carts, :token, unique: true

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
    add_index :cart_items, [:cart_id, :listing_id], unique: true

    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :company
      t.string :line1, null: false
      t.string :line2
      t.string :city, null: false
      t.string :region
      t.string :postal_code, null: false
      t.string :country_code, null: false, default: "ES"
      t.string :phone
      t.boolean :default, null: false, default: false
      t.timestamps
    end

    create_table :discount_codes do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :code, null: false
      t.integer :percent_off, null: false
      t.integer :max_uses
      t.integer :uses_count, null: false, default: 0
      t.datetime :expires_at
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :discount_codes, [:seller_id, :code], unique: true

    create_table :orders do |t|
      t.string :number, null: false
      t.string :checkout_reference, null: false
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :discount_code, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :delivery_method, null: false, default: 0
      t.string :currency, null: false, default: "EUR"
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_cents, null: false, default: 0
      t.integer :discount_cents, null: false, default: 0
      t.integer :platform_fee_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :email, null: false
      t.jsonb :shipping_address, null: false, default: {}
      t.text :buyer_note
      t.string :carrier
      t.string :tracking_number
      t.string :payment_provider
      t.string :payment_reference
      t.datetime :paid_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.datetime :protection_ends_at
      t.text :cancel_reason
      t.text :dispute_reason
      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_index :orders, :checkout_reference
    add_index :orders, [:buyer_id, :created_at]
    add_index :orders, [:seller_id, :created_at]
    add_index :orders, [:status, :protection_ends_at]

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.string :title, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end

    create_table :order_events do |t|
      t.references :order, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :from_status
      t.string :to_status, null: false
      t.text :note
      t.timestamps
    end

    add_foreign_key :reviews, :orders
  end
end
