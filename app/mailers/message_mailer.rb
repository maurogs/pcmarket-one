class MessageMailer < ApplicationMailer
  def new_message
    @message = params[:message]
    @recipient = params[:recipient]
    with_locale_for(@recipient) do
      mail to: @recipient.email, subject: t("mailers.message.new_message.subject", sender: @message.sender.display_name)
    end
  end
end
