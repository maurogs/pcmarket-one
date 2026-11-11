class UserDataExport
  def initialize(user)
    @user = user
  end

  def to_json(*)
    {
      exported_at: Time.current,
      account: @user.attributes.except("encrypted_password", "reset_password_token", "confirmation_token", "unlock_token"),
      addresses: @user.addresses.map(&:attributes),
      listings: @user.listings.map { |l| l.attributes.except("searchable") },
      purchases: @user.purchases.includes(:items).map { |o| o.attributes.merge(items: o.items.map(&:attributes)) },
      sales: @user.sales.map(&:attributes),
      favorites: @user.favorites.pluck(:listing_id, :created_at),
      saved_searches: @user.saved_searches.map(&:attributes),
      messages: Message.where(sender: @user).pluck(:conversation_id, :body, :created_at),
      reviews_written: Review.where(reviewer: @user).map(&:attributes)
    }.to_json
  end
end
