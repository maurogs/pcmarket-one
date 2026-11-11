# Minimal reference data and record builders shared by the test suite.
module MarketplaceFactory
  def spain
    @spain ||= Country.find_or_create_by!(code: "ES") { |c| c.enabled = true }.tap do |country|
      country.regions.find_or_create_by!(code: "es-madrid") { |r| r.name = "Madrid" }
    end
  end

  def gpu_filter
    @gpu_filter ||= FilterDefinition.find_or_create_by!(key: "gpu_model") do |f|
      f.name_translations = { "en" => "Graphics card", "es" => "Tarjeta gráfica" }
    end.tap do |definition|
      definition.filter_options.find_or_create_by!(value: "rtx_4070") { |o| o.label_translations = { "en" => "RTX 4070" }; o.metadata = { "score" => 17_800 } }
      definition.filter_options.find_or_create_by!(value: "rtx_3060") { |o| o.label_translations = { "en" => "RTX 3060" }; o.metadata = { "score" => 8_700 } }
    end
  end

  def category(slug = "gpus")
    Category.find_or_create_by!(slug: slug) { |c| c.name_translations = { "en" => slug.titleize, "es" => slug.titleize } }.tap do |category|
      CategoryFilter.find_or_create_by!(category: category, filter_definition: gpu_filter)
    end
  end

  def create_user(**attributes)
    @user_sequence = (@user_sequence || 0) + 1
    user = User.new({ email: "user#{@user_sequence}-#{SecureRandom.hex(3)}@example.com", password: "Password123!",
                      terms_accepted_at: Time.current, country: spain }.merge(attributes))
    user.skip_confirmation!
    user.save!
    user
  end

  def photo_blob
    ActiveStorage::Blob.create_and_upload!(io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")), filename: "photo.jpg", content_type: "image/jpeg")
  end

  def create_listing(user: create_user, status: :published, **attributes)
    listing = Listing.new({ user: user, category: category, country: spain, region: spain.regions.first, title: "GeForce RTX 4070 Founders Edition",
                            description: "Graphics card in perfect condition, barely used, with original box.", price: 450,
                            specs: { "gpu_model" => "rtx_4070" }, status: status, published_at: (Time.current if status == :published) }.merge(attributes))
    listing.photos.attach(photo_blob)
    listing.save!
    listing
  end
end
