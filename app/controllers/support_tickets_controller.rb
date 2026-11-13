class SupportTicketsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create

  def new
    @ticket = SupportTicket.new(name: current_user&.full_name, email: current_user&.email, topic: params[:topic])
  end

  def create
    @ticket = SupportTicket.new(params.require(:support_ticket).permit(:name, :email, :topic, :subject, :body).merge(user: current_user))
    if @ticket.save
      SupportMailer.with(ticket: @ticket).received.deliver_later
      redirect_to root_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end
end
