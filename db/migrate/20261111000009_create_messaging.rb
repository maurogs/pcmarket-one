class CreateMessaging < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :listing, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at
      t.integer :buyer_unread_count, null: false, default: 0
      t.integer :seller_unread_count, null: false, default: 0
      t.timestamps
    end
    add_index :conversations, [ :listing_id, :buyer_id, :seller_id ], unique: true, name: "index_conversations_uniqueness"
    add_index :conversations, [ :buyer_id, :last_message_at ]
    add_index :conversations, [ :seller_id, :last_message_at ]

    create_table :offers do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :conversation, foreign_key: true
      t.integer :amount_cents, null: false
      t.integer :status, null: false, default: 0
      t.datetime :expires_at, null: false
      t.datetime :responded_at
      t.timestamps
    end
    add_index :offers, [ :status, :expires_at ]

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :offer, foreign_key: true
      t.text :body
      t.integer :kind, null: false, default: 0
      t.timestamps
    end
    add_index :messages, [ :conversation_id, :created_at ]
  end
end
