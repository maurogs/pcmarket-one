class ExpireOffersJob < ApplicationJob
  queue_as :low

  def perform
    Offer.expirable.update_all(status: Offer.statuses[:expired], updated_at: Time.current)
  end
end
