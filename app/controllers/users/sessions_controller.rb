class Users::SessionsController < Devise::SessionsController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_session_path, alert: t("errors.too_many_attempts") }
end
