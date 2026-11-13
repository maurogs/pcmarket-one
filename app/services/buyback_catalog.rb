# GPU/CPU models we buy directly (Sell to us), priced through filter option metadata.
module BuybackCatalog
  module_function

  def options
    FilterOption.joins(:filter_definition)
      .where(filter_definitions: { key: %w[gpu_model cpu_model] })
      .where("(filter_options.metadata->>'buyback_cents')::int > 0")
      .includes(:filter_definition).order("filter_definitions.key", :position)
  end
end
