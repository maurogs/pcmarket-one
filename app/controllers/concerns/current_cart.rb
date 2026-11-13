module CurrentCart
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart, :cart_items_count
  end

  private

  def current_cart
    @current_cart ||= user_signed_in? ? user_cart : guest_cart
  end

  def cart_items_count
    @cart_items_count ||= existing_cart&.items_count.to_i
  end

  def existing_cart
    return @current_cart if @current_cart
    return current_user.cart if user_signed_in?

    Cart.find_by(token: cookies.signed[:cart_token], user_id: nil) if cookies.signed[:cart_token]
  end

  def user_cart
    cart = current_user.cart || current_user.create_cart!
    guest = cookies.signed[:cart_token] && Cart.find_by(token: cookies.signed[:cart_token], user_id: nil)
    if guest
      cart.merge!(guest)
      cookies.delete(:cart_token)
    end
    cart
  end

  def guest_cart
    cart = Cart.find_by(token: cookies.signed[:cart_token], user_id: nil) if cookies.signed[:cart_token]
    cart ||= Cart.create!
    cookies.signed.permanent[:cart_token] = { value: cart.token, httponly: true, same_site: :lax }
    cart
  end
end
