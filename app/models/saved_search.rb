class SavedSearch < ApplicationRecord
  MAX_PER_USER = 25

  enum :frequency, { instant: 0, daily: 1 }, default: :instant

  belongs_to :user

  validates :name, presence: true, length: { maximum: 80 }
  validate { errors.add(:base, :too_many_saved_searches, count: MAX_PER_USER) if new_record? && user && user.saved_searches.count >= MAX_PER_USER }

  scope :notifiable, -> { where(notify: true) }

  def search
    ListingSearch.new(query.symbolize_keys)
  end

  def matches?(listing)
    search.results.where(id: listing.id).exists?
  end

  def path_params
    query.compact_blank
  end
end
