module Api
  module V1
    class BaseController < ActionController::API
      include Pagy::Method
      include ActionController::HttpAuthentication::Token::ControllerMethods

      MAX_PER_PAGE = 50

      before_action :set_locale
      before_action :reject_in_maintenance

      rescue_from ActiveRecord::RecordNotFound, with: -> { render_error(:not_found, :not_found) }
      rescue_from ActiveRecord::RecordInvalid, with: ->(e) { render_validation(e.record) }
      rescue_from ActionController::ParameterMissing, with: ->(e) { render_error(:bad_request, :parameter_missing, e.message) }
      rescue_from Authorization::NotAuthorized, Order::NotAllowed, with: -> { render_error(:forbidden, :forbidden) }

      private

      def current_user
        return @current_user if defined?(@current_user)

        token = authenticate_with_http_token { |value, _| ApiToken.authenticate(value) }
        @current_api_token = token
        @current_user = token&.user
      end

      def authenticate!
        render_error(:unauthorized, :unauthorized) unless current_user
      end

      def authorize!(condition)
        raise Authorization::NotAuthorized unless condition
      end

      def set_locale
        requested = request.headers["Accept-Language"].to_s.scan(/[a-z]{2}/).find { |code| I18n.available_locales.map(&:to_s).include?(code) }
        I18n.locale = params[:locale].presence_in(I18n.available_locales.map(&:to_s)) || requested || I18n.default_locale
      end

      def reject_in_maintenance
        render_error(:service_unavailable, :maintenance) if Setting.enabled?(:maintenance_mode)
      end

      def paginate(scope)
        limit = params[:per_page].to_i.clamp(1, MAX_PER_PAGE)
        limit = 24 if params[:per_page].blank?
        pagy_obj, records = pagy(:offset, scope, limit: limit)
        response.headers["X-Total-Count"] = pagy_obj.count.to_s
        response.headers["X-Page"] = pagy_obj.page.to_s
        response.headers["X-Per-Page"] = limit.to_s
        @pagination = { page: pagy_obj.page, per_page: limit, total: pagy_obj.count, pages: pagy_obj.pages, next: pagy_obj.next }
        records
      end

      def render_error(status, code, message = nil)
        render json: { error: { code: code, message: message || I18n.t("api.errors.#{code}") } }, status: status
      end

      def render_validation(record)
        render json: { error: { code: :validation_failed, message: record.errors.full_messages.to_sentence, details: record.errors.to_hash } },
               status: :unprocessable_entity
      end
    end
  end
end
