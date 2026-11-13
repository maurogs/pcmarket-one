class MessagesController < ApplicationController
  before_action :authenticate_user!
  rate_limit to: 30, within: 1.minute, only: :create, with: -> { head :too_many_requests }

  def create
    @conversation = Conversation.find(params[:conversation_id])
    authorize!(@conversation.participant?(current_user))
    if @conversation.blocked?
      redirect_to conversation_path(@conversation), alert: t(".blocked")
      return
    end

    @message = @conversation.post!(sender: current_user, body: params.dig(:message, :body))
    @conversation.mark_read_for!(current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to conversation_path(@conversation) }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to conversation_path(@conversation), alert: t(".invalid")
  end
end
