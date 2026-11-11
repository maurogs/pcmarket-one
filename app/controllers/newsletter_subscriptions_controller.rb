class NewsletterSubscriptionsController < ApplicationController
  before_action { require_feature!(:newsletter_enabled) }
  before_action :set_subscription, only: %i[show update destroy]
  rate_limit to: 5, within: 10.minutes, only: :create

  def create
    subscription = NewsletterSubscription.find_or_initialize_by(email: params[:email].to_s.strip.downcase)
    subscription.locale = I18n.locale
    if subscription.save
      NewsletterMailer.with(subscription: subscription).confirmation.deliver_later unless subscription.confirmed_at
      redirect_back fallback_location: root_path, notice: t(".success")
    else
      redirect_back fallback_location: root_path, alert: t(".invalid")
    end
  end

  def show; end

  def update
    @subscription.confirm!
    redirect_to root_path, notice: t(".success")
  end

  def destroy
    @subscription.unsubscribe!
    redirect_to root_path, notice: t(".success"), status: :see_other
  end

  private

  def set_subscription
    @subscription = NewsletterSubscription.find_by!(token: params[:token])
  end
end
