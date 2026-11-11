class Category < ApplicationRecord
  include Translatable
  translates :name, :description

  TREE_CACHE_KEY = "categories/tree/v1".freeze

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, -> { order(:position) }, class_name: "Category", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :listings, dependent: :restrict_with_error
  has_many :category_filters, -> { order(:position) }, dependent: :delete_all
  has_many :filter_definitions, through: :category_filters
  has_one_attached :image

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validate :name_present
  validate :parent_not_self

  scope :active, -> { where(active: true) }
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :id) }
  scope :menu, -> { active.roots.where(show_in_menu: true).ordered }

  after_commit -> { Rails.cache.delete(TREE_CACHE_KEY) }

  # One query for the whole tree; categories are few and cached.
  def self.tree
    Rails.cache.fetch(TREE_CACHE_KEY) do
      all_categories = active.ordered.to_a
      all_categories.group_by(&:parent_id).transform_values { |list| list.map(&:id) }
        .then { |index| { index: index, records: all_categories.index_by(&:id) } }
    end
  end

  def self.cached_children_of(id)
    tree[:index].fetch(id, []).map { |child_id| tree[:records][child_id] }
  end

  def self.cached_find(id) = tree[:records][id]

  def ancestors
    list = []
    node = self
    while node.parent_id
      node = Category.cached_find(node.parent_id) || node.parent
      break unless node

      list.unshift(node)
    end
    list
  end

  def path
    ancestors + [self]
  end

  def root
    path.first
  end

  def descendant_ids
    ids = [id]
    frontier = [id]
    while frontier.any?
      frontier = frontier.flat_map { |parent_id| Category.tree[:index].fetch(parent_id, []) }
      ids.concat(frontier)
    end
    ids
  end

  def leaf?
    Category.tree[:index].fetch(id, []).empty?
  end

  # Filters attached to this category or any of its ancestors (ancestors first).
  def applicable_filters
    @applicable_filters ||= begin
      category_ids = path.map(&:id)
      CategoryFilter.where(category_id: category_ids).includes(filter_definition: :filter_options).to_a
        .sort_by { |link| [category_ids.index(link.category_id), link.position, link.filter_definition.position] }
        .map(&:filter_definition).select(&:active).uniq
    end
  end

  def to_param
    slug
  end

  private

  def name_present
    errors.add(:name_translations, :blank) if name_translations.values.all?(&:blank?)
  end

  def parent_not_self
    errors.add(:parent_id, :invalid) if parent_id.present? && (parent_id == id || (persisted? && descendant_ids.include?(parent_id)))
  end
end
