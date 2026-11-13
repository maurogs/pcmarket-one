class Region < ApplicationRecord
  belongs_to :country
  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :country_id }
end
