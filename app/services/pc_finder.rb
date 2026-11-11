# Converts PC Finder quiz answers into a ListingSearch and FPS estimates.
class PcFinder
  STEPS = %w[games resolution fps budget case_color cooling vibe].freeze
  RESOLUTIONS = %w[1080p 1440p 2160p].freeze
  FPS_TARGETS = [ 60, 144, 240 ].freeze
  BUDGETS = { "under_800" => [ nil, 800 ], "800_1200" => [ 800, 1200 ], "1200_2000" => [ 1200, 2000 ], "over_2000" => [ 2000, nil ] }.freeze
  CASE_COLORS = %w[black white multicolor].freeze
  COOLING = %w[air aio custom_loop].freeze
  VIBES = %w[minimalist rgb anime competitive retro].freeze

  attr_reader :answers

  def initialize(params = {})
    raw = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    @answers = raw.stringify_keys.slice(*STEPS)
  end

  def games = Game.active.where(slug: Array(answers["games"]).first(3))
  def resolution = RESOLUTIONS.include?(answers["resolution"]) ? answers["resolution"] : "1080p"
  def fps_target = FPS_TARGETS.include?(answers["fps"].to_i) ? answers["fps"].to_i : 60

  def search_params
    min, max = BUDGETS[answers["budget"]]
    filters = {}
    filters["case_color"] = [ answers["case_color"] ] if CASE_COLORS.include?(answers["case_color"])
    filters["cpu_cooler_type"] = [ answers["cooling"] ] if COOLING.include?(answers["cooling"])
    { category: "gaming-pcs", min_price: min, max_price: max, f: filters,
      tags: VIBES.include?(answers["vibe"]) ? [ answers["vibe"] ] : nil, sort: "value" }.compact
  end

  # Keeps listings that reach the FPS target in every selected game.
  def results(limit: 120)
    scope = ListingSearch.new(search_params).results.for_card.limit(limit)
    selected_games = games.to_a
    return scope.to_a if selected_games.empty?

    scope.select do |listing|
      selected_games.all? { |game| listing.estimated_fps(game, resolution).to_i >= fps_target }
    end
  end
end
