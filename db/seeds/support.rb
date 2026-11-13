require "net/http"
require "json"

module SeedSupport
  LOCALES = %w[es en fr de it pt].freeze
  OTHER = { "es" => "Otro", "en" => "Other", "fr" => "Autre", "de" => "Andere", "it" => "Altro", "pt" => "Outro" }.freeze

  module_function

  def step(name)
    started = Time.current
    print "→ #{name}... "
    yield
    puts "done (#{(Time.current - started).round(1)}s)"
  end

  # Accepts "Label" (same in every language) or a hash of locale => label.
  def translations(value)
    value.is_a?(Hash) ? value.transform_keys(&:to_s) : { "en" => value.to_s }
  end

  def t6(es, en, fr, de, it, pt)
    { "es" => es, "en" => en, "fr" => fr, "de" => de, "it" => it, "pt" => pt }
  end
end
