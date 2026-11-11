class OffersController < ApplicationController
  before_action :authenticate_user!

  ACTIONS = %w[accept decline withdraw].freeze

  def update
    offer = Offer.find(params[:id])
    decision = params[:decision].to_s
    authorize!(ACTIONS.include?(decision) && [offer.buyer_id, offer.seller_id].include?(current_user.id))
    offer.public_send("#{decision}!", current_user)
    redirect_to conversation_path(offer.conversation), notice: t("offers.#{decision}ed")
  rescue ArgumentError
    redirect_to conversation_path(offer.conversation), alert: t("offers.not_actionable")
  end
end
