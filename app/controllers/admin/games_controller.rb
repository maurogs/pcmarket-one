class Admin::GamesController < Admin::BaseController
  before_action :set_game, only: %i[edit update destroy]

  def index
    @games = Game.order(:position, :name).with_attached_cover
  end

  def new
    @game = Game.new(position: Game.maximum(:position).to_i + 1)
  end

  def create
    @game = Game.new(game_params)
    @game.save ? redirect_to(admin_games_path, notice: t("admin.flash.created")) : render(:new, status: :unprocessable_entity)
  end

  def edit; end

  def update
    @game.update(game_params) ? redirect_to(admin_games_path, notice: t("admin.flash.updated")) : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @game.destroy
    redirect_to admin_games_path, notice: t("admin.flash.destroyed"), status: :see_other
  end

  private

  def set_game = @game = Game.find_by!(slug: params[:id])
  def game_params = params.require(:game).permit(:name, :slug, :demand, :active, :position, :cover)
end
