class Stores::FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_store

  def create
    follow = current_user.active_follows.find_or_create_by(seller: @store)
    Notification.deliver(@store, :new_follower, path: store_path(current_user), follower: current_user.display_name) if follow.previously_new_record?
    respond
  end

  def destroy
    current_user.active_follows.where(seller: @store).destroy_all
    respond
  end

  private

  def set_store
    @store = User.find_by!("lower(username) = ?", params[:store_id].to_s.downcase)
  end

  def respond
    @store.reload
    respond_to do |format|
      format.turbo_stream { render "stores/follow" }
      format.html { redirect_back fallback_location: store_path(@store) }
    end
  end
end
