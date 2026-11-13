class CountryPreferencesController < ApplicationController
  def update
    code = params[:country].to_s.upcase
    cookies.permanent[Localization::COUNTRY_COOKIE] = code if Country.enabled_codes.include?(code)
    redirect_back fallback_location: root_path
  end
end
