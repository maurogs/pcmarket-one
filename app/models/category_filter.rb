class CategoryFilter < ApplicationRecord
  belongs_to :category, touch: true
  belongs_to :filter_definition
  validates :filter_definition_id, uniqueness: { scope: :category_id }
end
