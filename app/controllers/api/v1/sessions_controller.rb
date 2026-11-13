module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate!, only: :destroy
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_error(:too_many_requests, :rate_limited) }

      def create
        user = User.find_for_authentication(email: params[:email].to_s.downcase)
        if user&.valid_for_authentication? { user.valid_password?(params[:password].to_s) } && user.active_for_authentication?
          token = user.api_tokens.create!(name: params[:device_name].to_s.first(60).presence || "mobile")
          render json: { token: token.plain_token, expires_at: token.expires_at, user: UserSerializer.private(user) }, status: :created
        else
          render_error(:unauthorized, :invalid_credentials)
        end
      end

      def destroy
        @current_api_token.destroy
        head :no_content
      end
    end
  end
end
