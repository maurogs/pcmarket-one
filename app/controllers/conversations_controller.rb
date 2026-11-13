class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action { require_feature!(:chat_enabled) }

  def index
    @tab = %w[chats offers].include?(params[:tab]) ? params[:tab] : "chats"
    scope = Conversation.for_user(current_user).includes(:buyer, :seller, listing: { photos_attachments: :blob }).recent
    scope = scope.where(id: Offer.select(:conversation_id)) if @tab == "offers"
    @pagy, @conversations = pagy(:offset, scope, limit: 30)
  end

  def show
    @conversation = Conversation.includes(:listing, :buyer, :seller).find(params[:id])
    authorize!(@conversation.participant?(current_user))
    @conversation.mark_read_for!(current_user)
    @messages = @conversation.messages.includes(:sender, :offer).last(200)
  end

  def create
    listing = Listing.find(params[:listing_id].to_i)
    authorize!(listing.user_id != current_user.id && !current_user.blocked?(listing.user))
    conversation = Conversation.find_or_create_by!(listing: listing, buyer: current_user, seller: listing.user)
    conversation.post!(sender: current_user, body: params[:body]) if params[:body].present?
    redirect_to conversation_path(conversation)
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: listing_path(listing), alert: e.record.errors.full_messages.to_sentence
  end
end
