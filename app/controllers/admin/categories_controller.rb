class Admin::CategoriesController < Admin::BaseController
  include AdminTranslations
  before_action :require_admin!, except: %i[index show]
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = Category.includes(:parent).order(:parent_id, :position)
    @roots = @categories.select { |category| category.parent_id.nil? }
  end

  def show
    redirect_to edit_admin_category_path(@category)
  end

  def new
    @category = Category.new(parent_id: params[:parent_id], position: Category.maximum(:position).to_i + 1)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      audit!("category.created", @category)
      redirect_to admin_categories_path, notice: t("admin.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      audit!("category.updated", @category)
      redirect_to admin_categories_path, notice: t("admin.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      audit!("category.destroyed", nil, slug: @category.slug)
      redirect_to admin_categories_path, notice: t("admin.flash.destroyed"), status: :see_other
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  end

  def category_params
    params.require(:category).permit(:slug, :parent_id, :icon, :position, :active, :show_in_menu, :pc_finder, :image,
                                     *translated_attributes(:name, :description), filter_definition_ids: [])
  end
end
