class NotificationReadingsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path, notice: t(".success")
  end
end
