class Game < ApplicationRecord
  has_one_attached :cover

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :demand, numericality: { only_integer: true, in: 10..1000 }

  scope :active, -> { where(active: true).order(:position, :name) }

  def to_param = slug
end
