class CreateCategoriesAndFilters < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :parent, foreign_key: { to_table: :categories }
      t.string :slug, null: false
      t.jsonb :name_translations, null: false, default: {}
      t.jsonb :description_translations, null: false, default: {}
      t.string :icon
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :show_in_menu, null: false, default: true
      t.boolean :pc_finder, null: false, default: false
      t.integer :listings_count, null: false, default: 0
      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, [ :parent_id, :position ]

    create_table :filter_definitions do |t|
      t.string :key, null: false
      t.jsonb :name_translations, null: false, default: {}
      t.integer :kind, null: false, default: 0
      t.string :unit
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :collapsed, null: false, default: false
      t.boolean :in_listing_form, null: false, default: true
      t.boolean :required, null: false, default: false
      t.boolean :show_on_card, null: false, default: false
      t.timestamps
    end
    add_index :filter_definitions, :key, unique: true

    create_table :filter_options do |t|
      t.references :filter_definition, null: false, foreign_key: true
      t.string :value, null: false
      t.jsonb :label_translations, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :featured, null: false, default: true
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :filter_options, [ :filter_definition_id, :value ], unique: true

    create_table :category_filters do |t|
      t.references :category, null: false, foreign_key: true
      t.references :filter_definition, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :category_filters, [ :category_id, :filter_definition_id ], unique: true
  end
end
