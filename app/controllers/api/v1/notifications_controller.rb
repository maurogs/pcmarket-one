module Api
  module V1
    class NotificationsController < BaseController
      before_action :authenticate!

      def index
        notifications = paginate(current_user.notifications.recent)
        render json: { data: notifications.map { |n| { id: n.id, kind: n.kind, message: n.message, path: n.path, read: n.read?, created_at: n.created_at } }, meta: @pagination }
      end

      def update
        current_user.notifications.find(params[:id]).update!(read_at: Time.current)
        head :no_content
      end
    end
  end
end
