module Api
  module V1
    class OffersController < BaseController
      before_action :authenticate!

      def create
        listing = Listing.find(params[:listing_id].to_i)
        result = MakeOffer.new(listing: listing, buyer: current_user, amount: params[:amount], message: params[:message]).call
        return render_validation(result.offer) unless result.success?

        render json: { data: { id: result.offer.id, status: result.offer.status, conversation_id: result.conversation.id } }, status: :created
      end

      def update
        offer = Offer.find(params[:id])
        decision = params[:decision].to_s
        authorize!(%w[accept decline withdraw].include?(decision))
        case decision
        when "accept" then offer.accept!(current_user)
        when "decline" then offer.decline!(current_user)
        when "withdraw" then offer.withdraw!(current_user)
        end
        render json: { data: { id: offer.id, status: offer.status } }
      rescue ArgumentError
        render_error(:unprocessable_entity, :not_actionable)
      end
    end
  end
end
