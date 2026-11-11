class RobotsController < ApplicationController
  def show
    expires_in 1.day, public: true
    render plain: RobotsFile.new(sitemap_url: sitemap_url, allow: !feature?(:maintenance_mode)).to_s
  end
end
