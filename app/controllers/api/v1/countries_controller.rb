module Api
  module V1
    class CountriesController < BaseController
      def index
        countries = Country.enabled.ordered.includes(:regions)
        render json: { data: countries.map { |c| { code: c.code, name: c.name, currency: c.currency,
                                                   regions: c.regions.map { |r| { id: r.id, code: r.code, name: r.name } } } } }
      end
    end
  end
end
