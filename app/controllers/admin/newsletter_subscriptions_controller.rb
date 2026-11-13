class Admin::NewsletterSubscriptionsController < Admin::BaseController
  def index
    scope = NewsletterSubscription.order(created_at: :desc)
    scope = scope.active if params[:active] == "1"
    respond_to do |format|
      format.html { @pagy, @subscriptions = paginate(scope) }
      format.csv { send_data AdminCsv.subscriptions(scope.active), filename: "newsletter-#{Date.current}.csv" }
    end
  end

  def destroy
    NewsletterSubscription.find(params[:id]).destroy
    redirect_to admin_newsletter_subscriptions_path, notice: t("admin.flash.destroyed"), status: :see_other
  end
end
