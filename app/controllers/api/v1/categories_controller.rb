module Api
  module V1
    class CategoriesController < BaseController
      def index
        expires_in 10.minutes, public: true
        render json: { data: Category.active.ordered.map { |c| CategorySerializer.call(c) } }
      end

      def show
        category = Category.active.find_by!(slug: params[:id])
        render json: { data: CategorySerializer.call(category).merge(filters: category.applicable_filters.map { |f| FilterSerializer.call(f) }) }
      end
    end
  end
end
