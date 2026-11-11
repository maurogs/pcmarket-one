class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      ## Lockable
      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token
      t.datetime :locked_at

      ## OmniAuth
      t.string :provider
      t.string :uid

      ## Profile
      t.string :username, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.integer :role, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :suspension_reason
      t.string :locale, null: false, default: "es"
      t.references :country, foreign_key: true
      t.references :region, foreign_key: true
      t.string :city
      t.text :bio

      ## Store
      t.integer :seller_type, null: false, default: 0
      t.string :store_name
      t.string :store_tagline
      t.string :legal_name
      t.string :tax_id
      t.string :business_address
      t.string :trade_register_number
      t.datetime :trader_certified_at
      t.datetime :verified_at
      t.boolean :vacation_mode, null: false, default: false
      t.string :vacation_message
      t.boolean :allow_offers_default, null: false, default: true
      t.integer :return_window_days, null: false, default: 0
      t.text :store_policies

      ## Counters / reputation
      t.decimal :rating_avg, precision: 3, scale: 2, null: false, default: 0
      t.integer :reviews_count, null: false, default: 0
      t.integer :listings_count, null: false, default: 0
      t.integer :sales_count, null: false, default: 0
      t.integer :followers_count, null: false, default: 0

      ## Preferences & consents
      t.jsonb :notification_preferences, null: false, default: {}
      t.boolean :marketing_consent, null: false, default: false
      t.datetime :terms_accepted_at
      t.datetime :last_seen_at
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, "lower(username)", unique: true, name: "index_users_on_lower_username"
    add_index :users, [:provider, :uid], unique: true, where: "provider IS NOT NULL"
    add_index :users, :role
    add_index :users, :status
    add_index :users, :seller_type
    add_index :users, :store_name, opclass: :gin_trgm_ops, using: :gin
  end
end
