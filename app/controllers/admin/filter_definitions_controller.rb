class Admin::FilterDefinitionsController < Admin::BaseController
  include AdminTranslations
  before_action :require_admin!, except: %i[index show]
  before_action :set_definition, only: %i[show edit update destroy]

  def index
    scope = FilterDefinition.includes(:categories).ordered
    scope = scope.where("key ILIKE ?", "%#{FilterDefinition.sanitize_sql_like(params[:q])}%") if params[:q].present?
    @definitions = scope
    @option_counts = FilterOption.group(:filter_definition_id).count
  end

  def show
    redirect_to edit_admin_filter_definition_path(@definition)
  end

  def new
    @definition = FilterDefinition.new(position: FilterDefinition.maximum(:position).to_i + 1)
    3.times { @definition.filter_options.build }
  end

  def create
    @definition = FilterDefinition.new(definition_params)
    if @definition.save
      audit!("filter.created", @definition)
      redirect_to edit_admin_filter_definition_path(@definition), notice: t("admin.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    3.times { @definition.filter_options.build }
  end

  def update
    if @definition.update(definition_params)
      audit!("filter.updated", @definition)
      redirect_to edit_admin_filter_definition_path(@definition), notice: t("admin.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @definition.destroy
    audit!("filter.destroyed", nil, key: @definition.key)
    redirect_to admin_filter_definitions_path, notice: t("admin.flash.destroyed"), status: :see_other
  end

  private

  def set_definition
    @definition = FilterDefinition.find_by!(key: params[:id])
  end

  def definition_params
    permitted = params.require(:filter_definition).permit(
      :key, :kind, :unit, :position, :active, :collapsed, :in_listing_form, :required, :show_on_card,
      *translated_attributes(:name), category_ids: [],
      filter_options_attributes: [:id, :value, :position, :featured, :score, :buyback_cents, :_destroy, *translated_attributes(:label)]
    )
    Array(permitted[:filter_options_attributes]&.values).each do |option|
      metadata = { "score" => option.delete(:score).presence&.to_i, "buyback_cents" => option.delete(:buyback_cents).presence&.to_i }.compact
      option[:metadata] = metadata
    end
    permitted
  end
end
