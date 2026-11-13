class Admin::SupportTicketsController < Admin::BaseController
  def index
    scope = SupportTicket.recent
    scope = scope.where(status: params[:status].presence || "open") unless params[:status] == "all"
    scope = scope.where(topic: params[:topic]) if SupportTicket.topics.key?(params[:topic])
    @pagy, @tickets = paginate(scope)
  end

  def show
    @ticket = SupportTicket.find(params[:id])
  end

  def update
    ticket = SupportTicket.find(params[:id])
    ticket.update!(params.require(:support_ticket).permit(:status, :internal_note))
    redirect_to admin_support_ticket_path(ticket), notice: t("admin.flash.updated")
  end
end
