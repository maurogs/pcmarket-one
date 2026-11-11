module Api
  module V1
    class ConversationsController < BaseController
      before_action :authenticate!

      def index
        conversations = paginate(Conversation.for_user(current_user).includes(:buyer, :seller, :listing).recent)
        render json: { data: conversations.map { |c| ConversationSerializer.summary(c, current_user) }, meta: @pagination }
      end

      def show
        conversation = Conversation.find(params[:id])
        authorize!(conversation.participant?(current_user))
        conversation.mark_read_for!(current_user)
        messages = conversation.messages.includes(:sender, :offer).last(200)
        render json: { data: ConversationSerializer.summary(conversation, current_user).merge(messages: messages.map { |m| ConversationSerializer.message(m) }) }
      end

      def create
        listing = Listing.find(params[:listing_id].to_i)
        authorize!(listing.user_id != current_user.id && !current_user.blocked?(listing.user))
        conversation = Conversation.find_or_create_by!(listing: listing, buyer: current_user, seller: listing.user)
        conversation.post!(sender: current_user, body: params[:body]) if params[:body].present?
        render json: { data: ConversationSerializer.summary(conversation, current_user) }, status: :created
      end
    end
  end
end
