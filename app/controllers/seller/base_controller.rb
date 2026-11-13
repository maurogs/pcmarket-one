class Seller::BaseController < ApplicationController
  before_action :require_active_user!
  layout "application"
end
