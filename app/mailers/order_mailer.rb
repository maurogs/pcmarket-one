class OrderMailer < ApplicationMailer
  def status_changed
    @order = params[:order]
    @recipient = params[:recipient]
    with_locale_for(@recipient) do
      @role = @recipient == @order.seller ? :seller : :buyer
      mail to: @recipient.email, subject: t("mailers.order.status_changed.subject.#{@order.status}", number: @order.number)
    end
  end
end
