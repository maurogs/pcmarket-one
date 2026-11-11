class CreatePlatformTables < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :reporter, foreign_key: { to_table: :users }
      t.references :reportable, polymorphic: true, null: false
      t.integer :reason, null: false, default: 0
      t.text :details
      t.string :reporter_email
      t.integer :status, null: false, default: 0
      t.text :resolution_note
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :reports, [:status, :created_at]

    create_table :support_tickets do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.integer :topic, null: false, default: 0
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.text :internal_note
      t.timestamps
    end
    add_index :support_tickets, [:status, :created_at]

    create_table :newsletter_subscriptions do |t|
      t.string :email, null: false
      t.string :locale, null: false, default: "es"
      t.string :token, null: false
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.timestamps
    end
    add_index :newsletter_subscriptions, :email, unique: true
    add_index :newsletter_subscriptions, :token, unique: true

    create_table :collections do |t|
      t.string :slug, null: false
      t.integer :kind, null: false, default: 0
      t.jsonb :title_translations, null: false, default: {}
      t.jsonb :subtitle_translations, null: false, default: {}
      t.jsonb :query, null: false, default: {}
      t.string :accent_color
      t.boolean :active, null: false, default: true
      t.boolean :show_on_home, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :collections, :slug, unique: true
    add_index :collections, [:kind, :active, :position]

    create_table :games do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.integer :demand, null: false, default: 100
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :games, :slug, unique: true

    create_table :buyback_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :filter_option, null: false, foreign_key: true
      t.integer :condition, null: false, default: 0
      t.integer :quoted_cents, null: false
      t.integer :status, null: false, default: 0
      t.string :paypal_email
      t.text :notes
      t.timestamps
    end

    create_table :promotions do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.integer :price_cents, null: false, default: 0
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :promotions, [:status, :ends_at]

    create_table :legal_pages do |t|
      t.string :slug, null: false
      t.string :country_code, null: false
      t.string :locale, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, null: false, default: true
      t.timestamps
    end
    add_index :legal_pages, [:slug, :country_code, :locale], unique: true

    create_table :audit_logs do |t|
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.references :auditable, polymorphic: true
      t.jsonb :details, null: false, default: {}
      t.string :ip_address
      t.timestamps
    end
    add_index :audit_logs, :created_at

    create_table :image_credits do |t|
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }, index: { unique: true }
      t.string :title
      t.string :creator
      t.string :source, null: false
      t.string :source_url
      t.string :license
      t.string :license_url
      t.timestamps
    end
  end
end
