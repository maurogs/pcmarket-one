ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/marketplace_factory"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include MarketplaceFactory

    setup { Rails.cache.clear }
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
