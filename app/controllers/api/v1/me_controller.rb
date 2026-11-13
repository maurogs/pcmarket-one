module Api
  module V1
    class MeController < BaseController
      before_action :authenticate!

      def show
        render json: { user: UserSerializer.private(current_user), unread_messages: current_user.unread_messages_count,
                       unread_notifications: current_user.unread_notifications_count, cart_items: current_user.cart&.items_count.to_i }
      end

      def update
        current_user.update!(params.permit(:first_name, :last_name, :username, :phone, :bio, :locale, :city, :region_id))
        render json: { user: UserSerializer.private(current_user) }
      end
    end
  end
end
