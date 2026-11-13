class PcFindersController < ApplicationController
  before_action { require_feature!(:pc_finder_enabled) }

  def show
    @games = Game.active.with_attached_cover
    @finder = PcFinder.new(params.permit(:resolution, :fps, :budget, :case_color, :cooling, :vibe, games: []))
    @gamer_profiles = Collection.active.gamer_profile.ordered.with_attached_image
    @game_collections = Collection.active.game.ordered.with_attached_image
    return unless params[:results].present?

    @results = @finder.results
  end
end
