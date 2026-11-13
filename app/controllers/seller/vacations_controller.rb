class Seller::VacationsController < Seller::BaseController
  def update
    current_user.update!(vacation_mode: params[:vacation_mode] == "1", vacation_message: params[:vacation_message].to_s.first(200))
    current_user.refresh_listings_count!
    redirect_to seller_dashboard_path, notice: t(current_user.vacation_mode? ? ".enabled" : ".disabled")
  end
end
