class BuybackRequestsController < ApplicationController
  before_action { require_feature!(:sell_to_us_enabled) }
  before_action :authenticate_user!, except: :new

  def index
    @requests = current_user.buyback_requests.includes(filter_option: :filter_definition).order(created_at: :desc)
  end

  def new
    @options = BuybackCatalog.options
    @request = BuybackRequest.new
  end

  def create
    @request = current_user.buyback_requests.new(params.require(:buyback_request).permit(:filter_option_id, :condition, :paypal_email, :notes))
    if BuybackCatalog.options.include?(@request.filter_option) && @request.save
      redirect_to buyback_requests_path, notice: t(".success")
    else
      @options = BuybackCatalog.options
      render :new, status: :unprocessable_entity
    end
  end
end
