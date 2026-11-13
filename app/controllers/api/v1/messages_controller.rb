module Api
  module V1
    class MessagesController < BaseController
      before_action :authenticate!
      rate_limit to: 30, within: 1.minute, with: -> { render_error(:too_many_requests, :rate_limited) }

      def create
        conversation = Conversation.find(params[:conversation_id])
        authorize!(conversation.participant?(current_user) && !conversation.blocked?)
        message = conversation.post!(sender: current_user, body: params[:body])
        render json: { data: ConversationSerializer.message(message) }, status: :created
      end
    end
  end
end
