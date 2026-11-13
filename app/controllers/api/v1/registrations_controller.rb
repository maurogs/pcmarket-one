module Api
  module V1
    class RegistrationsController < BaseController
      rate_limit to: 5, within: 1.hour, only: :create, with: -> { render_error(:too_many_requests, :rate_limited) }

      def create
        return render_error(:forbidden, :registrations_closed) unless Setting.enabled?(:registrations_open)
        return render_error(:unprocessable_entity, :terms_required) unless ActiveModel::Type::Boolean.new.cast(params[:terms_accepted])

        user = User.create!(params.permit(:email, :password, :username, :first_name, :last_name)
                                  .merge(locale: I18n.locale, terms_accepted_at: Time.current))
        render json: { user: UserSerializer.private(user), confirmation_required: !user.confirmed? }, status: :created
      end
    end
  end
end
