class CreateCountriesAndRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :countries do |t|
      t.string :code, null: false, limit: 2
      t.boolean :enabled, null: false, default: false
      t.string :default_locale, null: false, default: "es"
      t.string :currency, null: false, default: "EUR"
      t.decimal :vat_rate, precision: 5, scale: 2, null: false, default: 21
      t.integer :position, null: false, default: 0
      t.jsonb :legal, null: false, default: {}
      t.timestamps
    end
    add_index :countries, :code, unique: true

    create_table :regions do |t|
      t.references :country, null: false, foreign_key: true
      t.string :code, null: false
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :regions, [:country_id, :code], unique: true
  end
end
