class BlocksController < ApplicationController
  before_action :authenticate_user!

  def index
    @blocks = current_user.blocks_made.includes(:blocked).order(created_at: :desc)
  end

  def create
    blocked = User.find_by!("lower(username) = ?", params[:username].to_s.downcase)
    current_user.blocks_made.find_or_create_by!(blocked: blocked)
    redirect_back fallback_location: blocks_path, notice: t(".success", name: blocked.display_name)
  end

  def destroy
    current_user.blocks_made.find(params[:id]).destroy
    redirect_to blocks_path, notice: t(".success"), status: :see_other
  end
end
