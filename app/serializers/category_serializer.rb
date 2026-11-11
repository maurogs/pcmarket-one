module CategorySerializer
  module_function

  def call(category)
    { id: category.id, slug: category.slug, name: category.name, parent_id: category.parent_id,
      icon: category.icon, listings_count: category.listings_count, leaf: category.leaf? }
  end
end
