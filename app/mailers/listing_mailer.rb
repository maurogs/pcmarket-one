class ListingMailer < ApplicationMailer
  def approved
    @listing = params[:listing]
    with_locale_for(@listing.user) do
      mail to: @listing.user.email, subject: t("mailers.listing.approved.subject", title: @listing.title)
    end
  end

  def rejected
    @listing = params[:listing]
    with_locale_for(@listing.user) do
      mail to: @listing.user.email, subject: t("mailers.listing.rejected.subject", title: @listing.title)
    end
  end
end
