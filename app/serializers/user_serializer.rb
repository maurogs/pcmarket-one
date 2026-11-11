module UserSerializer
  extend SerializerHelpers
  module_function

  def public(user)
    {
      username: user.username, name: user.display_name, tagline: user.store_tagline, bio: user.bio,
      seller_type: user.seller_type, verified: user.verified?, rating: user.rating_avg.to_f, reviews_count: user.reviews_count,
      listings_count: user.listings_count, sales_count: user.sales_count, followers_count: user.followers_count,
      vacation_mode: user.vacation_mode, avatar: image_url(user.avatar), logo: image_url(user.store_logo), member_since: user.created_at.to_date
    }
  end

  def private(user)
    public(user).merge(email: user.email, first_name: user.first_name, last_name: user.last_name, phone: user.phone,
                       locale: user.locale, confirmed: user.confirmed?, country: user.country&.code, role: user.role)
  end
end
