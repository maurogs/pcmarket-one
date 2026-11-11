class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @notifications = pagy(:offset, current_user.notifications.recent, limit: 30)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read_at: Time.current) unless notification.read?
    redirect_to notification.path.presence || notifications_path
  end
end
