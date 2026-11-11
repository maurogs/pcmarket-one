class CreateSocialTables < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.timestamps
    end
    add_index :favorites, [ :user_id, :listing_id ], unique: true

    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :follows, [ :follower_id, :seller_id ], unique: true

    create_table :blocks do |t|
      t.references :blocker, null: false, foreign_key: { to_table: :users }
      t.references :blocked, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :blocks, [ :blocker_id, :blocked_id ], unique: true

    create_table :saved_searches do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.jsonb :query, null: false, default: {}
      t.boolean :notify, null: false, default: true
      t.integer :frequency, null: false, default: 0
      t.datetime :last_notified_at
      t.timestamps
    end
    add_index :saved_searches, :notify

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.jsonb :params, null: false, default: {}
      t.string :path
      t.datetime :read_at
      t.timestamps
    end
    add_index :notifications, [ :user_id, :read_at ]

    create_table :reviews do |t|
      t.references :order, null: false, foreign_key: false, index: { unique: true }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :body
      t.text :seller_reply
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :reviews, [ :seller_id, :status, :created_at ]
  end
end
