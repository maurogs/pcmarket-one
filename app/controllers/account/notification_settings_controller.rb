class Account::NotificationSettingsController < Account::BaseController
  KEYS = %w[messages orders saved_searches marketing].freeze

  def edit; end

  def update
    preferences = KEYS.index_with { |key| params.dig(:preferences, key) == "1" }
    current_user.update!(notification_preferences: preferences, marketing_consent: preferences["marketing"])
    redirect_to edit_account_notification_settings_path, notice: t(".success")
  end
end
