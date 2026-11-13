class SupportMailer < ApplicationMailer
  def received
    @ticket = params[:ticket]
    mail to: @ticket.email, subject: t("mailers.support.received.subject", id: @ticket.id)
  end
end
