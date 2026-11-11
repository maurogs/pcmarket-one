require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppTestOne
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Madrid"

    # Six UI languages; Spanish is the default market language.
    config.i18n.available_locales = %i[es en fr de it pt]
    config.i18n.default_locale = :es
    config.i18n.fallbacks = { en: [:es], fr: [:en, :es], de: [:en, :es], it: [:en, :es], pt: [:en, :es] }
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.i18n.raise_on_missing_translations = false

    # ImageMagick is available everywhere we deploy; libvips is optional.
    config.active_storage.variant_processor = :mini_magick

    config.generators do |g|
      g.helper false
      g.assets false
    end
  end
end
